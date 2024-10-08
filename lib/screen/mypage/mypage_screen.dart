import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triptalk/screen/mypage/visit_histories_screen.dart';
import 'package:triptalk/screen/mypage/bookmark_screen.dart';
import 'package:triptalk/screen/mypage/alarm_screen.dart';
import 'package:triptalk/screen/splash_screen.dart';
import 'package:triptalk/screen/mypage/userInfo.dart';

class MypageScreen extends StatefulWidget {
  final String token;
  final Function(int) onDistanceSelected; // MainScreen으로 전달할 distanceValue 콜백 함수

  MypageScreen({required this.token, required this.onDistanceSelected});

  @override
  _MypageScreenState createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  bool _isHovering = false;
  String username = '';
  String profileImage = '';
  List<dynamic> visitHistories = [];
  List<dynamic> bookmarks = [];

  @override
  void initState() {
    super.initState();
    fetchMypageData();

  }

  Future<void> fetchMypageData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/users/mypage'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        username = utf8.decode(data['profile']['username'].toString().runes.toList());
        profileImage = data['profile']['profileImage'];
        visitHistories = data['visitHistories'];
        bookmarks = data['bookmarks'];
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SplashScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 섹션
            _buildUserInfoSection(),
            SizedBox(height: 24),
            // 방문 기록 섹션
            _buildSectionTitle(context, Icons.message, '방문 기록'),
            _buildGridSectionVisitHistories(context, visitHistories),
            SizedBox(height: 24),
            // 북마크 섹션
            _buildSectionTitle(context, Icons.bookmark, '북마크'),
            _buildGridSection(context, bookmarks),
            SizedBox(height: 24),
            // 알림 설정 섹션
            _buildSectionTitle(context, Icons.notifications, '알림 설정'),
            SizedBox(height: 40),
            // 로그아웃 버튼
            _buildLogoutButton(),
            SizedBox(height: 16),
            // 회원 탈퇴 버튼
            _buildDeleteAccountButton(),
          ],
        ),
      ),
    );
  }

  // 사용자 정보 섹션
  Widget _buildUserInfoSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(width: 16, height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('반가워요.', style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Pretendard')),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$username',
                    style: TextStyle(fontSize: 24, fontFamily: 'Pretendard.w600', fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(' 님!', style: TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () async {
        if (title == '알림 설정') {
          // 알림 설정 클릭 시 AlarmScreen으로 이동하여 distanceValue 받아오기
          final int? selectedDistance = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlarmScreen(token: widget.token)),
          );
          if (selectedDistance != null) {
            widget.onDistanceSelected(selectedDistance); // distanceValue를 MainScreen으로 전달
          }
        } else if (title == '방문 기록') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VisitHistoriesScreen(token: widget.token)),
          );
        } else if (title == '북마크') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookmarkScreen(token: widget.token)),
          );
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF549062)),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontFamily: 'Pretendard.w500', color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildGridSectionVisitHistories(BuildContext context, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var item in items.take(3)) _buildGridItemWithImage(item),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Color(0xFF539162)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VisitHistoriesScreen(token: widget.token)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridSection(BuildContext context, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var item in items.take(3)) _buildGridItemWithImage(item),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Color(0xFF539162)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarkScreen(token: widget.token)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridItemWithImage(dynamic item) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        image: item != null && item is String
            ? DecorationImage(image: NetworkImage(item), fit: BoxFit.cover)
            : null,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Text(
        '로그아웃',
        style: TextStyle(fontSize: 14, color: Color(0xFF656565), fontFamily: 'Pretendard', decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return GestureDetector(
      onTap: () {
        // 회원탈퇴 기능 연결 (여기서 정의할 필요 있음)
      },
      child: Text(
        '회원탈퇴',
        style: TextStyle(fontSize: 14, color: Color(0xFF656565), fontFamily: 'Pretendard', decoration: TextDecoration.underline),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'package:triptalk/screen/auth/login_screen.dart'; // 로그인 화면 추가
import 'package:triptalk/screen/mypage/visit_histories_screen.dart';
import 'package:triptalk/screen/mypage/bookmark_screen.dart';
import 'package:triptalk/screen/mypage/alarm_screen.dart'; // 알림 설정 화면 추가
import 'package:triptalk/screen/splash_screen.dart';
import 'package:triptalk/screen/mypage/userInfo.dart'; // userInfo 추가

class MypageScreen extends StatefulWidget {
  final String token;
  final Function(int) onDistanceSelected;

  //const MypageScreen({Key? key, required this.token}) : super(key: key);
  MypageScreen({required this.token, required this.onDistanceSelected});

  @override
  _MypageScreenState createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  bool _isHovering = false;
  String username = '';
  String profileImage = '';
  List<dynamic> visitHistories = []; // 방문 기록 리스트 (이미지 포함)
  List<dynamic> bookmarks = []; // 북마크 리스트 (이미지 포함)

  @override
  void initState() {
    super.initState();
    fetchMypageData(); // Mypage 데이터 가져오기
  }

  Future<void> fetchMypageData() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/users/mypage'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        // 사용자 정보 설정
        username = utf8.decode(data['profile']['username'].toString().runes.toList());
        profileImage = data['profile']['profileImage'];
        visitHistories = data['visitHistories']; // 방문 기록 데이터
        bookmarks = data['bookmarks']; // 북마크 데이터
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  // 로그아웃 함수
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // 모든 이전 화면을 제거하고 로그인 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => SplashScreen(),
      ),
          (route) => false, // 모든 기존 라우트 제거
    );
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22.0), // 왼쪽 간격 추가
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(width: 16, height: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '반가워요.',
                        style: TextStyle(fontSize: 16, color: Colors.black,fontFamily: 'Pretendard'),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic, // baseline 정렬 기준 설정
                        children: [
                          Text(
                            '$username',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Pretendard.w600',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            ' 님!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),


                      SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 간격 추가
              child: _buildSectionTitle(context, Icons.message, '방문 기록'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 간격 추가
              child: _buildGridSectionVisitHistories(context, visitHistories), // 방문 기록 섹션
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 간격 추가
              child: _buildSectionTitle(context, Icons.bookmark, '북마크'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 간격 추가
              child: _buildGridSection(context, bookmarks), // 북마크 섹션
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 간격 추가
              child: _buildSectionTitle(context, Icons.notifications, '알림 설정'),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 간격 추가
              child: GestureDetector(
                onTap: _logout, // 로그아웃 함수 연결
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF656565),
                    fontFamily: 'Pretendard',
                    decoration: TextDecoration.underline, // 밑줄 추가
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 간격 추가
              child: GestureDetector(
                onTap: () {
                  // 회원탈퇴 기능 연결 (여기서 정의할 필요 있음)
                },
                child: Text(
                  '회원탈퇴',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF656565),
                    fontFamily: 'Pretendard',
                    decoration: TextDecoration.underline, // 밑줄 추가
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        if (title == '방문 기록') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitHistoriesScreen(token: widget.token),
            ),
          );
        } else if (title == '북마크') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookmarkScreen(token: widget.token),
            ),
          );
        } else if (title == '알림 설정') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlarmScreen(token: widget.token),
            ),
          );
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF549062)),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Pretendard.w500',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // 방문 기록 그리드 섹션: 최신 3개의 방문 기록 이미지를 표시
  Widget _buildGridSectionVisitHistories(BuildContext context, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var item in items.take(3)) _buildGridItemWithImage(item), // 최신 3개의 방문 기록 이미지
          IconButton(
            icon: Icon(Icons.chevron_right, color: Color(0xFF539162)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisitHistoriesScreen(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 북마크 그리드 섹션: 최신 3개의 북마크 이미지를 표시
  Widget _buildGridSection(BuildContext context, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var item in items.take(3)) _buildGridItemWithImage(item), // 최신 3개의 북마크 이미지
          IconButton(
            icon: Icon(Icons.chevron_right, color: Color(0xFF539162)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarkScreen(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 이미지가 포함된 그리드 아이템
  Widget _buildGridItemWithImage(dynamic item) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        image: item != null && item is String
            ? DecorationImage(
          image: NetworkImage(item), // imageUrl을 표시
          fit: BoxFit.cover,
        )
            : null, // 이미지가 없으면 회색 박스
      ),
    );
  }
}

*/






