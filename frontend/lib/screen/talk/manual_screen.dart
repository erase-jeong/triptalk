import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:triptalk/screen/talk/talk_screen.dart';

class ManualGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  ManualGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  Map<String, dynamic>? _locationData;
  int _currentIndex = 0;
  List<dynamic> _audioDetails = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isLoading = true; // 데이터 로딩 상태 추가
  String locationName = ''; // 장소 이름 변수 추가

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
          // 모든 오디오가 끝나면 TalkScreen으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TalkScreen(token: widget.token),
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

    // 위치 정보가 있을 경우 지도에 표시
    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/manual?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // 인증 토큰 필요
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _audioDetails = data['audioDetails'];
        locationName = data['locationName']; // 장소 이름 가져오기
        isLoading = false; // 데이터 로딩 완료
      });
    } else {
      print('Failed to load location data');
      setState(() {
        isLoading = false; // 데이터 로딩 실패 시 로딩 상태 해제
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
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중일 때 인디케이터 표시
          : Stack(
        children: [
          Positioned.fill(
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
          // 커스텀 백 버튼 (앱바 대신 상단에 화살표만 남김)
          Positioned(
            top: 40, // 위치 조정 가능
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TalkScreen(token: widget.token),
                  ),
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
                color: Color(0xFF539262), // 하단바 배경색을 짙은 초록색으로 설정
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
                            "오디오 수동 재생 중",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Pretendard',),
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
                        locationName, // API에서 가져온 장소 이름 출력
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'HSSantokki',
                          fontSize: 30,
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
                  // 스크립트 표시
                  Container(
                    height: 60,
                    child: SingleChildScrollView(
                      child: Text(
                        _audioDetails.isNotEmpty
                            ? _audioDetails[_currentIndex]['script']
                            : "스크립트를 불러오는 중...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // 오디오 재생 시간 및 스크롤바
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
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_manual.html');
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
import 'package:triptalk/screen/talk/talk_screen.dart';

class ManualGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  ManualGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
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
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
    setState(() {
      _currentPosition = position;
    });

    if (_controller != null && _currentPosition != null) {
      _controller.runJavascript(
          'updateMap(${_currentPosition!.latitude}, ${_currentPosition!
              .longitude})');
    }
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/manual?tid=${widget
          .tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // 필요한 경우 인증 토큰 추가
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
          // 하단에 오디오 컨트롤 및 스크립트 표시
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
                  // 오디오 제목 및 스크립트
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
                  // 오디오 재생 시간 및 스크롤바
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
                            _seekAudio(value);
                          },
                        ),
                        Text(
                          '${_position.inMinutes}:${(_position.inSeconds % 60)
                              .toString()
                              .padLeft(2, '0')} / ${_duration
                              .inMinutes}:${(_duration.inSeconds % 60)
                              .toString()
                              .padLeft(2, '0')}',
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


  /*
  void _loadHtmlFromAssets() async {
    String fileText =
    await DefaultAssetBundle.of(context).loadString('assets/kakao_map_manual.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context).loadString(
        'assets/kakao_map_manual.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());

    // Flutter에서 _locationData를 지도에 전달
    if (_locationData != null) {
      _controller.runJavascript(
          'updateLocationData(${jsonEncode(_locationData)})'
      );
    }
  }
}
*/

/////////////////////////

//Location Name 이랑 audio title 들 출력
/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManualGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  ManualGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  Map<String, dynamic>? _locationData;
  List<dynamic> _audioDetails = [];
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _fetchLocationData();
  }

  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/manual?tid=${widget.tid}&tlid=${widget.tlid}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // 추가적인 인증 헤더가 필요하면 여기서 추가
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;
        _locationName = data['locationName']; // locationName 추출
        _audioDetails = data['audioDetails']; // audioDetails 추출
      });
    } else {
      print('Failed to load location data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Guide'),
      ),
      body: _locationData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // locationName 출력
            if (_locationName != null)
              Text(
                'Location Name: $_locationName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 16),

            // audioTitle들 출력
            Expanded(
              child: ListView.builder(
                itemCount: _audioDetails.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _audioDetails[index]['audioTitle'],
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

class ManualGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  ManualGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
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
      Uri.parse('https://triptalk.store/v1/locations-audio/manual?tid=${widget.tid}&tlid=${widget.tlid}'),
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

  void _nextAudio() {
    setState(() {
      if (_currentIndex < _audioDetails.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.green[100],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                            _seekAudio(value);
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class ManualGuideScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;

  ManualGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
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
      Uri.parse('https://triptalk.store/v1/locations-audio/manual?tid=${widget.tid}&tlid=${widget.tlid}'),
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


///////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class ManualGuideScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid;
  final String tlid;

  // 생성자에서 검색어와 토큰 받기
  ManualGuideScreen({required this.token, this.tid = '', this.tlid = ''});

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  late WebViewController _controller;
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _fetchLocationData();  // API 호출 함수 호출
  }

  // API 호출 및 데이터 가져오기
  Future<void> _fetchLocationData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/locations-audio/manual?tid=${widget.tid}&tlid=${widget.tlid}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _locationData = data;  // 받아온 데이터를 저장
        print("data : " + jsonEncode(data));
      });
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
    String fileText = await DefaultAssetBundle.of(context).loadString('assets/kakao_map_manual.html');
    _controller.loadUrl(Uri.dataFromString(
      fileText,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
*/