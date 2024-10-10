/*
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ManualGuideScreen extends StatefulWidget {
  const ManualGuideScreen({Key? key}) : super(key: key);

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  */
  // 오디오 전체 길이
/*
  Duration _position = Duration.zero;  // 현재 재생 위치
  bool isPlaying = false;  // 현재 재생 상태 확인
  String currentTrack = '코스1 - 들었다놨다.mp3'; // 현재 트랙 이름
  String currentAudioFile = 'audio/daybreak.mp3'; // 현재 음원 파일

  @override
  void initState() {
    super.initState();

    // 오디오 전체 길이 변경 시 처리
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    // 현재 재생 위치 변경 시 처리
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

  // 오디오 재생 및 일시정지 함수
  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource(currentAudioFile));
    }
    setState(() {
      isPlaying = !isPlaying;  // 상태를 반전시킴
    });
  }

  // 오디오 중지 함수
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
      isPlaying = false;
    });
  }

  // 슬라이더 위치를 변경할 때 호출
  void _seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  // 다음 트랙으로 변경하는 함수
  Future<void> _nextTrack() async {
    setState(() {
      currentTrack = '코스2-Love Me Like You Do.mp3'; // 텍스트 변경
      currentAudioFile = 'audio/Love Me Like You Do.mp3'; // 새로운 음원 파일
    });
    await _stopAudio(); // 현재 음원 중지
    await _audioPlayer.play(AssetSource(currentAudioFile)); // 새로운 음원 재생
    setState(() {
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수동 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '감천문화마을',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Adds space between the title and subtitle
            Text(
              currentTrack, // 현재 트랙 제목
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,  // You can adjust this color based on the screenshot you shared
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 24), // Adds space between subtitle and slider
            Slider(
              min: 0,
              max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
              value: _position.inSeconds.toDouble(),
              onChanged: (double value) {
                // 슬라이더가 움직일 때마다 위치를 업데이트
                setState(() {
                  _position = Duration(seconds: value.toInt());
                });
                _seekAudio(Duration(seconds: value.toInt()));  // 오디오 위치 즉시 변경
              },
              onChangeEnd: (double value) {
                // 드래그가 끝난 후 위치 고정
                _seekAudio(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),  // 현재 위치 시간 표시
                Text(_formatDuration(_duration)),  // 전체 오디오 길이 표시
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이전 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_rewind),
                  onPressed: () {
                    // 여기에 이전 트랙 기능을 추가할 수 있습니다.
                  },
                ),
                // 재생/일시정지 버튼
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                // 다음 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_forward),
                  onPressed: _nextTrack, // 다음 트랙 버튼 클릭 시 동작
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Duration을 분:초 형식으로 변환하는 함수
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
*/

////////////////////////////



/*
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ManualGuideScreen extends StatefulWidget {
  const ManualGuideScreen({Key? key}) : super(key: key);

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;  // 오디오 전체 길이
  Duration _position = Duration.zero;  // 현재 재생 위치
  bool isPlaying = false;  // 현재 재생 상태 확인
  String currentTrack = '코스1 - 들었다놨다.mp3'; // 현재 트랙 이름
  String currentAudioFile = 'audio/daybreak.mp3'; // 현재 음원 파일

  @override
  void initState() {
    super.initState();

    // 오디오 전체 길이 변경 시 처리
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    // 현재 재생 위치 변경 시 처리
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

  // 오디오 재생 및 일시정지 함수
  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource(currentAudioFile));
    }
    setState(() {
      isPlaying = !isPlaying;  // 상태를 반전시킴
    });
  }

  // 오디오 중지 함수
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
      isPlaying = false;
    });
  }

  // 슬라이더 위치를 변경할 때 호출
  void _seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  // 다음 트랙으로 변경하는 함수
  Future<void> _nextTrack() async {
    setState(() {
      currentTrack = '코스2-Love Me Like You Do.mp3'; // 텍스트 변경
      currentAudioFile = 'audio/Love Me Like You Do.mp3'; // 새로운 음원 파일
    });
    await _stopAudio(); // 현재 음원 중지
    await _audioPlayer.play(AssetSource(currentAudioFile)); // 새로운 음원 재생
    setState(() {
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수동 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '감천문화마을',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Adds space between the title and subtitle
            Text(
              currentTrack, // 현재 트랙 제목
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,  // You can adjust this color based on the screenshot you shared
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 24), // Adds space between subtitle and slider
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (double value) {
                _seekAudio(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),  // 현재 위치 시간 표시
                Text(_formatDuration(_duration)),  // 전체 오디오 길이 표시
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이전 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_rewind),
                  onPressed: () {
                    // 여기에 이전 트랙 기능을 추가할 수 있습니다.
                  },
                ),
                // 재생/일시정지 버튼
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                // 다음 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_forward),
                  onPressed: _nextTrack, // 다음 트랙 버튼 클릭 시 동작
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Duration을 분:초 형식으로 변환하는 함수
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
*/

/////////////////


import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ManualGuideScreen extends StatefulWidget {
  const ManualGuideScreen({Key? key}) : super(key: key);

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;  // 오디오 전체 길이
  Duration _position = Duration.zero;  // 현재 재생 위치
  bool isPlaying = false;  // 현재 재생 상태 확인

  @override
  void initState() {
    super.initState();

    // 오디오 전체 길이 변경 시 처리
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    // 현재 재생 위치 변경 시 처리
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

  // 오디오 재생 및 일시정지 함수
  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource('audio/daybreak.mp3'));
    }
    setState(() {
      isPlaying = !isPlaying;  // 상태를 반전시킴
    });
  }

  // 오디오 중지 함수
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
      isPlaying = false;
    });
  }

  // 슬라이더 위치를 변경할 때 호출
  void _seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수동 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '감천문화마을',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Adds space between the title and subtitle
            Text(
              '코스1 - 들었다놨다.mp3',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,  // You can adjust this color based on the screenshot you shared
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 24), // Adds space between subtitle and slider
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (double value) {
                _seekAudio(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),  // 현재 위치 시간 표시
                Text(_formatDuration(_duration)),  // 전체 오디오 길이 표시
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이전 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_rewind),
                  onPressed: () {
                    // 여기에 이전 트랙 기능을 추가할 수 있습니다.
                  },
                ),
                // 재생/일시정지 버튼
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                // 다음 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_forward),
                  onPressed: () {
                    // 여기에 다음 트랙 기능을 추가할 수 있습니다.
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Duration을 분:초 형식으로 변환하는 함수
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}


//////////////////////

/*
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ManualGuideScreen extends StatefulWidget {
  const ManualGuideScreen({Key? key}) : super(key: key);

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;  // 오디오 전체 길이
  Duration _position = Duration.zero;  // 현재 재생 위치
  bool isPlaying = false;  // 현재 재생 상태 확인

  @override
  void initState() {
    super.initState();

    // 오디오 전체 길이 변경 시 처리
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    // 현재 재생 위치 변경 시 처리
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

  // 오디오 재생 및 일시정지 함수
  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource('audio/daybreak.mp3'));
    }
    setState(() {
      isPlaying = !isPlaying;  // 상태를 반전시킴
    });
  }

  // 오디오 중지 함수
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
      isPlaying = false;
    });
  }

  // 슬라이더 위치를 변경할 때 호출
  void _seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수동 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '감천문화마을',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (double value) {
                _seekAudio(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),  // 현재 위치 시간 표시
                Text(_formatDuration(_duration)),  // 전체 오디오 길이 표시
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이전 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_rewind),
                  onPressed: () {
                    // 여기에 이전 트랙 기능을 추가할 수 있습니다.
                  },
                ),
                // 재생/일시정지 버튼
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                // 다음 트랙 버튼
                IconButton(
                  icon: Icon(Icons.fast_forward),
                  onPressed: () {
                    // 여기에 다음 트랙 기능을 추가할 수 있습니다.
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Duration을 분:초 형식으로 변환하는 함수
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
*/


/*
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ManualGuideScreen extends StatefulWidget {
  const ManualGuideScreen({Key? key}) : super(key: key);

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;  // 오디오 전체 길이
  Duration _position = Duration.zero;  // 현재 재생 위치

  @override
  void initState() {
    super.initState();

    // 오디오 전체 길이 변경 시 처리
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    // 현재 재생 위치 변경 시 처리
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

  // 오디오 재생 함수
  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource('audio/daybreak.mp3'));
  }

  // 오디오 일시정지 함수
  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  // 오디오 중지 함수
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  // 슬라이더 위치를 변경할 때 호출
  void _seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수동 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '감천문화마을',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (double value) {
                _seekAudio(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),  // 현재 위치 시간 표시
                Text(_formatDuration(_duration)),  // 전체 오디오 길이 표시
              ],
            ),
            ElevatedButton(
              onPressed: _playAudio,
              child: const Text('오디오 재생'),
            ),
            ElevatedButton(
              onPressed: _pauseAudio,
              child: const Text('일시 정지'),
            ),
            ElevatedButton(
              onPressed: _stopAudio,
              child: const Text('정지'),
            ),
          ],
        ),
      ),
    );
  }

  // Duration을 분:초 형식으로 변환하는 함수
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ManualGuideScreen extends StatefulWidget {
  const ManualGuideScreen({Key? key}) : super(key: key);

  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource('audio/daybreak.mp3'));
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수동 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _playAudio,
              child: const Text('오디오 재생'),
            ),
            ElevatedButton(
              onPressed: _pauseAudio,
              child: const Text('일시 정지'),
            ),
            ElevatedButton(
              onPressed: _stopAudio,
              child: const Text('정지'),
            ),
          ],
        ),
      ),
    );
  }
}
*/