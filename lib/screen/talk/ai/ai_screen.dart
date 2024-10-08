import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIScreen extends StatefulWidget {
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _filePath;
  var uuid = Uuid();
  List<Map<String, dynamic>> _messages = [];
  bool _isButtonDisabled = false; // 버튼 비활성화 여부
  bool _isLoading = false; // 로딩 애니메이션 여부
  String userUuid = ''; // 사용자 UUID 저장
  String? timestamp; // timestamp 값을 클래스 멤버로 선언

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
    _player.openPlayer(); // 플레이어 초기화
    _generateUserUuid(); // 사용자 UUID 생성
  }

  // 사용자 UUID 생성
  void _generateUserUuid() {
    setState(() {
      userUuid = uuid.v4(); // 고유 UUID 생성
    });
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

        // 녹음이 중단되면 바로 로딩 애니메이션을 시작
        _isLoading = true;
      });

      print("Recording stopped");

      if (_filePath != null) {
        File recordedFile = File(_filePath!);

        if (recordedFile.existsSync()) {
          print("File exists. Proceeding with Firebase upload.");

          // Firebase에 녹음 파일 업로드
          await _uploadFileToFirebase(recordedFile);

          // 사용자 텍스트 처리
          await _fetchUserInputTextWithTimestamp();

          // 상대방 메시지 로딩 상태 추가 (setState로 화면 갱신)
          final loadingMessageId = uuid.v4();  // 고유 ID 생성
          _addMessage('Loading...', isUser: false, id: loadingMessageId);

          // GPT 응답 확인 (20초 폴링 후 응답 및 음성 파일 가져오기)
          _checkForGPTOutputWithTimestampAndDelay(loadingMessageId);

          // 버튼은 GPT 음성 재생 완료 후에만 활성화
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
      // timestamp를 클래스 멤버 변수로 설정
      timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = '${userUuid}_$timestamp.aac';

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('$userUuid/user_input/$fileName');

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

  Future<void> _fetchUserInputTextWithTimestamp() async {
    try {
      if (timestamp == null) {
        print("Timestamp가 설정되지 않았습니다.");
        return;
      }

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference? targetFile;
      bool fileFound = false;

      // 5초 동안 폴링하여 timestamp와 일치하는 파일이 있는지 확인
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(seconds: 1));

        ListResult result = await storage.ref('$userUuid/user_input_txt/').listAll();

        for (Reference ref in result.items) {
          if (ref.name.contains(timestamp!)) {
            targetFile = ref;
            fileFound = true;
            print('Timestamp에 해당하는 user input text 파일 발견: ${targetFile.name}');
            break;
          }
        }

        if (fileFound) {
          await _fetchAndDisplayFile(targetFile!);  // 파일 처리
          break;
        }
      }

      // 5초 동안 파일을 찾지 못한 경우 에러 메시지 출력
      if (!fileFound) {
        print('Timestamp에 해당하는 user input text 파일을 5초 동안 찾지 못했습니다.');
      }
    } catch (e) {
      print('user input text 파일을 가져오는 중 오류 발생: $e');
    }
  }

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

  Future<void> _checkForGPTOutputWithTimestampAndDelay(String messageId) async {
    try {
      if (timestamp == null) {
        print("Timestamp가 설정되지 않았습니다.");
        return;
      }

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference? targetFile;
      bool fileFound = false;

      // 20초 동안 폴링하여 timestamp와 일치하는 파일이 있는지 확인
      for (int i = 0; i < 20; i++) {
        await Future.delayed(Duration(seconds: 1));

        ListResult result = await storage.ref('$userUuid/GPT_output_txt/').listAll();

        for (Reference ref in result.items) {
          if (ref.name.contains(timestamp!)) {
            targetFile = ref;
            fileFound = true;
            print('Timestamp에 해당하는 GPT output text 파일 발견: ${targetFile.name}');
            break;
          }
        }

        if (fileFound) {
          await _fetchAndDisplayGPTFile(targetFile!, messageId);  // 파일 처리
          break;
        }
      }

      // 20초 동안 파일을 찾지 못한 경우 다시 녹음 기능으로 돌아감
      if (!fileFound) {
        print('Timestamp에 해당하는 GPT output 파일을 20초 동안 찾지 못했습니다.');

        // 버튼 다시 활성화 및 로딩 애니메이션 중지
        setState(() {
          _isButtonDisabled = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('GPT output 파일을 가져오는 중 오류 발생: $e');

      // 오류 발생 시에도 다시 녹음 버튼 활성화 및 로딩 애니메이션 중지
      setState(() {
        _isButtonDisabled = false;
        _isLoading = false;
      });
    }
  }

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
        await _playGptAudioWithTimestamp();
      } else {
        print('Failed to fetch GPT output text. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch GPT output file: $e');
    }
  }

  Future<void> _playGptAudioWithTimestamp() async {
    try {
      if (timestamp == null) {
        print("Timestamp가 설정되지 않았습니다.");
        return;
      }

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference? targetMp3File;
      bool fileFound = false;

      // 20초 동안 폴링하여 timestamp와 일치하는 MP3 파일이 있는지 확인
      for (int i = 0; i < 40; i++) {  // 0.5초씩 40번 반복 -> 총 20초 동안 체크
        await Future.delayed(Duration(milliseconds: 500));

        ListResult result = await storage.ref('$userUuid/GPT_output/').listAll();

        for (Reference ref in result.items) {
          if (ref.name.contains(timestamp!) && ref.name.endsWith('.mp3')) {
            targetMp3File = ref;
            fileFound = true;
            print('Timestamp에 해당하는 GPT output audio 파일 발견: ${targetMp3File.name}');
            break;
          }
        }

        if (fileFound) {
          await _playGptAudioFile(targetMp3File!);  // 파일 처리 및 재생
          break;
        }
      }

      // 20초 동안 파일을 찾지 못한 경우 다시 녹음 버튼 활성화 및 로딩 애니메이션 중지
      if (!fileFound) {
        print('Timestamp에 해당하는 GPT output audio 파일을 20초 동안 찾지 못했습니다.');

        // 버튼 다시 활성화 및 로딩 애니메이션 중지
        setState(() {
          _isButtonDisabled = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('GPT output audio 파일을 가져오는 중 오류 발생: $e');

      // 오류가 발생한 경우에도 다시 녹음 버튼 활성화 및 로딩 애니메이션 중지
      setState(() {
        _isButtonDisabled = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _playGptAudioFile(Reference mp3Ref) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String localPath = '${tempDir.path}/${mp3Ref.name}';
      File file = File(localPath);

      await mp3Ref.writeToFile(file);
      print("MP3 파일을 로컬 경로에 다운로드 완료: $localPath");

      await _player.startPlayer(
        fromURI: file.path,
        codec: Codec.mp3,
        whenFinished: () {
          print('음성 파일 재생이 완료되었습니다.');

          // 재생이 끝나면 버튼 활성화 및 로딩 애니메이션 종료
          setState(() {
            _isButtonDisabled = false;
            _isLoading = false;
          });
        },
      );
      print('Playing MP3: ${file.path}');
    } catch (e) {
      print('MP3 파일 재생 중 오류 발생: $e');
    }
  }

  void _addMessage(String message, {required bool isUser, String? id}) {
    setState(() {
      _messages.add({
        'id': id ?? uuid.v4(), // 고유 ID 부여
        'text': message,
        'isUser': isUser
      });
    });
  }

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

      if (messageReplaced) {
        print('Loading... message replaced with GPT response.');
      } else {
        print('No Loading... message found to replace.');
      }
    });
  }

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
      backgroundColor: Color(0xFF539262),
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
                          ? Colors.white
                          : Color(0xFFCDE8D4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          _isLoading
              ? CircularProgressIndicator() // 로딩 애니메이션
              : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: _isButtonDisabled ? null : (_isRecording ? _stopRecording : _startRecording),
              child: Text(
                _isRecording ? '녹음 중단하기' : '터치해서 물어보기',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.underline, // 밑줄
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
