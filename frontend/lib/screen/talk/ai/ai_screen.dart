import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      backgroundColor: Color(0xFF539262),
      body: Column(

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Row의 시작점에 맞춰 배치
            children: [
              Padding(
                padding: const EdgeInsets.only(top:10.0, left: 20.0), // 왼쪽 패딩 추가
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 텍스트와 아이콘을 왼쪽 정렬
                  mainAxisSize: MainAxisSize.min, // Column 크기를 내용에 맞춤
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                        SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격
                        Text(
                          "오디오 재생 완료",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // 두 텍스트 사이의 간격
                    Text(
                      "토커토커님의 발걸음에 맞춰가고 있어요!",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'HSSantokki',
                        fontSize: 20, // 두 번째 텍스트 크기
                      ),
                    ),
                  ],
                ),
              ),
              // 여기에 다른 내용 추가
            ],
          ),


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
          Image.asset(
            'assets/images/subIcon/threeDot.png', // 이미지 경로 (assets 폴더에 아이콘 추가)
            width: 40,
            height: 40,
          ),

          SizedBox(height: 4),
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
                  color: Colors.white, // 텍스트 색상 (예시)
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



/*
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
                    child: Text(message['text'],style: TextStyle(color: Colors.black)),
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
                  child: Text(_isRecording ? '녹음 중단하기' : '터치해서 물어보기'),
            ),
          ),
        ],
      ),
    );
  }

   */



}



/*
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

class AIScreen extends StatefulWidget {
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  // 녹음기 초기화 및 권한 체크
  Future<void> _initializeRecorder() async {
    try {
      await _recorder!.openRecorder();
      await _checkPermissions();
    } catch (e) {
      print("Failed to initialize recorder: $e");
    }
  }

  // 마이크와 저장소 권한 요청
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

  // 녹음 시작
  Future<void> _startRecording() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/flutter_sound_temp.aac';

      setState(() {
        _filePath = path;
        _isRecording = true;
      });

      print("Starting recording. File will be saved to: $_filePath");

      // 녹음 시작 (AAC 형식으로 저장)
      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,  // AAC 형식 (ADTS)으로 녹음
      );

      print("Recording started successfully");
    } catch (e) {
      print("Failed to start recording: $e");
    }
  }

  // 녹음 종료 및 파일 업로드
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
          print("File exists. Proceeding with upload.");
          await _uploadFileToFirebase(recordedFile);
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

  // Firebase Storage로 파일 업로드
  Future<void> _uploadFileToFirebase(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;

      // Firebase Storage에 user_input_audio 폴더에 파일 저장
      Reference ref = storage.ref().child('user_input_audio/$fileName.aac');
      print("Uploading file: ${file.path}");

      TaskSnapshot snapshot = await ref.putFile(file);
      print("Upload task completed with state: ${snapshot.state}");

      if (snapshot.state == TaskState.success) {
        print("File uploaded successfully to Firebase");

        // 업로드가 완료되면 로딩 화면으로 전환하여 GPT_output 버킷 모니터링 시작
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MP3FileChecker()),
        );
      } else {
        print("File upload failed with state: ${snapshot.state}");
      }
    } catch (e) {
      print("Failed to upload file: $e");
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF539262),
      /*
      appBar: AppBar(
        title: Text('AI Sound Recorder'),
      ),*/
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRecording ? 'Recording...' : 'Press the button to start recording',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}

class MP3FileChecker extends StatefulWidget {
  @override
  _MP3FileCheckerState createState() => _MP3FileCheckerState();
}

class _MP3FileCheckerState extends State<MP3FileChecker> {
  Timer? _timer;
  bool _isFileFound = false;
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  Reference? _initialLatestFileRef;

  @override
  void initState() {
    super.initState();
    _startCheckingForFile();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.closePlayer();
    super.dispose();
  }

  void _startCheckingForFile() {
    const monitoringDuration = Duration(seconds: 20);
    const interval = Duration(seconds: 1);

    _checkForMP3File(); // 초기 파일 체크

    _timer = Timer.periodic(interval, (timer) async {
      await _checkForMP3File();
    });

    Future.delayed(monitoringDuration, () {
      _timer?.cancel(); // 모니터링 중지
      if (_initialLatestFileRef != null) {
        _isFileFound = true;
        _playMP3(_initialLatestFileRef!);
      } else {
        _showTimeoutDialog();
      }
    });
  }

  Future<void> _checkForMP3File() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      ListResult result = await storage.ref('GPT_output/').listAll();

      Reference? latestFileRef;
      DateTime? latestTime;

      for (Reference ref in result.items) {
        if (ref.name.endsWith('.mp3')) {
          FullMetadata metadata = await ref.getMetadata();
          DateTime createdTime = metadata.timeCreated!;

          if (latestTime == null || createdTime.isAfter(latestTime)) {
            latestTime = createdTime;
            latestFileRef = ref;
          }
        }
      }

      if (latestFileRef != null) {
        if (_initialLatestFileRef == null) {
          _initialLatestFileRef = latestFileRef;
          print("처음 인식된 가장 최근 MP3 파일: ${latestFileRef.name}");
        } else if (_initialLatestFileRef!.name != latestFileRef.name) {
          _initialLatestFileRef = latestFileRef;
          print("더 최신 MP3 파일 발견: ${latestFileRef.name}");
        }
      }
    } catch (e) {
      print('MP3 파일을 확인하는 중 오류 발생: $e');
    }
  }

  Future<void> _playMP3(Reference fileRef) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String localPath = '${tempDir.path}/${fileRef.name}';
      File file = File(localPath);

      await fileRef.writeToFile(file);
      print("MP3 파일이 로컬 경로에 다운로드됨: $localPath");

      await _player.openPlayer();
      await _player.startPlayer(
        fromURI: file.path,
        codec: Codec.mp3,
        whenFinished: () {
          _player.closePlayer();
          print("MP3 재생 완료");
          Navigator.pop(context); // 재생이 완료되면 이전 화면으로 돌아감
        },
      );
      print("MP3 파일 재생 중: ${fileRef.name}");
    } catch (e) {
      print('MP3 재생 실패: $e');
    }
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Timeout"),
        content: Text("4초 동안 새로운 MP3 파일이 생성되지 않았습니다."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("MP3 File Checker")),
      body: Center(
        child: _isFileFound
            ? Text("새로운 MP3 파일이 발견되었고 재생 중입니다!")
            : CircularProgressIndicator(),
      ),
    );
  }
}

*/