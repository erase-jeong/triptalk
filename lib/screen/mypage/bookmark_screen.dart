import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookmarkScreen extends StatefulWidget {
  final String token; // Token for authentication

  BookmarkScreen({required this.token});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<dynamic> bookmarks = [];
  bool isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    fetchBookmarks(); // 초기화 시 북마크 데이터를 가져옴
  }

  Future<void> fetchBookmarks() async {
    setState(() {
      isLoading = true; // 데이터를 가져올 때 로딩 상태로 전환
    });

    try {
      final response = await http.get(
        Uri.parse('https://triptalk.store/v1/bookmarks'),
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Token required for the request
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          bookmarks = data;
          isLoading = false; // 데이터를 성공적으로 가져온 후 로딩 완료
        });
      } else {
        print('Failed to fetch bookmarks: ${response.statusCode}');
        setState(() {
          bookmarks = [];
          isLoading = false; // 오류 발생 시에도 로딩 종료
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        bookmarks = [];
        isLoading = false; // 네트워크 오류 발생 시에도 로딩 종료
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
        title: Text('북마크'),
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
            : bookmarks.isEmpty
            ? Center(child: Text('북마크가 없습니다.')) // 북마크가 없을 때
            : ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder (or actual image if URL is provided)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                      image: bookmark['imageUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(bookmark['imageUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Bookmark details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        //bookmark['locationName'] ?? 'No Name',
                        utf8.decode(bookmark['locationName'].toString().runes.toList())??'No Name',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),

                    ],
                  ),
                  Spacer(),
                  // Bookmark time
                  Text(
                    bookmark['bookmarkTime'] != null
                        ? bookmark['bookmarkTime'].split('T').first
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

/////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookmarkScreen extends StatefulWidget {
  final String token; // Token for authentication

  BookmarkScreen({required this.token}); // 생성자에서 토큰을 받음

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<dynamic> bookmarks = [];

  @override
  void initState() {
    super.initState();
    fetchBookmarks(); // 초기화 시 북마크 데이터를 가져옴
  }

  Future<void> fetchBookmarks() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/bookmarks'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        bookmarks = data;
      });
    } else {
      print('Failed to fetch bookmarks: ${response.statusCode}');
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
            Navigator.pop(context); // 뒤로 가기 버튼
          },
        ),
        title: Text('북마크'),
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
        child: bookmarks.isNotEmpty
            ? ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder (or actual image if URL is provided)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                      image: bookmark['imageUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(bookmark['imageUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Bookmark details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark['locationName'] ?? 'No Name',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        bookmark['locationAddress'] ?? 'No Address',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Bookmark time
                  Text(
                    bookmark['bookmarkTime'] != null
                        ? bookmark['bookmarkTime'].split('T').first
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
        )
            : Center(
          child: CircularProgressIndicator(), // 데이터 로딩 중
        ),
      ),
    );
  }
}
*/

////////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookmarkScreen extends StatefulWidget {
  final String token; // Token for authentication

  BookmarkScreen({required this.token});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<dynamic> bookmarks = [];

  @override
  void initState() {
    super.initState();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    final response = await http.get(
      Uri.parse('https://triptalk.store/v1/bookmarks'),
      headers: {
        'Authorization': 'Bearer ${widget.token}', // Token required for the request
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        bookmarks = data;
      });
    } else {
      print('Failed to fetch bookmarks: ${response.statusCode}');
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
        title: Text('북마크'),
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
        child: bookmarks.isNotEmpty
            ? ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder (or actual image if URL is provided)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                      image: bookmark['imageUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(bookmark['imageUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Bookmark details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark['locationName'] ?? 'No Name',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        bookmark['locationAddress'] ?? 'No Address',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Bookmark time
                  Text(
                    bookmark['bookmarkTime'] != null
                        ? bookmark['bookmarkTime'].split('T').first
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
        )
            : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

*/

//////////////////////////////////


/*
import 'package:flutter/material.dart';

class BookmarkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('북마크'),
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
        child: Column(
          children: [
            // Single Bookmark Item
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 16),
                // Bookmark Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '관광지명', // Placeholder for name
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '관광지주소', // Placeholder for address
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Placeholder for bookmark action
                Text(
                  '북마크 날짜',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

*/