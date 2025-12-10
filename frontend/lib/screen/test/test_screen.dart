import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱을 위해 필요
import 'package:triptalk/screen/test/manual_guide_screen.dart';
import 'package:triptalk/screen/test/auto_guide_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String searchQuery = ""; // 검색창에서 입력한 텍스트를 저장하는 변수
  Map<String, dynamic>? searchResult; // 검색 결과를 저장하는 변수

  // API 호출을 통해 관광지 정보를 가져오는 함수
  Future<void> fetchTouristSpot(String spotname) async {
    final url = Uri.parse('http://localhost:3000/touristSpot?spotname=$spotname');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResult = data; // 검색 결과를 상태로 저장
        });
      } else {
        setState(() {
          searchResult = null; // 검색 결과가 없으면 null 처리
        });
      }
    } catch (error) {
      print('Error fetching tourist spot: $error');
      setState(() {
        searchResult = null; // 에러가 발생하면 null 처리
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey[300], // 검색 바의 배경색을 회색으로 설정
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '관광지 검색...',
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    searchQuery = value; // 검색창에 입력된 값을 저장
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  if (searchQuery.isNotEmpty) {
                    fetchTouristSpot(searchQuery); // API 호출
                  }
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white, // 상단 바의 배경색을 흰색으로 설정
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            searchResult != null
                ? Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300], // 이미지 자리
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              searchResult!['spotname'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.bookmark_border, color: Colors.red), // 북마크 아이콘
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '위도: ${searchResult!['lat']}, 경도: ${searchResult!['lng']}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                : Center(
              child: Text(
                searchQuery.isEmpty
                    ? '관광지를 검색하세요'
                    : '검색 결과가 없습니다.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 경로 보기 버튼을 눌렀을 때 동작
                    // 경로 관련 로직을 추가할 수 있습니다.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300], // 버튼 배경색을 회색으로 설정
                  ),
                  child: const Text(
                    '경로보기',
                    style: TextStyle(color: Colors.black), // 텍스트를 검정색으로 설정
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showGuideDialog(context); // 가이드 버튼을 눌렀을 때 팝업창 호출
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300], // 버튼 배경색을 회색으로 설정
                  ),
                  child: const Text(
                    '가이드',
                    style: TextStyle(color: Colors.black), // 텍스트를 검정색으로 설정
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AutoGuideScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 버튼 배경색을 검정색으로 설정
                ),
                child: const Text('자동 가이드'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManualGuideScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 버튼 배경색을 검정색으로 설정
                ),
                child: const Text('수동 가이드'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:triptalk/screen/test/manual_guide_screen.dart';
import 'package:triptalk/screen/test/auto_guide_screen.dart';

//dart 파일 import

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey[300], // 검색 바의 배경색을 회색으로 설정
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '관광지 검색...',
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Icon(Icons.search, color: Colors.black),
            ],
          ),
        ),
        backgroundColor: Colors.white, // 상단 바의 배경색을 흰색으로 설정
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300], // 이미지 자리
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: const [
                            Text(
                              '관광지명',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.bookmark_border, color: Colors.red), // 북마크 아이콘
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '부산 사하구 감천동',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 경로 보기 버튼을 눌렀을 때 동작
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[300], // 버튼 배경색을 회색으로 설정
                  ),
                  child: const Text(
                    '경로보기',
                    style: TextStyle(color: Colors.black), // 텍스트를 검정색으로 설정
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showGuideDialog(context); // 가이드 버튼을 눌렀을 때 팝업창 호출
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[300], // 버튼 배경색을 회색으로 설정
                  ),
                  child: const Text(
                    '가이드',
                    style: TextStyle(color: Colors.black), // 텍스트를 검정색으로 설정
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AutoGuideScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // 버튼 배경색을 검정색으로 설정
                ),
                child: const Text('자동 가이드'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManualGuideScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // 버튼 배경색을 검정색으로 설정
                ),
                child: const Text('수동 가이드'),
              ),

            ],
          ),
        );
      },
    );
  }
}
*/