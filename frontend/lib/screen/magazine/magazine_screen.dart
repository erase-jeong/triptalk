import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:triptalk/screen/service/notification_service.dart';

class MagazineScreen extends StatefulWidget {
  const MagazineScreen({super.key});

  @override
  _MagazineScreenState createState() => _MagazineScreenState();
}

class _MagazineScreenState extends State<MagazineScreen> {
  Timer? _timer; // 타이머 선언

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions(); // 알림 권한 요청
  }

  void _requestNotificationPermissions() async {
    // 알림 권한 요청
    final status = await NotificationService().requestNotificationPermissions();
    if (status.isDenied && context.mounted) {
      showDialog(
        // 알림 권한 거부 시 다이얼로그 출력
        context: context,
        builder: (context) => AlertDialog(
          title: Text('알림 권한이 거부되었습니다.'),
          content: Text('알림을 받으려면 앱 설정에서 권한을 허용해야 합니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('설정'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // 설정 클릭 시 앱 설정으로 이동
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E6E6E), // 배경 색상 설정
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 이미지
            Image.asset(
              'assets/images/magazine/warning.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            // 경고 메시지
            const Text(
              '아직 열심히 준비 중이에요!',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'HSSantokki',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              '매거진 콘텐츠를 위해 조금만 기다려주세요.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'HSSantokki',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            /*
            ElevatedButton(
              onPressed: () {
                NotificationService().showNotification(); // 알림 출력
              },
              child: const Text('알림바'),
            ),

             */
          ],
        ),
      ),
    );
  }
}


/*
//매거진 코드
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:triptalk/screen/service/notification_service.dart';

class MagazineScreen extends StatefulWidget {
  const MagazineScreen({super.key});

  @override
  _MagazineScreenState createState() => _MagazineScreenState();
}

class _MagazineScreenState extends State<MagazineScreen> {
  int _counter = 0; // 타이머 카운트 초기화
  int _targetNumber = 10; // 타겟 시간 초기화
  Timer? _timer; // 타이머 선언

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions(); // 알림 권한 요청
  }

  void _requestNotificationPermissions() async {
    // 알림 권한 요청
    final status = await NotificationService().requestNotificationPermissions();
    if (status.isDenied && context.mounted) {
      showDialog(
        // 알림 권한 거부 시 다이얼로그 출력
        context: context,
        builder: (context) => AlertDialog(
          title: Text('알림 권한이 거부되었습니다.'),
          content: Text('알림을 받으려면 앱 설정에서 권한을 허용해야 합니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('설정'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // 설정 클릭 시 앱 설정으로 이동
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E6E6E), // 배경 색상 설정
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 이미지
            Image.asset(
              'assets/images/magazine/warning.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            // 경고 메시지
            const Text(
              '아직 열심히 준비 중이에요!',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'HSSantokki',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              '매거진 콘텐츠를 위해 조금만 기다려주세요.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'HSSantokki',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 타이머
            Text(
              '타이머: $_counter 초',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('알림 시간 입력(초): ', style: TextStyle(color: Colors.white)),
                SizedBox(
                  width: 60,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _targetNumber = int.parse(value);
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetCounter,
                  child: const Text('초기화'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(_timer?.isActive == true ? '정지' : '시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetCounter() {
    setState(() {
      _counter = 0; // 타이머 카운터 초기화
    });
  }

  void _toggleTimer() {
    // 타이머 시작/정지 기능
    if (_timer?.isActive == true) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    // 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _counter++;
        if (_counter == _targetNumber) {
          NotificationService().showNotification(_targetNumber); // 알림 출력
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    // 타이머 정지
    _timer?.cancel();
  }
}
*/



/*
//완성된 코드
import 'package:flutter/material.dart';

class MagazineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6E6E6E), // 배경 색상 설정
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 이미지
            Image.asset(
              'assets/images/magazine/warning.png',
              width: 100, // 크기 조정 가능
              height: 100,
            ),
            SizedBox(height: 20),
            // 경고 메시지
            Text(
              '아직 열심히 준비 중이에요!',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'HSSantokki',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              '매거진 콘텐츠를 위해 조금만 기다려주세요.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'HSSantokki',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
*/



//오디오 테스트 코드
/*
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:triptalk/screen/magazine/audio_player_screen.dart';
// AudioPlayerScreen을 정의

// MagazineScreen을 정의
class MagazineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700], // 배경 색상 설정
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 아이콘
            Icon(
              Icons.warning_amber_rounded,
              size: 100,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            // 경고 메시지
            Text(
              '아직 열심히 준비 중이에요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              '매거진 콘텐츠를 위해 조금만 기다려주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            // '오디오 URL test' 버튼 추가
            ElevatedButton(
              onPressed: () {
                // 버튼 누르면 AudioPlayerScreen으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AudioPlayerScreen()),
                );
              },
              child: Text('오디오 URL test'),
            ),
          ],
        ),
      ),
    );
  }
}
*/




/*
import 'package:flutter/material.dart';

class MagazineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700], // 배경 색상 설정
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 아이콘
            Icon(
              Icons.warning_amber_rounded,
              size: 100,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            // 경고 메시지
            Text(
              '아직 열심히 준비 중이에요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              '매거진 콘텐츠를 위해 조금만 기다려주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

*/

