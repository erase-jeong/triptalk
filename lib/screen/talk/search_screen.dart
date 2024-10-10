import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triptalk/screen/talk/talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드
  final String token; // 토큰을 전달받기 위한 필드 추가

  // 생성자에서 검색어와 토큰 받기
  SearchScreen({required this.searchText, required this.token});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/triptalk/backIcon.png',width:18,height:18), // 첨부된 backIcon 이미지 사용
          onPressed: () {
            // 뒤로가기 버튼을 클릭하면 이전 화면으로 돌아감
            Navigator.pop(context);
          },
        ),
        title: _buildSearchBar(),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.grey),
                title: Text(
                  result['locationName'],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  result['address'],
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  // 항목 클릭 시 TalkScreen으로 이동하며 tid 전달
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TalkScreen(
                        token: widget.token,
                        tid: result['tid'],
                        tlid: result['tlid'],
                        locationName: result['locationName'],
                        address: result['address'],
                      ),
                    ),
                  );
                },
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ],
          );
        },
      ),
    );
  }

  // 검색 바를 구현
  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: widget.searchText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 12),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


///////

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triptalk/screen/talk/talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드
  final String token; // 토큰을 전달받기 위한 필드 추가

  // 생성자에서 검색어와 토큰 받기
  SearchScreen({required this.searchText, required this.token});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 0, // leading(뒤로가기 버튼) 제거
        title: _buildSearchBar(), // 사진과 비슷한 검색 바 구현
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.grey),
                title: Text(
                  result['locationName'],
                  style: TextStyle(
                    color: Colors.black, // 텍스트 색상을 검정색으로 변경
                    fontSize: 16, // 글씨 크기를 16으로 설정
                    fontWeight: FontWeight.bold, // 굵게 표시
                  ),
                ),
                subtitle: Text(
                  result['address'],
                  style: TextStyle(
                    color: Colors.grey, // 주소 색상을 회색으로 설정
                    fontSize: 14, // 글씨 크기를 14로 설정
                  ),
                ),
                onTap: () {
                  // 항목 클릭 시 TalkScreen으로 이동하며 tid 전달
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TalkScreen(
                        token: widget.token, // SearchScreen에서 받은 토큰 전달
                        tid: result['tid'], // 선택된 항목의 tid 전달
                        tlid: result['tlid'],
                        locationName: result['locationName'],
                        address: result['address'],
                      ),
                    ),
                  );
                },
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1, // 얇은 구분선 추가
              ),
            ],
          );
        },
      ),
    );
  }

  // 검색 바를 구현 (기존과 동일하나 더 길게 설정)
  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 검색 바를 화면의 90%로 설정
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 8), // 왼쪽 여백만 남기고 아이콘 제거
          Expanded(
            child: TextField(
              readOnly: true, // 사용자가 직접 입력하지 못하게 수정
              decoration: InputDecoration(
                hintText: widget.searchText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 12), // 텍스트를 살짝 위로 올림
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/


/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triptalk/screen/talk/talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드
  final String token; // 토큰을 전달받기 위한 필드 추가

  // 생성자에서 검색어와 토큰 받기
  SearchScreen({required this.searchText, required this.token});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 0, // leading(뒤로가기 버튼) 제거
        title: _buildSearchBar(), // 사진과 비슷한 검색 바 구현
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.grey),
                title: Text(
                  result['locationName'],
                  style: TextStyle(
                    color: Colors.black, // 텍스트 색상을 검정색으로 변경
                    fontSize: 16, // 글씨 크기를 16으로 설정
                    fontWeight: FontWeight.bold, // 굵게 표시
                  ),
                ),
                subtitle: Text(
                  result['address'],
                  style: TextStyle(
                    color: Colors.grey, // 주소 색상을 회색으로 설정
                    fontSize: 14, // 글씨 크기를 14로 설정
                  ),
                ),
                onTap: () {
                  // 항목 클릭 시 TalkScreen으로 이동하며 tid 전달
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TalkScreen(
                        token: widget.token, // SearchScreen에서 받은 토큰 전달
                        tid: result['tid'], // 선택된 항목의 tid 전달
                        tlid: result['tlid'],
                        locationName: result['locationName'],
                        address: result['address'],
                      ),
                    ),
                  );
                },
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1, // 얇은 구분선 추가
              ),
            ],
          );
        },
      ),
    );
  }

  // 검색 바를 구현 (기존과 동일하나 더 길게 설정)
  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 검색 바를 화면의 90%로 설정
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 8),
          Icon(Icons.search, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              readOnly: true, // 사용자가 직접 입력하지 못하게 수정
              decoration: InputDecoration(
                hintText: widget.searchText,
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triptalk/screen/talk/talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드
  final String token; // 토큰을 전달받기 위한 필드 추가

  // 생성자에서 검색어와 토큰 받기
  SearchScreen({required this.searchText, required this.token});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(
                  token: widget.token, // SearchScreen에서 받은 토큰 전달
                  tid: 'some-tid', // 임의의 tid 전달
                ),
              ),
            );
          },
        ),
        title: _buildSearchBar(), // 사진과 비슷한 검색 바 구현
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.grey),
                title: Text(
                  result['locationName'],
                  style: TextStyle(
                    color: Colors.black, // 텍스트 색상을 검정색으로 변경
                    fontSize: 16, // 글씨 크기를 16으로 설정
                    fontWeight: FontWeight.bold, // 굵게 표시
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result['address'],
                      style: TextStyle(
                        color: Colors.grey, // 주소 색상을 회색으로 설정
                        fontSize: 14, // 글씨 크기를 14로 설정
                      ),
                    ),
                    SizedBox(height: 4), // 간격 추가
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "관광지분류",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12, // 작은 텍스트 크기
                          ),
                        ),
                        Text(
                          "거리 km",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12, // 작은 텍스트 크기
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  // 항목 클릭 시 TalkScreen으로 이동하며 tid 전달
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TalkScreen(
                        token: widget.token, // SearchScreen에서 받은 토큰 전달
                        tid: result['tid'], // 선택된 항목의 tid 전달
                        tlid: result['tlid'],
                        locationName: result['locationName'],
                        address: result['address'],
                      ),
                    ),
                  );
                },
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1, // 얇은 구분선 추가
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 8),
          Icon(Icons.search, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: widget.searchText,
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triptalk/screen/talk/talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드
  final String token; // 토큰을 전달받기 위한 필드 추가

  // 생성자에서 검색어와 토큰 받기
  SearchScreen({required this.searchText, required this.token});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
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
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(
                  token: widget.token, // SearchScreen에서 받은 토큰 전달
                  tid: 'some-tid', // 임의의 tid 전달
                ),
              ),
            );
          },
        ),
        title: Text(widget.searchText), // 검색어를 화면에 표시
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(
              result['locationName'],
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정색으로 변경
                fontSize: 16, // 글씨 크기를 16으로 설정
              ),
            ),
            subtitle: Text(
              result['address'],
              style: TextStyle(
                color: Colors.black, // 텍스트 색상을 검정색으로 변경
                fontSize: 14, // 글씨 크기를 14로 설정
              ),
            ),
            onTap: () {
              // 항목 클릭 시 TalkScreen으로 이동하며 tid 전달
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkScreen(
                    token: widget.token, // SearchScreen에서 받은 토큰 전달
                    tid: result['tid'], // 선택된 항목의 tid 전달
                    tlid: result['tlid'],
                    locationName: result['locationName'],
                    address: result['address'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/


///////

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triptalk/screen/talk/talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드
  final String token; // 토큰을 전달받기 위한 필드 추가

  // 생성자에서 검색어와 토큰 받기
  SearchScreen({required this.searchText, required this.token});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
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
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(
                  token: widget.token, // SearchScreen에서 받은 토큰 전달
                  tid: 'some-tid', // 임의의 tid 전달
                ),
              ),
            );
          },
        ),
        title: Text(widget.searchText), // 검색어를 화면에 표시
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(result['locationName']),
            subtitle: Text(result['address']),
            onTap: () {
              // 항목 클릭 시 TalkScreen으로 이동하며 tid 전달
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkScreen(
                      token: widget.token, // SearchScreen에서 받은 토큰 전달
                      tid: result['tid'], // 선택된 항목의 tid 전달
                      tlid: result['tlid'],
                      locationName:result['locationName'],
                      address:result['address']
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

*/

///////////////////////////

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triptalk/screen/talk/talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드
  final String token; // 토큰을 전달받기 위한 필드 추가

  // 생성자에서 검색어와 토큰 받기
  SearchScreen({required this.searchText, required this.token});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
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
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(
                  token: widget.token, // SearchScreen에서 받은 토큰 전달
                  locationName: 'Some Location', // 임의의 장소 이름
                  address: 'Some Address', // 임의의 주소
                ),
              ),
            );
          },
        ),
        title: Text(widget.searchText), // 검색어를 화면에 표시
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(result['locationName']),
            subtitle: Text(result['address']),
            onTap: () {
              // 항목 클릭 시 TalkScreen으로 이동하며 해당 결과의 데이터를 전달
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkScreen(
                    token: widget.token, // SearchScreen에서 받은 토큰 전달
                    locationName: result['locationName'], // 선택된 장소 이름 전달
                    address: result['address'], // 선택된 주소 전달
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

*/


//////////////////

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드

  SearchScreen({required this.searchText}); // 생성자에서 검색어 받기

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
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
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(token: 'your-token-here'), // TalkScreen으로 복귀 시 토큰 전달
              ),
            );
          },
        ),
        title: Text(widget.searchText), // 검색어를 화면에 표시
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(result['locationName']),
            subtitle: Text(result['address']),
            onTap: () {
              // 항목 클릭 시 TalkScreen으로 이동하며 해당 결과의 데이터를 전달
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkScreen(
                    token: 'your-token-here', // 토큰 전달
                    locationName: result['locationName'], // 선택된 장소 이름 전달
                    address: result['address'], // 선택된 주소 전달
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

*/

/////////////////

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드

  SearchScreen({required this.searchText}); // 생성자에서 검색어 받기

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      //final data = json.decode(response.body)['data'];
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
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
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(token: 'your-token-here'), // TalkScreen으로 복귀 시 토큰 전달
              ),
            );
          },
        ),
        title: Text(widget.searchText), // 검색어를 화면에 표시
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(result['locationName']),
            subtitle: Text(result['address']),
          );
        },
      ),
    );
  }
}
*/

//////////////////

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatefulWidget {
  final String searchText; // 검색어를 전달받기 위한 필드

  SearchScreen({required this.searchText}); // 생성자에서 검색어 받기

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults(widget.searchText);
  }

  Future<void> fetchSearchResults(String keyword) async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/search?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        searchResults = data;
        isLoading = false;
      });
    } else {
      // 오류 처리
      print('Failed to fetch search results: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(token: 'your-token-here'), // TalkScreen으로 복귀 시 토큰 전달
              ),
            );
          },
        ),
        title: Text(widget.searchText), // 검색어를 화면에 표시
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
          ? Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(result['locationName']),
            subtitle: Text(result['address']),
          );
        },
      ),
    );
  }
}
*/

////////////////////////

/*
import 'package:flutter/material.dart';
import 'talk_screen.dart'; // TalkScreen을 불러옵니다.

class SearchScreen extends StatelessWidget {
  final String searchText; // 검색어를 전달받기 위한 필드

  SearchScreen({required this.searchText}); // 생성자에서 검색어 받기

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // TalkScreen으로 돌아가기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TalkScreen(token: 'your-token-here'), // TalkScreen으로 복귀 시 토큰 전달
              ),
            );
          },
        ),
        title: Text(searchText), // 검색어를 화면에 표시
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('감천문화마을'),
            subtitle: Text('부산광역시 사하구 감내1로 200'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('감천항'),
            subtitle: Text('부산광역시 사하구 구평동'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('감천사거리'),
            subtitle: Text('부산광역시 사하구 감천동'),
          ),
        ],
      ),
    );
  }
}

*/