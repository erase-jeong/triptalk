import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(SoundRecordingApp());
}

class SoundRecordingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _filePath;
  var uuid = Uuid();
  List<Map<String, dynamic>> _messages = [];
  String openAiApiKey = 'your_openai_api_key';

  bool _isButtonDisabled = false; // 버튼 비활성화 여부
  bool _isLoading = false; // 로딩 애니메이션 여부

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
    _player.openPlayer(); // 플레이어 초기화
  }

  Future<void> _initializeRecorder() async {
    try {
      await _recorder!.openRecorder();
      await _checkPermissions();
    } catch (e) {
      print("Failed to initialize recorder: $e");
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      print("Microphone permission not granted");
      return;
    }

    status = await Permission.storage.request();
    if (!status.isGranted) {
      print("Storage permission not granted");
      return;
    }

    print("Permissions granted");
  }

  Future<void> _startRecording() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/flutter_sound_temp.aac';

      setState(() {
        _filePath = path;
        _isRecording = true;
      });

      print("Starting recording. File will be saved to: $_filePath");

      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );

      print("Recording started successfully");
    } catch (e) {
      print("Failed to start recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();

      setState(() {
        _isRecording = false;
      });

      print("Recording stopped");

      if (_filePath != null) {
        File recordedFile = File(_filePath!);

        if (recordedFile.existsSync()) {
          print("File exists. Proceeding with Firebase upload.");

          // Firebase에 녹음 파일 업로드
          await _uploadFileToFirebase(recordedFile);

          // 사용자 텍스트 처리
          await _fetchUserInputTextWithDelay();

          // 상대방 메시지 로딩 상태 추가 (setState로 화면 갱신)
          final loadingMessageId = uuid.v4();  // 고유 ID 생성
          _addMessage('Loading...', isUser: false, id: loadingMessageId);

          // GPT 응답 확인 (20초 폴링 후 응답 및 음성 파일 가져오기)
          _checkForGPTOutputWithDelay(loadingMessageId);

          // 10초 동안 버튼 비활성화 후 로딩 애니메이션
          _disableButtonForDuration(10);
        } else {
          print("Recorded file does not exist.");
        }
      } else {
        print("No file path available.");
      }
    } catch (e) {
      print("Failed to stop recording: $e");
    }
  }

  Future<void> _uploadFileToFirebase(File file) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${uuid.v4()}.aac';

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('user_input_audio/$fileName');

      print("Uploading file: ${file.path}");

      TaskSnapshot snapshot = await ref.putFile(file);
      print("Upload task completed with state: ${snapshot.state}");

      if (snapshot.state != TaskState.success) {
        print("File upload failed with state: ${snapshot.state}");
      }
    } catch (e) {
      print("Failed to upload file: $e");
    }
  }

  Future<void> _fetchUserInputTextWithDelay() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      ListResult initialResult = await storage.ref('user_input_txt/').listAll();
      int initialFileCount = initialResult.items.length;

      Reference? newFile;
      bool fileFound = false;

      // 5초 동안 폴링하여 새로운 파일이 생성되었는지 확인
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(seconds: 1));

        ListResult currentResult = await storage.ref('user_input_txt/').listAll();
        if (currentResult.items.length > initialFileCount) {
          newFile = currentResult.items.last;
          fileFound = true;
          print('New user input file found: ${newFile!.name}');
          break;
        }
      }

      // 5초 안에 새 파일이 있으면 해당 파일을 표시, 없으면 가장 최근 파일 표시
      if (fileFound && newFile != null) {
        await _fetchAndDisplayFile(newFile);
      } else {
        print('No new file found, fetching most recent file.');
        Reference? latestFile = await _getMostRecentFile(initialResult);
        if (latestFile != null) {
          await _fetchAndDisplayFile(latestFile);
        }
      }
    } catch (e) {
      print('Error while checking for new files: $e');
    }
  }

  // 가장 최근 파일 가져오기
  Future<Reference?> _getMostRecentFile(ListResult result) async {
    DateTime? latestTime;
    Reference? latestFile;

    for (Reference ref in result.items) {
      FullMetadata metadata = await ref.getMetadata();
      DateTime createdTime = metadata.timeCreated!;

      if (latestTime == null || createdTime.isAfter(latestTime)) {
        latestTime = createdTime;
        latestFile = ref;
      }
    }
    return latestFile;
  }

  // 파일을 다운로드하고 메시지로 추가
  Future<void> _fetchAndDisplayFile(Reference fileRef) async {
    try {
      String textUrl = await fileRef.getDownloadURL();
      http.Response response = await http.get(Uri.parse(textUrl));

      if (response.statusCode == 200) {
        // UTF-8로 텍스트 디코딩
        String userMessage = utf8.decode(response.bodyBytes);
        print('User input text: $userMessage');
        _addMessage(userMessage, isUser: true);
      } else {
        print('Failed to fetch user input text. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch and display file: $e');
    }
  }

  // 메시지 추가 (고유 ID 부여)
  void _addMessage(String message, {required bool isUser, String? id}) {
    setState(() {
      _messages.add({
        'id': id ?? uuid.v4(), // 고유 ID 부여
        'text': message,
        'isUser': isUser
      });
    });
  }

  Future<void> _checkForGPTOutputWithDelay(String messageId) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      ListResult initialResult = await storage.ref('GPToutputtext/').listAll();
      int initialFileCount = initialResult.items.length;

      Reference? newFile;
      bool fileFound = false;

      // 20초 동안 폴링하여 새로운 파일이 생성되었는지 확인
      for (int i = 0; i < 20; i++) {
        await Future.delayed(Duration(seconds: 1));

        ListResult currentResult = await storage.ref('GPToutputtext/').listAll();
        if (currentResult.items.length > initialFileCount) {
          newFile = currentResult.items.last;
          fileFound = true;
          print('New GPT output file found: ${newFile!.name}');
          break;
        }
      }

      // 20초 안에 새 파일이 있으면 해당 파일을 표시
      if (fileFound && newFile != null) {
        await _fetchAndDisplayGPTFile(newFile, messageId);
      } else {
        print('No new GPT output file found within 20 seconds.');
      }
    } catch (e) {
      print('Error while checking for GPT output: $e');
    }
  }

  // GPT 파일을 다운로드하고 로딩 메시지 교체 및 음성 파일 재생
  Future<void> _fetchAndDisplayGPTFile(Reference fileRef, String messageId) async {
    try {
      String textUrl = await fileRef.getDownloadURL();
      http.Response response = await http.get(Uri.parse(textUrl));

      if (response.statusCode == 200) {
        // UTF-8로 텍스트 디코딩
        String gptMessage = utf8.decode(response.bodyBytes);
        print('GPT output text: $gptMessage');

        // 로딩 메시지 교체
        _replaceLoadingMessage(gptMessage, messageId);

        // 음성 파일 다운로드 및 재생
        await _playGptAudio(messageId);
      } else {
        print('Failed to fetch GPT output text. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch GPT output file: $e');
    }
  }

  // 음성 파일을 다운로드하고 재생
  Future<void> _playGptAudio(String messageId) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      ListResult audioResult = await storage.ref('GPT_output/').listAll();

      Reference? latestMp3File;

      for (Reference ref in audioResult.items) {
        if (ref.name.endsWith('.mp3')) {
          latestMp3File = ref;
        }
      }

      if (latestMp3File != null) {
        // 파일을 로컬에 다운로드
        Directory tempDir = await getTemporaryDirectory();
        String localPath = '${tempDir.path}/${latestMp3File.name}';
        File file = File(localPath);

        await latestMp3File.writeToFile(file);

        print("MP3 파일을 로컬 경로에 다운로드 완료: $localPath");

        // 음성 파일 재생
        await _player.startPlayer(
          fromURI: file.path,
          codec: Codec.mp3,
        );
        print('Playing MP3: ${file.path}');
      }
    } catch (e) {
      print('MP3 파일 재생 중 오류 발생: $e');
    }
  }

  // 로딩 메시지를 GPT 응답 텍스트로 대체 (ID 기반으로 교체)
  void _replaceLoadingMessage(String response, String messageId) {
    setState(() {
      bool messageReplaced = false;
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i]['id'] == messageId) {
          _messages[i]['text'] = response;
          messageReplaced = true;
          break;
        }
      }

      // 강제로 UI 갱신을 위해 다시 리스트를 업데이트
      _messages = List.from(_messages);

      // Debugging 로그
      if (messageReplaced) {
        print('Loading... message replaced with GPT response.');
      } else {
        print('No Loading... message found to replace.');
      }
    });
  }

  // 버튼을 10초 동안 비활성화하는 함수
  void _disableButtonForDuration(int seconds) {
    setState(() {
      _isButtonDisabled = true;
      _isLoading = true; // 로딩 애니메이션 시작
    });

    Timer(Duration(seconds: seconds), () {
      setState(() {
        _isButtonDisabled = false; // 버튼 활성화
        _isLoading = false; // 로딩 애니메이션 중지
      });
    });
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player.closePlayer(); // 플레이어 닫기
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with GPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                return Align(
                  alignment: message['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message['isUser']
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['text']),
                  ),
                );
              },
            ),
          ),
          _isLoading
              ? CircularProgressIndicator() // 로딩 애니메이션
              : Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: _isButtonDisabled ? null : (_isRecording ? _stopRecording : _startRecording),
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ),
        ],
      ),
    );
  }
}
