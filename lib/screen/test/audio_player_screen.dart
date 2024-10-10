import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  // AudioPlayer 인스턴스 생성
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isPaused = false;

  // 오디오 파일 URL (로컬 파일 사용 시 파일 경로를 사용하세요)
  final String audioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  // 오디오 재생 함수
  void _playAudio() async {
    if (!isPlaying && !isPaused) {
      await _audioPlayer.play(UrlSource(audioUrl));
      setState(() {
        isPlaying = true;
      });
    } else if (isPaused) {
      await _audioPlayer.resume();
      setState(() {
        isPlaying = true;
        isPaused = false;
      });
    }
  }

  // 오디오 일시정지 함수
  void _pauseAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
        isPaused = true;
      });
    }
  }

  // 오디오 중지 함수
  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      isPaused = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 앱 종료 시 오디오 플레이어 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("오디오 플레이어"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _playAudio,
              child: Text(isPlaying ? '재생 중' : '재생'),
            ),
            ElevatedButton(
              onPressed: _pauseAudio,
              child: Text('일시정지'),
            ),
            ElevatedButton(
              onPressed: _stopAudio,
              child: Text('중지'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AudioPlayerScreen(),
  ));
}
