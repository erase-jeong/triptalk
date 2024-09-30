/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:triptalk/screen/main_screen.dart';

class KakaoLoginScreen extends StatefulWidget {
  final int kakaoId;
  final String username;
  final String profileImage;

  KakaoLoginScreen({required this.kakaoId, required this.username, required this.profileImage});

  @override
  _KakaoLoginScreenState createState() => _KakaoLoginScreenState();
}

class _KakaoLoginScreenState extends State<KakaoLoginScreen> {
  // Variable to store the token received after login
  String token = '';

  // Function to make the POST request
  Future<void> loginWithKakao() async {
    final url = Uri.parse('https://triptalk.store/v1/users/kakao-login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "kakaoId": widget.kakaoId,
        "username": widget.username,
        "profileImage": widget.profileImage,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        token = data['data']; // Storing the JWT token from response
      });

      // Navigate to MainScreen on successful login, passing the token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(token: token),
        ),
      );
    } else {
      print('Failed to log in: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    loginWithKakao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF549062),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '로그인 중...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              token.isNotEmpty
                  ? Text(
                '로그인 성공! 토큰: $token',
                style: TextStyle(color: Colors.white),
              )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
*/

/////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:triptalk/screen/main_screen.dart';

class KakaoLoginScreen extends StatefulWidget {
  @override
  _KakaoLoginScreenState createState() => _KakaoLoginScreenState();
}

class _KakaoLoginScreenState extends State<KakaoLoginScreen> {
  // Variables for input
  int kakaoId = 0;
  String username = '';
  String profileImage = '';

  // Variable to store the token received after login
  String token = '';

  // Function to make the POST request
  Future<void> loginWithKakao() async {
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

      // Navigate to MainScreen on successful login, passing the token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(token: token),
        ),
      );
    } else {
      print('Failed to log in: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF549062),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        color: Colors.purple[200],
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
                        color: Colors.purple[200],
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
                        color: Colors.purple[200],
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Kakao ID',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  kakaoId = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  username = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Profile Image URL',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  profileImage = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginWithKakao,
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFFE812), // 카카오 노란색
                  onPrimary: Colors.black, // 글자 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  '카카오계정으로 로그인',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              token.isNotEmpty
                  ? Text(
                '로그인 성공! 토큰: $token',
                style: TextStyle(color: Colors.white),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
*/