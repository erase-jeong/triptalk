import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VisitHistoriesScreen extends StatefulWidget {
  final String token; // 토큰을 받기 위한 필드 추가

  // 생성자 정의
  VisitHistoriesScreen({required this.token});

  @override
  _VisitHistoriesScreenState createState() => _VisitHistoriesScreenState();
}

class _VisitHistoriesScreenState extends State<VisitHistoriesScreen> {
  List<dynamic> visitHistories = []; // 방문 기록 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchVisitHistories(); // 초기화 시 API 호출
  }

  // 방문 기록 API 호출 함수
  Future<void> fetchVisitHistories() async {
    try {
      final response = await http.get(
        Uri.parse('https://triptalk.store/v1/visit-histories'),
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Authorization 헤더에 토큰 추가
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          visitHistories = data; // 데이터를 리스트에 저장
          isLoading = false; // 로딩 완료
        });
      } else {
        print('Failed to load visit histories: ${response.statusCode}');
        setState(() {
          isLoading = false; // 로딩 완료
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // 오류 발생 시 로딩 완료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('방문기록'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(
          color: Colors.green, // Back button color
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.green, // Green underline
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // 로딩 중일 때
            : visitHistories.isEmpty
            ? Center(child: Text('방문 기록이 없습니다.')) // 데이터가 없을 때
            : ListView.builder(
          itemCount: visitHistories.length,
          itemBuilder: (context, index) {
            final visitHistory = visitHistories[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 placeholder (API에서 imageUrl 제공 시 사용)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                      image: visitHistory['imageUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(visitHistory['imageUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  // 방문 기록 정보
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        //visitHistory['locationName'] ?? 'Unknown Location',
                        utf8.decode(visitHistory['locationName'].toString().runes.toList())??'Unknown Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),

                    ],
                  ),
                  Spacer(),
                  // 방문 시간
                  Text(
                    visitHistory['visitedTime'] != null
                        ? visitHistory['visitedTime'].split('T').first
                        : 'No Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VisitHistoriesScreen extends StatefulWidget {
  final String token; // 토큰을 받기 위한 필드 추가

  // 생성자 정의
  VisitHistoriesScreen({required this.token});

  @override
  _VisitHistoriesScreenState createState() => _VisitHistoriesScreenState();
}

class _VisitHistoriesScreenState extends State<VisitHistoriesScreen> {
  List<dynamic> visitHistories = []; // 방문 기록 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchVisitHistories(); // 초기화 시 API 호출
  }

  // 방문 기록 API 호출 함수
  Future<void> fetchVisitHistories() async {
    try {
      final response = await http.get(
        Uri.parse('https://triptalk.store/v1/visit-histories'),
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Authorization 헤더에 토큰 추가
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          visitHistories = data; // 데이터를 리스트에 저장
          isLoading = false; // 로딩 완료
        });
      } else {
        print('Failed to load visit histories: ${response.statusCode}');
        setState(() {
          isLoading = false; // 로딩 완료
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // 오류 발생 시 로딩 완료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('방문기록'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(
          color: Colors.green, // Back button color
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.green, // Green underline
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // 로딩 중일 때
            : visitHistories.isEmpty
            ? Center(child: Text('방문 기록이 없습니다.')) // 데이터가 없을 때
            : ListView.builder(
          itemCount: visitHistories.length,
          itemBuilder: (context, index) {
            final visitHistory = visitHistories[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 placeholder (API에서 imageUrl 제공 시 사용)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                      image: visitHistory['imageUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(visitHistory['imageUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  // 방문 기록 정보
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        //visitHistory['locationName'] ?? 'Unknown Location',
                        utf8.decode(visitHistory['locationName'].toString().runes.toList())??'Unknown Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        //visitHistory['locationAddress'] ?? 'Unknown Address',
                        utf8.decode(visitHistory['locationAddress'].toString().runes.toList())??'Unknown Address',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // 방문 시간
                  Text(
                    visitHistory['visitedTime'] != null
                        ? visitHistory['visitedTime'].split('T').first
                        : 'No Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

*/