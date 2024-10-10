//감천문화마을 1



//서울 역사박물관

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> playAudio() async {

    //서울 역사박물관
    //String url="https://sfj608538-sfj608538.ktcdn.co.kr/file/audio/56/1090.mp3";

    //감천문화마을
    String url="https://firebasestorage.googleapis.com/v0/b/triptalk-645fd.appspot.com/o/script_tts%2F%EA%B0%90%EC%B2%9C%EB%AC%B8%ED%99%94%EB%A7%88%EC%9D%841.mp3?alt=media&token=5289cf25-5f63-4f2f-a205-e9396eb76656";
    //String url="https://firebasestorage.googleapis.com/v0/b/triptalk-645fd.appspot.com/o/script_tts%2F%EA%B0%90%EC%B2%9C%EB%AC%B8%ED%99%94%EB%A7%88%EC%9D%841.mp3?alt=media&token=5289cf25-5f63-4f2f-a205-e9396eb76656";

    await _audioPlayer.play(UrlSource(url));

    setState(() {
      isPlaying = true;
    });
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();

    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isPlaying ? pauseAudio : playAudio,
              child: Text(isPlaying ? "Pause" : "Play"),
            ),
          ],
        ),
      ),
    );
  }
}
