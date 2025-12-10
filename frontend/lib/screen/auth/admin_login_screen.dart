import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:triptalk/screen/main_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Variables for input
  int kakaoId = 0;
  String username = '';
  String profileImage = 'none';

  // Variable to store the token received after login
  String token = '';

  // Function to make the POST request
  Future<void> loginWithKakao() async {
    // Checking if the credentials are correct
    if (kakaoId == 20010817 && username == '졔구리') {
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
            builder: (context) => MainScreen(token: token,distanceValue: 0),
          ),
        );
      } else {
        print('Failed to log in: ${response.statusCode}');
      }
    } else {
      // Display an error message if the credentials are incorrect
      print('Invalid credentials');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그인 실패'),
            content: const Text('관리자 권한으로만 로그인 가능합니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7BC99E), // Light green background to match the image
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
              const SizedBox(height: 80), // Adjust space for the top section

              // Title Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '똑똑한 ',
                      style: TextStyle(
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
              const SizedBox(height: 40),

              // Kakao ID Input Field
              Container(
                width: 300, // Adjust the width of the text field
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '아이디',
                    labelStyle: const TextStyle(color: Colors.white, fontFamily: 'Pretendard',),
                    filled: true,
                    fillColor: const Color.fromRGBO(221, 238, 238, 0.65),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    kakaoId = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Password Input Field
              Container(
                width: 300, // Adjust the width of the text field
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '비밀번호', // Label is displayed above the text field when not focused
                    labelStyle: const TextStyle(color: Colors.white , fontFamily: 'Pretendard',),
                    filled: true,
                    fillColor: const Color.fromRGBO(221, 238, 238, 0.65),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never, // Prevents label from floating when focused
                  ),
                  //obscureText: true, // To hide the input text for passwords
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    username = value;
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Login Button
              ElevatedButton(
                onPressed: loginWithKakao,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFFCC8E7), // Light pink color for the login button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 15),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 18, fontFamily: 'HSSantokki'),
                ),
              ),
              const SizedBox(height: 20),

              // Token Display after successful login


            ],
          ),
        ),
      ),
    );
  }
}


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:triptalk/screen/main_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Variables for input
  int kakaoId = 0;
  String username = '';
  String profileImage = 'none';

  // Variable to store the token received after login
  String token = '';

  // Function to make the POST request
  Future<void> loginWithKakao() async {
    // Checking if the credentials are correct
    if (kakaoId == 1232 && username == 'sdf') {
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
    } else {
      // Display an error message if the credentials are incorrect
      print('Invalid credentials');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid ID or Password.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7BC99E), // Light green background to match the image
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
              const SizedBox(height: 80), // Adjust space for the top section

              // Title Text
              // other widgets...

              // Login Button
              ElevatedButton(
                onPressed: loginWithKakao,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFFCC8E7), // Light pink color for the login button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 15),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 18, fontFamily: 'HSSantokki'),
                ),
              ),
              const SizedBox(height: 20),

              // Token Display after successful login
              // other widgets...
            ],
          ),
        ),
      ),
    );
  }
}

*/

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:triptalk/screen/main_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Variables for input
  int kakaoId = 0;
  String username = '';
  String profileImage = 'none';

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
        backgroundColor: const Color(0xFF7BC99E),
        // Light green background to match the image
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
                const SizedBox(height: 80), // Adjust space for the top section

                // Title Text
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '똑똑한 ',
                        style: TextStyle(
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
                const SizedBox(height: 40),

                // Kakao ID Input Field
                Container(
                  width: 300, // Adjust the width of the text field
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '아이디',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFFDDEEEE),
                      // Light gray background for input fields
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      kakaoId = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input Field
                Container(
                  width: 300, // Adjust the width of the text field
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      // Label is displayed above the text field when not focused
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFFDDEEEE),
                      // Light gray background for input fields
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior
                          .never, // Prevents label from floating when focused
                    ),
                    obscureText: true, // To hide the input text for passwords
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      username = value;
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Login Button
                ElevatedButton(
                  onPressed: loginWithKakao,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFFCC8E7),
                    // Light pink color for the login button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded button
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 125, vertical: 15),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(fontSize: 18, fontFamily: 'HSSantokki'),
                  ),
                ),
                const SizedBox(height: 20),

                // Token Display after successful login
                token.isNotEmpty
                    ? Text(
                  '로그인 성공! 토큰: $token',
                  style: const TextStyle(color: Colors.white),
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