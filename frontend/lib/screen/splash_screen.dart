import 'package:flutter/material.dart';
import 'package:triptalk/screen/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // 스플래시 화면을 2초간 보여준 후
    await Future.delayed(Duration(seconds: 3), () {});
    // 홈 화면으로 이동
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DefaultTabController(
            length: 2,
            child: Scaffold(
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  LoginScreen(),
                  // 다른 화면들을 추가할 수 있습니다.
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/onboarding/onboardingBackground.png'),
            fit: BoxFit.cover, // 이미지를 화면에 꽉 차게 설정
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '똑똑한 ',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFFFCC8E7),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' 여행,\n',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '뜻깊은 ',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFFFCC8E7),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' 여정,\n',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Trip Talk',
                      style: TextStyle(
                        fontFamily: 'HSSantokki',
                        color: Color(0xFFFCC8E7),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 200), // 텍스트와 이미지 사이에 간격 추가

            ],
          ),
        ),
      ),
    );
  }
}


//////////

/*
import 'package:flutter/material.dart';
import 'package:triptalk/screen/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // 스플래시 화면을 2초간 보여준 후
    await Future.delayed(Duration(seconds: 2), () {});
    // 홈 화면으로 이동
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DefaultTabController(
            length: 2,
            child: Scaffold(
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  LoginScreen(),
                  // 다른 화면들을 추가할 수 있습니다.
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF549062), // 배경색 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '똑똑한 ',
                    style: TextStyle(
                      color: Color(0xFFFCC8E7),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '여행,\n',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '뜻깊은 ',
                    style: TextStyle(
                      color: Color(0xFFFCC8E7),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '여정,\n',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '\n',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Trip Talk',
                    style: TextStyle(
                      color: Color(0xFFFCC8E7),
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24), // 텍스트와 이미지 사이에 간격 추가
            Image.asset(
              './assets/onboarding_img.png', // 이미지 경로를 설정하세요
              width: 200,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}
*/