import 'package:flutter/material.dart';
import 'package:triptalk/screen/splash_screen.dart'; // 로그아웃 시 이동할 화면 추가

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Info Page'),
            SizedBox(height: 20), // 간격 추가

            // 로그아웃 텍스트
            GestureDetector(
              onTap: () async {
                // SharedPreferences에서 토큰을 삭제하여 로그아웃 처리 (옵션)

                // 모든 네비게이션 스택을 삭제하고 SplashScreen으로 이동 (MainScreen 포함)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(), // SplashScreen으로 이동
                  ),
                      (Route<dynamic> route) => false, // 스택을 비우고 MainScreen도 제거
                );
              },
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:triptalk/screen/splash_screen.dart'; // 로그아웃 시 이동할 화면 추가

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Info Page'),
            SizedBox(height: 20), // 간격 추가

            // 로그아웃 텍스트
            GestureDetector(
              onTap: () async {
                // 여기에서 로그아웃 처리 (토큰 삭제 등)

                // 기존의 모든 화면을 제거하고 새로운 화면을 시작 (하단바 제거)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(), // 로그아웃 후 SplashScreen으로 이동
                  ),
                      (Route<dynamic> route) => false, // 이전 모든 페이지 제거
                );
              },
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
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
import 'package:triptalk/screen/splash_screen.dart'; // 로그아웃 시 이동할 화면 추가

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Info Page'),
            SizedBox(height: 20), // 간격 추가

            // 로그아웃 텍스트
            GestureDetector(
              onTap: () async {
                // SharedPreferences에서 토큰을 삭제하여 로그아웃 처리
                // 여기에 SharedPreferences 처리 코드를 넣을 수 있습니다.

                // 로그아웃 시 MainScreen을 제거하고 SplashScreen으로 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(), // 로그아웃 후 SplashScreen으로 이동
                  ),
                      (route) => false, // 모든 기존 화면 제거
                );
              },
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
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
import 'package:triptalk/screen/splash_screen.dart'; // logout.dart 추가

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Info Page'),
            SizedBox(height: 20), // 간격 추가

            // 로그아웃 텍스트
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(), // 로그아웃 페이지로 이동
                  ),
                );
              },
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


/*
// userInfo.dart
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
        child: Text('User Info Page'),
      ),
    );
  }
}

*/