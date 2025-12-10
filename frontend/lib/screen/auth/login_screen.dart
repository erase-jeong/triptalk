import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:triptalk/screen/main_screen.dart'; // MainScreen 경로 확인
import 'package:triptalk/screen/auth/admin_login_screen.dart'; // AdminLoginScreen 경로 확인
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {  @override
_LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false; // 로딩 상태 추가
  String token = '';

  Future<void> _loginWithKakao() async {
    setState(() {
      _isLoading = true; // 로딩 상태 시작
    });


    try {
      late OAuthToken loginResult;
      if (await isKakaoTalkInstalled()) { // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
        try {

          //loginResult = await UserApi.instance.loginWithKakaoAccount(); // <- 카카오 계정꺼
          loginResult = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡 로그인 성공, ${loginResult.toString()}');

          // 로그인 성공 시 사용자 정보 요청
          User user = await UserApi.instance.me();
          String username = user.kakaoAccount?.profile?.nickname ?? 'Unknown User';
          String profileImage = user.kakaoAccount?.profile?.profileImageUrl ?? 'aa';
          int kakaoId = user.id ?? 0;

          print("login_screen에서 사용자 값 확인");
          print("username: ");
          print(username);
          print("profileImage : ");
          print(profileImage);
          print("kakoId : ");
          print(kakaoId);

          // 서버로 사용자 정보 전송
          await _sendUserInfoToServer(kakaoId, username, profileImage);

          // 로그인 성공 시 MainScreen으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                token: token, // 이후 처리할 필요가 없으므로 빈 토큰
                distanceValue: 0,
              ),
            ),
          );

        } catch (error) {
          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            print(await KakaoSdk.origin);
            loginResult = await UserApi.instance.loginWithKakaoAccount();
            print('카카오 계정 로그인 성공, ${loginResult.toString()}');

            // 로그인 성공 시 사용자 정보 요청
            User user = await UserApi.instance.me();
            String username = user.kakaoAccount?.profile?.nickname ?? 'Unknown User';
            String profileImage = user.kakaoAccount?.profile?.profileImageUrl ?? 'aa';
            int kakaoId = user.id ?? 0;

            print("login_screen에서 사용자 값 확인");
            print("username: ");
            print(username);
            print("profileImage : ");
            print(profileImage);
            print("kakoId : ");
            print(kakaoId);

            // 서버로 사용자 정보 전송
            await _sendUserInfoToServer(kakaoId, username, profileImage);

            // 로그인 성공 시 MainScreen으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  token: token, // 이후 처리할 필요가 없으므로 빈 토큰
                  distanceValue: 0,
                ),
              ),
            );

          } catch (error) {
            print('카카오 계정 로그인 실패, ${error.toString()}');
            rethrow;
          }
        }
      } else {
        print(await KakaoSdk.origin);
        loginResult = await UserApi.instance.loginWithKakaoAccount();
        print('카카오 계정 로그인 성공, ${loginResult.toString()}');
        // 로그인 성공 시 사용자 정보 요청
        User user = await UserApi.instance.me();
        String username = user.kakaoAccount?.profile?.nickname ?? 'Unknown User';
        String profileImage = user.kakaoAccount?.profile?.profileImageUrl ?? 'aa';
        int kakaoId = user.id ?? 0;

        print("login_screen에서 사용자 값 확인");
        print("username: ");
        print(username);
        print("profileImage : ");
        print(profileImage);
        print("kakoId : ");
        print(kakaoId);

        // 서버로 사용자 정보 전송
        await _sendUserInfoToServer(kakaoId, username, profileImage);

        // 로그인 성공 시 MainScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              token: token, // 이후 처리할 필요가 없으므로 빈 토큰
              distanceValue: 0,
            ),
          ),
        );
      }
    } catch (e) {
      print('카카오 계정 로그인 실패, ${e.toString()}');
      rethrow;
    }
    finally {
      setState(() {
        _isLoading = false; // 로딩 상태 종료
      });
    }
  }




  // 서버로 사용자 정보를 보내는 함수
  Future<void> _sendUserInfoToServer(int kakaoId, String username, String profileImage) async {
    final url = Uri.parse('https://triptalk.store/v1/users/kakao-login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "kakaoId": kakaoId,
        "username": username,
        "profileImage": profileImage,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        token = data['data']; // Storing the JWT token from response
      });

      // Print the token to console
      print('Login successful! Token: $token');
    } else {
      print('서버 오류: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/onboarding/loginBackground.png'),
            fit: BoxFit.cover, // 이미지를 화면에 꽉 차게 설정
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              SizedBox(height: 100),

              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // 버튼의 가로 길이를 70%로 설정
                child: ElevatedButton(
                  onPressed: _loginWithKakao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFCC8E7),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 텍스트와 아이콘을 가운데 정렬
                    children: [
                      Image.asset(
                        'assets/images/onboarding/kakaotalkIcon.png', // 아이콘 파일 경로
                        width: 24, // 아이콘 크기
                        height: 24,
                      ),
                      SizedBox(width: 10), // 아이콘과 텍스트 사이의 간격
                      Text(
                        '카카오 로그인',
                        style: TextStyle(fontSize: 18, fontFamily: 'HSSantokki'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 33),
              // 관리자용 로그인 추가
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminLoginScreen(),
                    ),
                  );
                },
                child: Text(
                  '관리자용 로그인',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline, // 밑줄 추가
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/////////////////////


/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:triptalk/screen/auth/test_screen.dart';
import 'package:triptalk/screen/main_screen.dart';

class LoginScreen extends StatelessWidget {

  Future<void> signInWithKakao() async {
    // 카카오 로그인 구현 예제

// 카카오톡 실행 가능 여부 확인
// 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        navigateToMainPage();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
    try {
      await UserApi.instance.loginWithKakaoAccount();
      print('카카오계정으로 로그인 성공');
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  void navigateToMainPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TestScreen())
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // 로그인 버튼이 눌렸을 때 동작 추가
              },
              child: Text('Login'),
            ),
            getKakoLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget getKakoLoginButton(){
    return InkWell(
      onTap:(){
        signInWithKakao();
      },

      child: const Text("Sign in With Kakao"),

    );
  }


}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}

*/
