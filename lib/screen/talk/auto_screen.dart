import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/talk/ai/ai_screen.dart'; // Import AiScreen

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  bool isAudioFinished = false; // 오디오 재생 완료 여부 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 재생 상태 변경 감지
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생 또는 종료 상태 처리
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        if (_currentIndex < _audioDetails.length - 1) {
          _nextAudio();
          _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        } else {
          // 모든 오디오가 재생된 후 상태 변경
          isAudioFinished = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() async {
    if (_audioDetails.isNotEmpty && !isAudioFinished) { // 오디오가 종료되지 않았을 경우만 재생
      await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
        isAudioFinished = false; // 오디오 재생 시 완료 상태 해제
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        // 모든 오디오가 끝났거나 >| 버튼을 눌렀을 경우
        isAudioFinished = true;
      }
    });

    // 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isAudioFinished) {
        _playAudio();
      }
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    if (!isAudioFinished) { // 오디오가 종료되지 않았을 경우만 이전 오디오로 이동
      setState(() {
        if (_currentIndex > 0) {
          _currentIndex--;
        } else {
          _currentIndex = _audioDetails.length - 1;
        }
      });

      // 오디오 재생
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playAudio();
      });
    }
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (_audioDetails.isNotEmpty && !isAudioFinished) { // 오디오가 종료되지 않았을 경우만 재생
        await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        setState(() {
          isPlaying = true;
        });
      } else {
        print('오디오 데이터가 없습니다.');
      }
    }
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  // 터치해서 AiScreen으로 이동하는 메서드
  void _navigateToAiScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AIScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 인디케이터 표시
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // 위치 조정 가능
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.green), // 녹색 화살표
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            isAudioFinished
                                ? "오디오 재생 완료"
                                : "오디오 자동 재생 중", // 오디오 재생 상태에 따라 텍스트 변경
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAudioFinished ? locationName : locationName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'HSSantokki',
                        ),
                      ),
                      if (!isAudioFinished) // 오디오가 끝나지 않았을 경우에만 버튼 표시
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous, color: Colors.white),
                              onPressed: _previousAudio,
                            ),
                            IconButton(
                              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white),
                              onPressed: _togglePlayPause,
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: Colors.white),
                              onPressed: _nextAudio,
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (!isAudioFinished)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _audioDetails.isNotEmpty
                              ? _audioDetails[_currentIndex]['audioTitle']
                              : "Unknown Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'HSSantokki',
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8),
                  if (isAudioFinished) // 오디오가 끝난 후 UI 변경
                    Column(
                      children: [
                        Text(
                          "궁금한게 있다면\n 무엇이든 물어봐요!", // 임의로 설정한 장소 이름
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'HSSantokki',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Image.asset(
                          'assets/images/subIcon/message.png', // 이미지 경로
                          width: 100, // 너비 설정
                          height: 100, // 높이 설정
                        ),
                        
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _navigateToAiScreen,
                          child: Container(
                            padding: EdgeInsets.all(12), // Optional padding
                            child: Text(
                              "터치해서 물어보기",
                              style: TextStyle(
                                color: Colors.white, // White text color
                                fontFamily: 'Pretendard.w500',
                                fontSize: 16,
                                decoration: TextDecoration.underline, // Underlined text
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                  // 스크립트 부분 스크롤 가능하게 수정
                    Container(
                      height: 60,
                      child: SingleChildScrollView(
                        child: Text(
                          _audioDetails.isNotEmpty
                              ? _audioDetails[_currentIndex]['script']
                              : "스크립트를 불러오는 중...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  if (!isAudioFinished)
                    Slider(
                      activeColor: Color(0xFFFCC8E7),
                      inactiveColor: Colors.white,
                      value: _position.inSeconds.toDouble(),
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (double value) {
                        _seekAudio(value);
                      },
                    ),
                  if (!isAudioFinished)
                    Text(
                      '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/talk/ai/ai_screen.dart'; // Import AiScreen

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  bool isAudioFinished = false; // 오디오 재생 완료 여부 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 재생 상태 변경 감지
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생 또는 종료 상태 처리
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        if (_currentIndex < _audioDetails.length - 1) {
          _nextAudio();
          _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        } else {
          // 모든 오디오가 재생된 후 상태 변경
          isAudioFinished = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() async {
    if (_audioDetails.isNotEmpty) {
      await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
        isAudioFinished = false; // 오디오 재생 시 완료 상태 해제
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        // 모든 오디오가 끝났거나 >| 버튼을 눌렀을 경우
        isAudioFinished = true;
      }
    });

    // 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isAudioFinished) {
        _playAudio();
      }
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (_audioDetails.isNotEmpty) {
        await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        setState(() {
          isPlaying = true;
        });
      } else {
        print('오디오 데이터가 없습니다.');
      }
    }
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  // 터치해서 AiScreen으로 이동하는 메서드
  void _navigateToAiScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 인디케이터 표시
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // 위치 조정 가능
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.green), // 녹색 화살표
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            isAudioFinished
                                ? "오디오 재생 완료"
                                : "오디오 자동 재생 중", // 오디오 재생 상태에 따라 텍스트 변경
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAudioFinished ? "토키토키님의 발견경에 맞춰가고 있어요!" : locationName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'HSSantokki',
                        ),
                      ),
                      if (!isAudioFinished) // 오디오가 끝나지 않았을 경우에만 버튼 표시
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous, color: Colors.white),
                              onPressed: _previousAudio,
                            ),
                            IconButton(
                              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white),
                              onPressed: _togglePlayPause,
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: Colors.white),
                              onPressed: _nextAudio,
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (!isAudioFinished)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _audioDetails.isNotEmpty
                              ? _audioDetails[_currentIndex]['audioTitle']
                              : "Unknown Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'HSSantokki',
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8),
                  if (isAudioFinished) // 오디오가 끝난 후 UI 변경
                    Column(
                      children: [
                        Text(
                          "감천문화마을", // 임의로 설정한 장소 이름
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'HSSantokki',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "궁금한게 있다면 무엇이든 물어보세요!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _navigateToAiScreen,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "터치해서 물어보기",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                  // 스크립트 부분 스크롤 가능하게 수정
                    Container(
                      height: 60,
                      child: SingleChildScrollView(
                        child: Text(
                          _audioDetails.isNotEmpty
                              ? _audioDetails[_currentIndex]['script']
                              : "스크립트를 불러오는 중...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  if (!isAudioFinished)
                    Slider(
                      activeColor: Color(0xFFFCC8E7),
                      inactiveColor: Colors.white,
                      value: _position.inSeconds.toDouble(),
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (double value) {
                        _seekAudio(value);
                      },
                    ),
                  if (!isAudioFinished)
                    Text(
                      '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/talk/ai/ai_screen.dart'; // Import AiScreen

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  bool isAudioFinished = false; // 오디오 재생 완료 여부 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 재생 상태 변경 감지
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생 또는 종료 상태 처리
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        if (_currentIndex < _audioDetails.length - 1) {
          _nextAudio();
          _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        } else {
          // 모든 오디오가 재생된 후 상태 변경
          isAudioFinished = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() async {
    if (_audioDetails.isNotEmpty) {
      await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
        isAudioFinished = false; // 오디오 재생 시 완료 상태 해제
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        // 모든 오디오가 끝나면 완료 상태로 변경
        isAudioFinished = true;
      }
    });

    // 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (_audioDetails.isNotEmpty) {
        await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        setState(() {
          isPlaying = true;
        });
      } else {
        print('오디오 데이터가 없습니다.');
      }
    }
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  // 터치해서 AiScreen으로 이동하는 메서드
  void _navigateToAiScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 인디케이터 표시
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // 위치 조정 가능
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.green), // 녹색 화살표
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            isAudioFinished
                                ? "오디오 재생 완료"
                                : "오디오 자동 재생 중", // 오디오 재생 상태에 따라 텍스트 변경
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAudioFinished ? "토키토키님의 발견경에 맞춰가고 있어요!" : locationName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'HSSantokki',
                        ),
                      ),
                      if (!isAudioFinished) // 오디오가 끝나지 않았을 경우에만 버튼 표시
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous, color: Colors.white),
                              onPressed: _previousAudio,
                            ),
                            IconButton(
                              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white),
                              onPressed: _togglePlayPause,
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: Colors.white),
                              onPressed: _nextAudio,
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (!isAudioFinished)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _audioDetails.isNotEmpty
                              ? _audioDetails[_currentIndex]['audioTitle']
                              : "Unknown Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'HSSantokki',
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8),
                  if (isAudioFinished) // 오디오가 끝난 후 UI 변경
                    Column(
                      children: [
                        Text(
                          "감천문화마을", // 임의로 설정한 장소 이름
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'HSSantokki',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "궁금한게 있다면 무엇이든 물어보세요!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _navigateToAiScreen,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "터치해서 물어보기",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                  // 스크립트 부분 스크롤 가능하게 수정
                    Container(
                      height: 60,
                      child: SingleChildScrollView(
                        child: Text(
                          _audioDetails.isNotEmpty
                              ? _audioDetails[_currentIndex]['script']
                              : "스크립트를 불러오는 중...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  if (!isAudioFinished)
                    Slider(
                      activeColor: Color(0xFFFCC8E7),
                      inactiveColor: Colors.white,
                      value: _position.inSeconds.toDouble(),
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (double value) {
                        _seekAudio(value);
                      },
                    ),
                  if (!isAudioFinished)
                    Text(
                      '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/talk/ai/ai_screen.dart'; // Import AiScreen

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 재생 상태 변경 감지
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        if (_currentIndex < _audioDetails.length - 1) {
          _nextAudio();
          _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        } else {
          // 모든 오디오가 재생된 후 AiScreen으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AiScreen(), // AiScreen으로 이동
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() async {
    if (_audioDetails.isNotEmpty) {
      await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        // 마지막 오디오에서 다음 버튼을 누를 시 AiScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AiScreen(), // AiScreen으로 이동
          ),
        );
      }
    });

    // 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (_audioDetails.isNotEmpty) {
        await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        setState(() {
          isPlaying = true;
        });
      } else {
        print('오디오 데이터가 없습니다.');
      }
    }
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 인디케이터 표시
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // 위치 조정 가능
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.green), // 녹색 화살표
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locationName, // API에서 가져온 locationName 사용
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'HSSantokki',
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'HSSantokki',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60,
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/


/////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/talk/ai/ai_screen.dart'; // Import AiScreen

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 재생 상태 변경 감지
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        if (_currentIndex < _audioDetails.length - 1) {
          _nextAudio();
          _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        } else {
          // 모든 오디오가 재생된 후 ai_screen으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AiScreen(), // AiScreen으로 이동
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() async {
    if (_audioDetails.isNotEmpty) {
      await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() async {
    if (isPlaying) {
      // 오디오 일시정지
      await _audioPlayer.pause(); // 비동기 호출
      setState(() {
        isPlaying = false;
      });
    } else {
      // 오디오 재생
      if (_audioDetails.isNotEmpty) {
        await _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl'])); // 비동기 호출
        setState(() {
          isPlaying = true;
        });
      } else {
        print('오디오 데이터가 없습니다.');
      }
    }
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // You can adjust the position as necessary
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)), // Navigate to TalkScreen
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.green), // Green back arrow
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locationName, // API에서 가져온 locationName 사용
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'HSSantokki',
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'HSSantokki',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

/////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/talk/ai/ai_screen.dart'; // Import AiScreen

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        if (_currentIndex < _audioDetails.length - 1) {
          _nextAudio();
          _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
        } else {
          // 모든 오디오가 재생된 후 ai_screen으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AiScreen(), // AiScreen으로 이동
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // You can adjust the position as necessary
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)), // Navigate to TalkScreen
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                /*
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3), // Semi-transparent background
                ),
                */
                child: Icon(Icons.arrow_back, color: Colors.green), // Green back arrow
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // API로 가져온 locationName 출력
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locationName, // API에서 가져온 locationName 사용
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/


/////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // You can adjust the position as necessary
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)), // Navigate to TalkScreen
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                /*
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3), // Semi-transparent background
                ),
                */
                child: Icon(Icons.arrow_back, color: Colors.green), // Green back arrow
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // API로 가져온 locationName 출력
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locationName, // API에서 가져온 locationName 사용
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'talk_screen.dart'; // Import TalkScreen
import 'package:triptalk/screen/talk/talk_screen.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TalkScreen(token: widget.token)), // Navigate to TalkScreen
            );
          },
        ),
      ),
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // API로 가져온 locationName 출력
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locationName, // API에서 가져온 locationName 사용
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가
  String locationName = ''; // locationName 변수 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // locationName을 API 데이터에서 가져옴
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // API로 가져온 locationName 출력
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locationName, // API에서 가져온 locationName 사용
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName; // locationName을 추가

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = '', required this.locationName});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // locationName 출력
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.locationName, // 여기서 locationName 출력
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}

*/
//////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // "여행 루트에 맞춰 가주세요!" 텍스트를 위로 이동
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "여행 루트에 맞춰 가주세요!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}

*/

/////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "여행 루트에 맞춰 가주세요!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 스크립트 부분 스크롤 가능하게 수정
                  Container(
                    height: 60, // 제한된 높이 설정
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시에도 로딩 상태 해제
      });
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading // 로딩 중일 때 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "여행 루트에 맞춰 가주세요!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _audioDetails.isNotEmpty
                              ? _audioDetails[_currentIndex]['script']
                              : "스크립트를 불러오는 중...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너

          // 하단에 초록색 배경을 입힌 컨테이너를 첫 번째 화면처럼 수정
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 변경
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 오디오 재생 상태 표시 아이콘 및 텍스트
                      Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFFFCC8E7), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "오디오 자동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "여행 루트에 맞춰 가주세요!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _previousAudio,
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _nextAudio,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['audioTitle']
                            : "Unknown Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "현재 읽고 있는 텍스트 파일. 지금 오디오 재생 중인 건 불투명하게 지나갔거나, 아직 읽히기 전인 것은 투명도를 낮춰서 표현하기",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 오디오 스크롤바
                  Slider(
                    activeColor: Color(0xFFFCC8E7),
                    inactiveColor: Colors.white,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _seekAudio(value);
                    },
                  ),
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}

*/

/*

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          // 하단에 초록색 배경을 입힌 컨테이너
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.green[100],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 오디오 재생/일시정지, 이전/다음 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous, color: Colors.black87),
                        onPressed: () {
                          _previousAudio();
                        },
                      ),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black87),
                        onPressed: () {
                          _togglePlayPause();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next, color: Colors.black87),
                        onPressed: () {
                          _nextAudio();
                        },
                      ),
                    ],
                  ),
                  // 오디오 스크립트 및 제목
                  if (_audioDetails.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _audioDetails[_currentIndex]['audioTitle'],
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 100,
                          child: SingleChildScrollView(
                            child: Text(
                              _audioDetails[_currentIndex]['script'],
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  // 오디오 스크롤바 및 현재 재생 시간
                  if (_audioDetails.isNotEmpty)
                    Column(
                      children: [
                        Slider(
                          activeColor: Colors.pink,
                          inactiveColor: Colors.white,
                          value: _position.inSeconds.toDouble(),
                          min: 0.0,
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (double value) {
                            _seekAudio(value); // 오디오 재생 위치 변경
                          },
                        ),
                        Text(
                          '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

/////

/*
//하단바 배경색 안입혀진 버전
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 현재 선택된 오디오 재생
  void _playAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(UrlSource(_audioDetails[_currentIndex]['audioUrl']));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Slider 값 변경 시 오디오 재생 위치 변경
  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // 오디오 재생/일시정지, 이전/다음 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Colors.black87),
                      onPressed: () {
                        _previousAudio();
                      },
                    ),
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black87),
                      onPressed: () {
                        _togglePlayPause();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Colors.black87),
                      onPressed: () {
                        _nextAudio();
                      },
                    ),
                  ],
                ),
                // 오디오 스크립트 및 제목
                if (_audioDetails.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _audioDetails[_currentIndex]['audioTitle'],
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 100,
                        child: SingleChildScrollView(
                          child: Text(
                            _audioDetails[_currentIndex]['script'],
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                // 오디오 스크롤바 및 현재 재생 시간
                if (_audioDetails.isNotEmpty)
                  Column(
                    children: [
                      Slider(
                        activeColor: Colors.pink,
                        inactiveColor: Colors.white,
                        value: _position.inSeconds.toDouble(),
                        min: 0.0,
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (double value) {
                          _seekAudio(value); // 오디오 재생 위치 변경
                        },
                      ),
                      Text(
                        '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 오디오 테스트 버튼 클릭 시 실행
  void _playTestAudio() {
    if (_audioDetails.isNotEmpty) {
      _audioPlayer.play(_audioDetails[0]['audioUrl']); // 첫 번째 오디오 URL을 재생
      setState(() {
        isPlaying = true;
      });
    } else {
      print('오디오 데이터가 없습니다.');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 현재 오디오 재생
  void _playAudio() {
    _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
    setState(() {
      isPlaying = true;
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showBottomSheet(context);
                  },
                  child: Text('안내 시작', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _playTestAudio();
                  },
                  child: Text('오디오 URL test', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildBottomSheetContent(setState);
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'],
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'],
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 스크롤바 및 컨트롤 버튼
          Slider(
            activeColor: Colors.pink,
            inactiveColor: Colors.white,
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _previousAudio();
                  });
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87),
                onPressed: () {
                  _togglePlayPause();
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _nextAudio();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

///////////////


//정상코드
/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });

    // 다음 프레임에서 오디오를 재생하도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  // 현재 오디오 재생
  void _playAudio() {
    _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
    setState(() {
      isPlaying = true;
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              child: Text('안내 시작', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildBottomSheetContent(setState);
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'],
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'],
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 스크롤바 및 컨트롤 버튼
          Slider(
            activeColor: Colors.pink,
            inactiveColor: Colors.white,
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _previousAudio();
                  });
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87),
                onPressed: () {
                  _togglePlayPause();
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _nextAudio();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 다음 오디오로 넘어가기
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _playAudio();
    });
  }

  // 이전 오디오로 돌아가기
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
      _playAudio();
    });
  }

  // 현재 오디오 재생
  void _playAudio() {
    _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
    setState(() {
      isPlaying = true;
    });
  }

  // 오디오 일시정지/재생 토글
  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _playAudio();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              child: Text('안내 시작', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildBottomSheetContent(setState);
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'],
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'],
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 스크롤바 및 컨트롤 버튼
          Slider(
            activeColor: Colors.pink,
            inactiveColor: Colors.white,
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _previousAudio();
                  });
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87),
                onPressed: () {
                  _togglePlayPause();
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _nextAudio();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

///////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // 오디오가 끝나면 자동으로 다음 오디오 재생
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _nextAudio();
        _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              child: Text('안내 시작', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildBottomSheetContent(setState);
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'],
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'],
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 스크롤바 및 컨트롤 버튼
          Slider(
            activeColor: Colors.pink,
            inactiveColor: Colors.white,
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _previousAudio();
                    _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
                  });
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87),
                onPressed: () async {
                  if (isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                    await _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
                  }
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _nextAudio();
                    _audioPlayer.play(_audioDetails[_currentIndex]['audioUrl']);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

*/

////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // Stream을 사용하여 오디오 진행 시간 및 재생 길이를 추적
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              child: Text('안내 시작', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildBottomSheetContent(setState);
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'],
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'],
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 스크롤바 및 컨트롤 버튼
          Slider(
            activeColor: Colors.pink,
            inactiveColor: Colors.white,
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _previousAudio();
                  });
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87),
                onPressed: () async {
                  if (isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                    await _audioPlayer.play(
                        _audioDetails[_currentIndex]['audioUrl']);
                  }
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _nextAudio();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

/////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AutoGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchLocationData();

    // 오디오 재생 시간 및 진행 상태 업데이트
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
      });
    } else {
      print('Failed to load location data');
    }
  }

  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _audioDetails.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
                onPageFinished: (String url) {
                  if (_locationData != null) {
                    _controller.runJavascript(
                        'updateLocationData(${jsonEncode(_locationData)})');
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              child: Text('안내 시작', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildBottomSheetContent(setState);
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'],
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'],
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 스크롤바 및 컨트롤 버튼
          Slider(
            activeColor: Colors.pink,
            inactiveColor: Colors.white,
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _previousAudio();
                  });
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87),
                onPressed: () async {
                  if (isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                    await _audioPlayer.play(
                        _audioDetails[_currentIndex]['audioUrl']);
                  }
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _nextAudio();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

/////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AutoGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0; // 현재 표시 중인 audioDetails의 인덱스
  List<dynamic> _audioDetails = []; // audioDetails를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _determinePosition();  // 현재 위치를 가져오는 함수 호출
    _fetchLocationData();  // API 호출 함수 호출
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      // WebView에 현재 위치 전달
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})'
      );
    }
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];  // audioDetails 배열 저장
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 다음 audioDetails 항목으로 이동
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++; // 인덱스를 증가시켜 다음 항목으로 이동
      } else {
        _currentIndex = 0; // 마지막 항목이면 처음으로 돌아감
      }
    });
  }

  // 이전 audioDetails 항목으로 이동
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--; // 인덱스를 감소시켜 이전 항목으로 이동
      } else {
        _currentIndex = _audioDetails.length - 1; // 처음 항목이면 마지막으로 이동
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // 지도를 화면 전체에 꽉 채움
              Positioned.fill(
                child: Container(
                  child: WebView(
                    initialUrl: 'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                    onPageFinished: (String url) {
                      if (_locationData != null) {
                        // HTML 페이지가 완전히 로드된 후에 JavaScript 함수 호출
                        _controller.runJavascript(
                            'updateLocationData(${jsonEncode(_locationData)})'
                        );
                      }
                    },
                  ),
                ),
              ),
              // '안내 시작' 버튼을 화면 하단에 고정
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // '안내 시작' 버튼이 눌렸을 때 showBottomSheet 호출
                    _showBottomSheet(context);
                  },
                  child: Text('안내 시작',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]
        )
    );
  }

  // HTML 파일을 assets에서 불러와 WebView에 로드하는 함수
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  // 하단 시트를 띄우는 함수
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildBottomSheetContent(setState);
          },
        );
      },
    );
  }

  // 하단 시트의 내용 구성 (스크롤바 추가)
  Widget _buildBottomSheetContent(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'], // 현재 오디오 제목 표시
                  style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // 스크롤 가능한 영역 추가
                Container(
                  height: 100, // 스크롤바가 있는 컨테이너의 높이 설정
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'], // 현재 오디오 스크립트 표시
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 컨트롤 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _previousAudio(); // 상태를 변경하면서 UI 갱신
                  });
                }, // 이전 버튼 클릭 시 실행
              ),
              IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.black87),
                onPressed: () {
                  // 재생 버튼 동작 (오디오 재생 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.pause, color: Colors.black87),
                onPressed: () {
                  // 일시정지 버튼 동작 (오디오 일시정지 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _nextAudio(); // 상태를 변경하면서 UI 갱신
                  });
                }, // 다음 버튼 클릭 시 실행
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

//////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AutoGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0; // 현재 표시 중인 audioDetails의 인덱스
  List<dynamic> _audioDetails = []; // audioDetails를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _determinePosition();  // 현재 위치를 가져오는 함수 호출
    _fetchLocationData();  // API 호출 함수 호출
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      // WebView에 현재 위치 전달
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})'
      );
    }
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];  // audioDetails 배열 저장
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 다음 audioDetails 항목으로 이동
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++; // 인덱스를 증가시켜 다음 항목으로 이동
      } else {
        _currentIndex = 0; // 마지막 항목이면 처음으로 돌아감
      }
    });
  }

  // 이전 audioDetails 항목으로 이동
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--; // 인덱스를 감소시켜 이전 항목으로 이동
      } else {
        _currentIndex = _audioDetails.length - 1; // 처음 항목이면 마지막으로 이동
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // 지도를 화면 전체에 꽉 채움
              Positioned.fill(
                child: Container(
                  child: WebView(
                    initialUrl: 'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                    onPageFinished: (String url) {
                      if (_locationData != null) {
                        // HTML 페이지가 완전히 로드된 후에 JavaScript 함수 호출
                        _controller.runJavascript(
                            'updateLocationData(${jsonEncode(_locationData)})'
                        );
                      }
                    },
                  ),
                ),
              ),
              // '안내 시작' 버튼을 화면 하단에 고정
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // '안내 시작' 버튼이 눌렸을 때 showBottomSheet 호출
                    _showBottomSheet(context);
                  },
                  child: Text('안내 시작',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]
        )
    );
  }

  // HTML 파일을 assets에서 불러와 WebView에 로드하는 함수
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  // 하단 시트를 띄우는 함수
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 하단 시트의 내용 구성 (스크롤바 추가)
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'], // 현재 오디오 제목 표시
                  style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // 스크롤 가능한 영역 추가
                Container(
                  height: 100, // 스크롤바가 있는 컨테이너의 높이 설정
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'], // 현재 오디오 스크립트 표시
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 컨트롤 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: _previousAudio, // 이전 버튼 클릭 시 실행
              ),
              IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.black87),
                onPressed: () {
                  // 재생 버튼 동작 (오디오 재생 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.pause, color: Colors.black87),
                onPressed: () {
                  // 일시정지 버튼 동작 (오디오 일시정지 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: _nextAudio, // 다음 버튼 클릭 시 실행
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AutoGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0; // 현재 표시 중인 audioDetails의 인덱스
  List<dynamic> _audioDetails = []; // audioDetails를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _determinePosition();  // 현재 위치를 가져오는 함수 호출
    _fetchLocationData();  // API 호출 함수 호출
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      // WebView에 현재 위치 전달
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})'
      );
    }
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];  // audioDetails 배열 저장
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 다음 audioDetails 항목으로 이동
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++; // 인덱스를 증가시켜 다음 항목으로 이동
      } else {
        _currentIndex = 0; // 마지막 항목이면 처음으로 돌아감
      }
    });
  }

  // 이전 audioDetails 항목으로 이동
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--; // 인덱스를 감소시켜 이전 항목으로 이동
      } else {
        _currentIndex = _audioDetails.length - 1; // 처음 항목이면 마지막으로 이동
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // 지도를 화면 전체에 꽉 채움
              Positioned.fill(
                child: Container(
                  child: WebView(
                    initialUrl: 'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                    onPageFinished: (String url) {
                      if (_locationData != null) {
                        // HTML 페이지가 완전히 로드된 후에 JavaScript 함수 호출
                        _controller.runJavascript(
                            'updateLocationData(${jsonEncode(_locationData)})'
                        );
                      }
                    },
                  ),
                ),
              ),
              // '안내 시작' 버튼을 화면 하단에 고정
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // '안내 시작' 버튼이 눌렸을 때 showBottomSheet 호출
                    _showBottomSheet(context);
                  },
                  child: Text('안내 시작',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]
        )
    );
  }

  // HTML 파일을 assets에서 불러와 WebView에 로드하는 함수
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  // 하단 시트를 띄우는 함수
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 하단 시트의 내용 구성 (스크롤바 추가)
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'], // 현재 오디오 제목 표시
                  style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // 스크롤 가능한 영역 추가
                Container(
                  height: 100, // 스크롤바가 있는 컨테이너의 높이 설정
                  child: SingleChildScrollView(
                    child: Text(
                      _audioDetails[_currentIndex]['script'], // 현재 오디오 스크립트 표시
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 컨트롤 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: _previousAudio, // 이전 버튼 클릭 시 실행
              ),
              IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.black87),
                onPressed: () {
                  // 재생 버튼 동작 (오디오 재생 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.pause, color: Colors.black87),
                onPressed: () {
                  // 일시정지 버튼 동작 (오디오 일시정지 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: _nextAudio, // 다음 버튼 클릭 시 실행
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/


/////////


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AutoGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0; // 현재 표시 중인 audioDetails의 인덱스
  List<dynamic> _audioDetails = []; // audioDetails를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _determinePosition();  // 현재 위치를 가져오는 함수 호출
    _fetchLocationData();  // API 호출 함수 호출
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      // WebView에 현재 위치 전달
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})'
      );
    }
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];  // audioDetails 배열 저장
      });
    } else {
      print('Failed to load location data');
    }
  }

  // 다음 audioDetails 항목으로 이동
  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++; // 인덱스를 증가시켜 다음 항목으로 이동
      } else {
        _currentIndex = 0; // 마지막 항목이면 처음으로 돌아감
      }
    });
  }

  // 이전 audioDetails 항목으로 이동
  void _previousAudio() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--; // 인덱스를 감소시켜 이전 항목으로 이동
      } else {
        _currentIndex = _audioDetails.length - 1; // 처음 항목이면 마지막으로 이동
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // 지도를 화면 전체에 꽉 채움
              Positioned.fill(
                child: Container(
                  child: WebView(
                    initialUrl: 'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                    onPageFinished: (String url) {
                      if (_locationData != null) {
                        // HTML 페이지가 완전히 로드된 후에 JavaScript 함수 호출
                        _controller.runJavascript(
                            'updateLocationData(${jsonEncode(_locationData)})'
                        );
                      }
                    },
                  ),
                ),
              ),
              // '안내 시작' 버튼을 화면 하단에 고정
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // '안내 시작' 버튼이 눌렸을 때 showBottomSheet 호출
                    _showBottomSheet(context);
                  },
                  child: Text('안내 시작',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]
        )
    );
  }

  // HTML 파일을 assets에서 불러와 WebView에 로드하는 함수
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  // 하단 시트를 띄우는 함수
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 하단 시트의 내용 구성
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_audioDetails.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioDetails[_currentIndex]['audioTitle'], // 현재 오디오 제목 표시
                  style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  _audioDetails[_currentIndex]['script'], // 현재 오디오 스크립트 표시
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(height: 16),
              ],
            ),
          // 오디오 컨트롤 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: _previousAudio, // 이전 버튼 클릭 시 실행
              ),
              IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.black87),
                onPressed: () {
                  // 재생 버튼 동작 (오디오 재생 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.pause, color: Colors.black87),
                onPressed: () {
                  // 일시정지 버튼 동작 (오디오 일시정지 코드 추가 가능)
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: _nextAudio, // 다음 버튼 클릭 시 실행
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

/////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AutoGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  // 생성자에서 검색어와 토큰 받기
  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _determinePosition();  // 현재 위치를 가져오는 함수 호출
    _fetchLocationData();  // API 호출 함수 호출
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      // WebView에 현재 위치 전달
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})'
      );
    }
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;  // 받아온 데이터를 저장
        print("data : " + jsonEncode(data));
        print(widget.tlid);
      });

      // if (_controller != null && _locationData != null) {
      //   // WebView에 API 데이터 전달
      //   _controller.runJavascript(
      //     'updateLocationData(${jsonEncode(_locationData)})'
      //   );
      // }
    } else {
      print('Failed to load location data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // 지도를 화면 전체에 꽉 채움
              Positioned.fill(
                child: Container(
                  child: WebView(
                    initialUrl: 'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                    onPageFinished: (String url) {
                      if (_locationData != null) {
                        // HTML 페이지가 완전히 로드된 후에 JavaScript 함수 호출
                        _controller.runJavascript(
                            'updateLocationData(${jsonEncode(_locationData)})'
                        );
                      }
                    },
                  ),
                ),
              ),
              // '안내 시작' 버튼을 화면 하단에 고정
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // '안내 시작' 버튼이 눌렸을 때 showBottomSheet 호출
                    _showBottomSheet(context);
                  },
                  child: Text('안내 시작',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]
        )
    );
  }

  // HTML 파일을 assets에서 불러와 WebView에 로드하는 함수
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  // 하단 시트를 띄우는 함수
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 하단 시트의 내용 구성
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "오디오 자동 재생 중",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            "여행 루트에 맞춰 가주세요!",
            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            "감천문화마을",
            style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "현재 읽고 있는 텍스트 파일. 지금 오디오 재생 중인 건 블루투명하게 지나갔거나, 아직 읽히기 전인 것은 투명도를 낮춰서 표현하기",
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 16),
          // 오디오 컨트롤 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black87),
                onPressed: () {
                  // 이전 버튼 동작
                },
              ),
              IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.black87),
                onPressed: () {
                  // 재생 버튼 동작
                },
              ),
              IconButton(
                icon: Icon(Icons.pause, color: Colors.black87),
                onPressed: () {
                  // 일시정지 버튼 동작
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black87),
                onPressed: () {
                  // 다음 버튼 동작
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

*/


///////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AutoGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  // 생성자에서 검색어와 토큰 받기
  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _determinePosition();  // 현재 위치를 가져오는 함수 호출
    _fetchLocationData();  // API 호출 함수 호출
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      // WebView에 현재 위치 전달
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})'
      );
    }
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;  // 받아온 데이터를 저장
        print("data : " + jsonEncode(data));
        print(widget.tlid);
      });

      // if (_controller != null && _locationData != null) {
      //   // WebView에 API 데이터 전달
      //   _controller.runJavascript(
      //     'updateLocationData(${jsonEncode(_locationData)})'
      //   );
      // }
    } else {
      print('Failed to load location data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // 지도를 화면 전체에 꽉 채움
              Positioned.fill(
                child: Container(
                  child: WebView(
                    initialUrl: 'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                    onPageFinished: (String url) {
                      if (_locationData != null) {
                        // HTML 페이지가 완전히 로드된 후에 JavaScript 함수 호출
                        _controller.runJavascript(
                            'updateLocationData(${jsonEncode(_locationData)})'
                        );
                      }
                    },
                  ),
                ),
              ),
              // '안내 시작' 버튼을 화면 하단에 고정
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // '안내 시작' 버튼이 눌렸을 때 실행할 코드 추가
                    print('안내 시작 버튼이 눌렸습니다');
                    // 필요에 따라 WebView에 JavaScript 실행 또는 화면 이동 코드 추가 가능
                  },
                  child: Text('안내 시작',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]
        )
    );
  }

  // HTML 파일을 assets에서 불러와 WebView에 로드하는 함수
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

////////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AutoGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  // 생성자에서 검색어와 토큰 받기
  AutoGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _AutoGuideScreenState createState() => _AutoGuideScreenState();
}

class _AutoGuideScreenState extends State<AutoGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _determinePosition();  // 현재 위치를 가져오는 함수 호출
    _fetchLocationData();  // API 호출 함수 호출
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      // WebView에 현재 위치 전달
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})'
      );
    }
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/auto?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;  // 받아온 데이터를 저장
        print("data : " + jsonEncode(data));
        print(widget.tlid);
      });

      // if (_controller != null && _locationData != null) {
      //   // WebView에 API 데이터 전달
      //   _controller.runJavascript(
      //     'updateLocationData(${jsonEncode(_locationData)})'
      //   );
      // }
    } else {
      print('Failed to load location data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // 지도를 화면 전체에 꽉 채움
              Positioned.fill(
                child: Container(
                  child: WebView(
                    initialUrl: 'about:blank',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                    onPageFinished: (String url) {
                      if (_locationData != null) {
                        // HTML 페이지가 완전히 로드된 후에 JavaScript 함수 호출
                        _controller.runJavascript(
                            'updateLocationData(${jsonEncode(_locationData)})'
                        );
                      }
                    },
                  ),
                ),
              )
            ]
        )
    );
  }

  // HTML 파일을 assets에서 불러와 WebView에 로드하는 함수
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_auto.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/