
/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName;
  final String address;

  TalkScreen({
    required this.token,
    this.tid = '',
    this.tlid = '',
    this.locationName = '',
    this.address = '',
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  String selectedLocation = ''; // 검색된 장소 이름
  String selectedAddress = ''; // 검색된 장소 주소

  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");
    print("[TalkScreen] tid: ${widget.tid}");
    print("[TalkScreen] tlid: ${widget.tlid}");
    print("[TalkScreen] locationName: ${widget.locationName}");
    print("[TalkScreen] address: ${widget.address}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),
          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 검색 결과가 있으면 하단바 표시
          if (selectedLocation.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomInfoBar(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              // 여기는 검색을 위한 로직 - 검색 결과에 따라 장소를 하단에 표시합니다.
              // 이 부분은 기존의 SearchScreen과의 연동 로직을 그대로 유지합니다.
              setState(() {
                // 검색 결과가 나왔다고 가정한 하드코딩된 예시입니다.
                selectedLocation = "남산타워";
                selectedAddress = "서울특별시 용산구 남산공원길 105";
              });
            },
          ),
        ],
      ),
    );
  }

  // 검색 결과가 나오면 하단에 locationName, 가이드, 경로탐색 버튼이 있는 하단바 표시
  Widget _buildBottomInfoBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedLocation, // 검색된 장소 이름
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            selectedAddress, // 검색된 장소 주소
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showRouteAlert,
                  child: Image.asset(
                    'assets/images/triptalk/routeGuidanceBtn.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _toggleGuideMessage,
                  child: Image.asset(
                    'assets/images/triptalk/guideBtn.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  // 경로 안내 알림창
  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('경로 안내', style: TextStyle(color: Colors.black)),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 가이드 기능 호출
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutoGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/autoGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/manunalGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:triptalk/screen/talk/search_screen.dart';

class TalkScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName;
  final String address;

  TalkScreen({
    required this.token,
    this.tid = '',
    this.tlid = '',
    this.locationName = '',
    this.address = '',
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  String selectedLocation = ''; // 검색된 장소 이름
  String selectedAddress = ''; // 검색된 장소 주소

  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");
    print("[TalkScreen] tid: ${widget.tid}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),
          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 검색 결과가 있으면 하단바 표시
          if (selectedLocation.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomInfoBar(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              // 검색 결과를 받으면 하단바에 장소명과 버튼들 표시
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText,
                    token: widget.token,
                    onLocationSelected: (location, address) {
                      setState(() {
                        selectedLocation = location;
                        selectedAddress = address;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 검색 결과가 나오면 하단에 locationName, 가이드, 경로탐색 버튼이 있는 하단바 표시
  Widget _buildBottomInfoBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedLocation, // 검색된 장소 이름
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            selectedAddress, // 검색된 장소 주소
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showRouteAlert,
                  child: Image.asset(
                    'assets/images/triptalk/routeGuidanceBtn.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _toggleGuideMessage,
                  child: Image.asset(
                    'assets/images/triptalk/guideBtn.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  // 경로 안내 알림창
  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('경로 안내', style: TextStyle(color: Colors.black)),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 가이드 기능 호출
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutoGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/autoGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/manunalGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

/////////



/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:triptalk/screen/talk/search_screen.dart';

class TalkScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName;
  final String address;

  TalkScreen({
    required this.token,
    this.tid = '',
    this.tlid = '',
    this.locationName = '',
    this.address = '',
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool showBottomSheet = false;

  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");
    print("[TalkScreen] tid: ${widget.tid}");
    print("[TalkScreen] tlid: ${widget.tlid}");
    print("[TalkScreen] locationName: ${widget.locationName}");
    print("[TalkScreen] address: ${widget.address}");

    if (widget.tid.isNotEmpty) {
      // Show bottom sheet only if there's a valid search result (tid, tlid)
      showBottomSheet = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk Screen'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),
          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // Bottom sheet showing search results (similar to second screenshot)
          if (showBottomSheet)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildSearchResultBottomSheet(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(fileText,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText,
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  Widget _buildSearchResultBottomSheet() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.locationName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.address,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: _showRouteAlert,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  '경로 안내',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: _toggleGuideMessage,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  '가이드',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('경로 안내', style: TextStyle(color: Colors.black)),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutoGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/autoGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/manualGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:triptalk/screen/talk/search_screen.dart';

class TalkScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName;
  final String address;

  TalkScreen({
    required this.token,
    this.tid = '',
    this.tlid = '',
    this.locationName = '',
    this.address = '',
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool showBottomSheet = false;

  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");
    print("[TalkScreen] tid: ${widget.tid}");
    print("[TalkScreen] tlid: ${widget.tlid}");
    print("[TalkScreen] locationName: ${widget.locationName}");
    print("[TalkScreen] address: ${widget.address}");

    if (widget.tid.isNotEmpty) {
      // Show bottom sheet only if there's a valid search result (tid, tlid)
      showBottomSheet = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),
          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // Bottom sheet showing search results (similar to second screenshot)
          if (showBottomSheet)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildSearchResultBottomSheet(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(fileText,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText,
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  Widget _buildSearchResultBottomSheet() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.locationName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.address,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: _showRouteAlert,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  '경로 안내',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: _toggleGuideMessage,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  '가이드',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('경로 안내', style: TextStyle(color: Colors.black)),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutoGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/autoGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/manualGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:triptalk/screen/talk/search_screen.dart';

class TalkScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName;
  final String address;
  final String imageUrl; // URL or asset path for the image

  TalkScreen({
    required this.token,
    this.tid = '',
    this.tlid = '',
    this.locationName = '',
    this.address = '',
    this.imageUrl = '', // Add default empty image path if none is provided
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool showBottomSheet = false;
  bool isBookmarked = false; // For bookmark toggle

  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");
    print("[TalkScreen] tid: ${widget.tid}");
    print("[TalkScreen] tlid: ${widget.tlid}");
    print("[TalkScreen] locationName: ${widget.locationName}");
    print("[TalkScreen] address: ${widget.address}");

    if (widget.tid.isNotEmpty) {
      // Show bottom sheet only if there's a valid search result (tid, tlid)
      showBottomSheet = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),
          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // Bottom sheet showing search results (similar to first screenshot)
          if (showBottomSheet)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildSearchResultBottomSheet(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(fileText,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText,
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  Widget _buildSearchResultBottomSheet() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.imageUrl.isNotEmpty
                    ? Image.asset(
                  widget.imageUrl, // If it's an asset image
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  'https://via.placeholder.com/80', // Placeholder if imageUrl is empty
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: 60.0, // Adjust the size as needed
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],  // Placeholder color
                  borderRadius: BorderRadius.circular(8.0),
                  image: widget.imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,  // Default image if 'imageUrl' is null
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.locationName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.address,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              // Bookmark icon
              IconButton(
                icon: isBookmarked
                    ? Image.asset('assets/images/surroundingIcon/bookmarkFull.png')
                    : Image.asset('assets/images/surroundingIcon/bookmarkEmpty.png'),
                onPressed: _toggleBookmark,
              ),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: _showRouteAlert,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  '경로 안내',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: _toggleGuideMessage,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  '가이드',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 북마크 토글 기능
  void _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('경로 안내', style: TextStyle(color: Colors.black)),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutoGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/autoGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/triptalk/manualGuideBtn.png',
                        height: 80, // 이미지의 높이를 더 크게 설정
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:triptalk/screen/talk/search_screen.dart';

class TalkScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName;
  final String address;

  TalkScreen({
    required this.token,
    this.tid = '',
    this.tlid = '',
    this.locationName = '',
    this.address = '',
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool showBottomSheet = false;
  bool isBookmarked = false; // For bookmark toggle
  String imageUrl = ''; // Image URL from API
  String weather='';
  String temperature='';
  int? locationId;


  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");
    print("[TalkScreen] tid: ${widget.tid}");
    print("[TalkScreen] tlid: ${widget.tlid}");
    print("[TalkScreen] locationName: ${widget.locationName}");
    print("[TalkScreen] address: ${widget.address}");

    // Make the API call to fetch imageUrl and bookmark status
    if (widget.tid.isNotEmpty && widget.tlid.isNotEmpty) {
      fetchLocationDetails(widget.tid, widget.tlid);
    }
  }

  // Function to fetch location details from API
  Future<void> fetchLocationDetails(String tid, String tlid) async {
    final url = 'https://triptalk.store/v1/locations?tid=$tid&tlid=$tlid';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      //final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final locationData = jsonResponse['data'];
      //final locationData = json.decode(response.body)['data'];

      setState(() {
        imageUrl = locationData['imageUrl'] ?? ''; // Set imageUrl
        isBookmarked = locationData['bookmarked'] ?? false; // Set bookmarked status
        showBottomSheet = true; // Show bottom sheet when data is available
        weather = locationData['weather'] ?? ''; // Set weather
        temperature = locationData['temperature']?.toString() ?? ''; //
        locationId = locationData['locationId'];
      });
    } else {
      print('Failed to fetch location details: ${response.statusCode}');
    }
  }

  // 북마크 추가 API 호출 함수
  Future<void> addBookmark(int locationId) async {
    final url = 'https://triptalk.store/v1/bookmarks/$locationId';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Bookmark added successfully');
    } else {
      print('Failed to add bookmark');
    }
  }


  // 북마크 삭제 API 호출 함수
  Future<void> deleteBookmark(int locationId) async {
    final url = 'https://triptalk.store/v1/bookmarks/$locationId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Bookmark deleted successfully');
    } else {
      print('Failed to delete bookmark');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),
          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // Bottom sheet showing search results with imageUrl
          if (showBottomSheet)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildSearchResultBottomSheet(),
            ),
        ],
      ),

    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(fileText,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText,
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  Widget _buildSearchResultBottomSheet() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl, // Display imageUrl if provided
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey, // 빈 회색 네모
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.locationName,
                        style: TextStyle(fontSize: 26, color: Color(0xFF539162), fontFamily: 'HSSantokki'),
                      ),
                      Text(
                        widget.address,
                        style: TextStyle(fontSize: 16, fontFamily: 'Pretendard', color: Colors.black),
                      ),
                      // 날씨와 기온을 더 오른쪽으로 정렬
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                        children: [
                          Spacer(),
                          Padding( // Padding으로 더 오른쪽에 여백 추가
                            padding: const EdgeInsets.only(right: 0.0), // 원하는 만큼의 여백 설정
                            child: Row(
                              children: [
                                Text(
                                  "날씨: $weather", // Display weather
                                  style: TextStyle(fontSize: 14, color: Color(0xFF3F3F3F)),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "기온: $temperature°C", // Display temperature
                                  style: TextStyle(fontSize: 14, color: Color(0xFF3F3F3F)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),



              IconButton(
                icon: isBookmarked
                    ? Image.asset(
                  'assets/images/surroundingIcon/bookmarkFull.png',
                  width: 24.0,
                  height: 24.0,
                )
                    : Image.asset(
                  'assets/images/surroundingIcon/bookmarkEmpty.png',
                  width: 24.0,
                  height: 24.0,
                ),
                onPressed: _toggleBookmark, // 북마크 토글 함수 연결
              ),

              /*
              // Bookmark icon
              IconButton(
                icon: isBookmarked
                    ? Image.asset(
                  'assets/images/surroundingIcon/bookmarkFull.png',
                  width: 24.0,  // 원하는 너비
                  height: 24.0, // 원하는 높이
                )
                    : Image.asset(
                  'assets/images/surroundingIcon/bookmarkEmpty.png',
                  width: 24.0,  // 원하는 너비
                  height: 24.0, // 원하는 높이
                ),
                onPressed: _toggleBookmark,
              ),

              */
            ],
          ),
          Spacer(),
          // The rest of the bottom sheet remains the same
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: _showRouteAlert, // Attach the same function for this button
                child: Image.asset(
                  'assets/images/triptalk/routeGuidanceBtn.png', // Use the image for the button
                  height: 80, // Adjust the height if needed
                  fit: BoxFit.contain,
                ),
              ),
              GestureDetector(
                onTap: _toggleGuideMessage, // Attach the same function for this button
                child: Image.asset(
                  'assets/images/triptalk/guideBtn.png', // Use the image for the button
                  height: 80, // Adjust the height if needed
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// 북마크 토글 기능
  void _toggleBookmark() async {
    setState(() {
      isBookmarked = !isBookmarked;
    });

    // 북마크가 추가되었는지에 따라 API 호출
    if (isBookmarked) {
      await addBookmark(locationId!);
      //await addBookmark(int.parse(widget.locationId));  // tid나 tlid를 사용하여 북마크 추가
    } else {
      await deleteBookmark(locationId!);
      //await deleteBookmark(int.parse(widget.locationId));  // tid나 tlid를 사용하여 북마크 삭제
    }
  }
  /*
  // 북마크 토글 기능
  void _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }
  */

  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('경로 안내', style: TextStyle(color: Colors.black)),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Stack(
            children: [
              // 첫 번째 이미지: 왼쪽 상단 배치
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AutoGuideScreen(
                            token: widget.token,
                            tid: widget.tid,
                            tlid: widget.tlid),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/triptalk/autoGuideBtn.png',
                    height: 100, // 원하는 크기로 조정
                    //width: 300.0,  // 원하는 너비
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // 두 번째 이미지: 오른쪽 하단 배치
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManualGuideScreen(
                            token: widget.token,
                            tid: widget.tid,
                            tlid: widget.tlid),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/triptalk/manunalGuideBtn.png',
                    height: 100, // 원하는 크기로 조정
                    //width: 300.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}


//////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:triptalk/screen/talk/search_screen.dart';

class TalkScreen extends StatefulWidget {
  final String token;
  final String tid;
  final String tlid;
  final String locationName;
  final String address;

  TalkScreen({
    required this.token,
    this.tid = '',
    this.tlid = '',
    this.locationName = '',
    this.address = '',
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");
    print("[TalkScreen] tid: ${widget.tid}");
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        Widget page = _buildTalkHome(); // 기본 Talk 화면

        if (settings.name == '/auto') {
          page = AutoGuideScreen(token: widget.token);
        } else if (settings.name == '/manual') {
          page = ManualGuideScreen(token: widget.token);
        }

        return MaterialPageRoute(builder: (context) => page);
      },
    );
  }

  Widget _buildTalkHome() {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),
          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 트립톡톡 버튼을 지도 위에 겹치도록 배치 (아래쪽에 위치, tid 값이 있을 때만)
          if (widget.tid.isNotEmpty)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _showBottomSheet,
                child: Text("${widget.locationName} 안내받기",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText,
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.locationName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showRouteAlert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('경로 안내', style: TextStyle(color: Colors.black)),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutoGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualGuideScreen(
                                token: widget.token,
                                tid: widget.tid,
                                tlid: widget.tlid),
                          ),
                        );
                      },
                      child: _buildGuideOption(
                        '토커 마음대로 관광을 즐기고 싶다면',
                        '수동 가이드',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.green[900])),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}

*/

//////////


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:triptalk/screen/talk/auto_screen.dart';
import 'package:triptalk/screen/talk/manual_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:triptalk/screen/talk/search_screen.dart';

//import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid; // tid 전달받기 위한 필드 추가
  final String tlid;
  final String locationName; // Location Name
  final String address; // Address

  // 생성자에서 토큰, tid, locationName, address 받기
  TalkScreen({
    required this.token,
    this.tid = '', // 선택적인 필드로 설정, 기본값은 빈 문자열
    this.tlid = '',
    this.locationName = '', // Default empty string
    this.address = '', // Default empty string
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    print("[TalkScreen] token: ${widget.token}");  // 추가된 부분
    print("[TalkScreen] tid: ${widget.tid}");      // 기존 코드
    //print("[talk_screen] tid: ${widget.tid}"); // 전달받은 tid 값을 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),

          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),

          /*
          //test용 버튼
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: ElevatedButton(
            onPressed: () {
              // 버튼이 눌렸을 때 실행되는 코드
              print('Button Pressed!');
              print("[TalkScreen] token: ${widget.token}");
            },
            child: Text('Click Me'),
          ),
          ),
          */

          // 트립톡톡 버튼을 지도 위에 겹치도록 배치 (아래쪽에 위치, tid 값이 있을 때만)
          if (widget.tid.isNotEmpty) // tid가 빈 문자열이 아닌 경우에만 버튼을 표시
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                child: Text(widget.locationName+" 안내받기",
                  style:TextStyle(color:Colors.white)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle( // 여기서 텍스트 색상을 변경합니다.
                color: Colors.black, // 입력 텍스트의 색상을 검정색으로 설정
                fontSize: 16, // 필요에 따라 글씨 크기도 설정 가능
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                    token: widget.token, // token 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Talk Screen 에서의 Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 바텀 시트의 내용 구성
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location 정보 컨테이너
          Row(
            children: [
              // 이미지나 아이콘 자리 (임의로 배경색을 넣어줌)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[200], // 사진처럼 연한 녹색 배경
                  borderRadius: BorderRadius.circular(12), // 둥근 모서리
                ),
              ),
              SizedBox(width: 16),
              // locationName과 address를 보여줌
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location name
                    Text(
                      widget.locationName, // SearchScreen에서 받은 locationName
                      style: TextStyle(
                        fontSize: 18, // 제목은 큰 글씨로
                        fontWeight: FontWeight.bold, // 굵은 글씨체
                        color: Colors.black, // 검정색 글씨
                      ),
                    ),
                    SizedBox(height: 4),
                    // Address
                    Text(
                      widget.address, // SearchScreen에서 받은 address
                      style: TextStyle(
                        fontSize: 14, // 주소는 작은 글씨로
                        color: Colors.black54, // 회색 글씨
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // 두 버튼 사이 공간
          Row(
            children: [
              // "경로 안내" 버튼
              Expanded(
                child: ElevatedButton(
                  /*onPressed: () {
                    // 경로 안내 기능 추가
                  },*/
                  onPressed: _showRouteAlert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              // "가이드" 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage, // 기존 가이드 메시지 기능
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRouteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 팝업창 배경색을 흰색으로 설정
          title: Text(
            '경로 안내',
            style: TextStyle(color: Colors.black), // 제목 글자를 검정색으로 설정
          ),
          content: Text(
            '이 기능은 개발중에 있습니다.',
            style: TextStyle(color: Colors.black), // 본문 글자를 검정색으로 설정
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '확인',
                style: TextStyle(color: Colors.black), // 버튼 글자를 검정색으로 설정
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업창 닫기
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGuideMessage() {
    // 가이드 메시지를 위한 함수 (기존 코드 유지)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                        // 자동 가이드 버튼을 눌렀을 때 AutoGuideScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutoGuideScreen(token: widget.token, tid: widget.tid, tlid: widget.tlid), // AutoGuideScreen으로 이동
                          ),
                        );
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                        // 자동 가이드 버튼을 눌렀을 때 AutoGuideScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualGuideScreen(token: widget.token, tid: widget.tid, tlid: widget.tlid), // AutoGuideScreen으로 이동
                          ),
                        );
                      },
                      child: _buildGuideOption(
                        '토커 마음대로 관광을 즐기고 싶다면',
                        '수동 가이드',
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.green[900]),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}

*/


//////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.
import 'package:http/http.dart' as http; // HTTP 패키지 추가
import 'package:triptalk/screen/talk/auto_screen.dart'

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid; // tid 전달받기 위한 필드 추가
  final String tlid;
  final String locationName; // Location Name
  final String address; // Address

  // 생성자에서 토큰, tid, locationName, address 받기
  TalkScreen({
    required this.token,
    this.tid = '', // 선택적인 필드로 설정, 기본값은 빈 문자열
    this.tlid = '',
    this.locationName = '', // Default empty string
    this.address = '', // Default empty string
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러
  bool _isBookmarked = false; // 북마크 상태를 저장할 변수

  @override
  void initState() {
    super.initState();
    print("[talk_screen] tid: ${widget.tid}"); // 전달받은 tid 값을 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),

          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),

          // 트립톡톡 버튼을 지도 위에 겹치도록 배치 (아래쪽에 위치, tid 값이 있을 때만)
          if (widget.tid.isNotEmpty) // tid가 빈 문자열이 아닌 경우에만 버튼을 표시
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                child: Text('트립톡톡'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                    token: widget.token, // token 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 바텀 시트의 내용 구성
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // X 아이콘과 북마크 아이콘을 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // X 아이콘 (닫기 기능)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // 바텀 시트 닫기
                },
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              // 북마크 아이콘
              GestureDetector(
                onTap: _toggleBookmark, // 북마크 상태 변경 및 API 연동
                child: Icon(

                  _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // X 아이콘과 콘텐츠 사이 공간 추가
          // Location 정보 컨테이너
          Row(
            children: [
              // 이미지나 아이콘 자리 (임의로 배경색을 넣어줌)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[200], // 사진처럼 연한 녹색 배경
                  borderRadius: BorderRadius.circular(12), // 둥근 모서리
                ),
              ),
              SizedBox(width: 16),
              // locationName과 address를 보여줌
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location name
                    Text(
                      widget.locationName, // SearchScreen에서 받은 locationName
                      style: TextStyle(
                        fontSize: 18, // 제목은 큰 글씨로
                        fontWeight: FontWeight.bold, // 굵은 글씨체
                        color: Colors.black, // 검정색 글씨
                      ),
                    ),
                    SizedBox(height: 4),
                    // Address
                    Text(
                      widget.address, // SearchScreen에서 받은 address
                      style: TextStyle(
                        fontSize: 14, // 주소는 작은 글씨로
                        color: Colors.black54, // 회색 글씨
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // 두 버튼 사이 공간
          Row(
            children: [
              // "경로 안내" 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 경로 안내 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              // "가이드" 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage, // 기존 가이드 메시지 기능
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 북마크 상태 변경 및 API 호출
  void _toggleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked; // 북마크 상태를 토글
      print('_isBookmarked 상태: $_isBookmarked'); // 로그로 상태 확인
    });

    // API 연동
    String url = 'https://yourapiurl.com/bookmark'; // 실제 API 주소로 변경
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'tid': widget.tid,
        'isBookmarked': _isBookmarked,
      }),
    );

    if (response.statusCode == 200) {
      print('Bookmark updated successfully');
    } else {
      print('Failed to update bookmark');
    }
  }

  void _toggleGuideMessage() {
    // 가이드 메시지 기능 추가
  }
}
*/

/////////


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid; // tid 전달받기 위한 필드 추가
  final String locationName; // Location Name
  final String address; // Address

  // 생성자에서 토큰, tid, locationName, address 받기
  TalkScreen({
    required this.token,
    this.tid = '', // 선택적인 필드로 설정, 기본값은 빈 문자열
    this.locationName = '', // Default empty string
    this.address = '', // Default empty string
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    print("[talk_screen] tid: ${widget.tid}"); // 전달받은 tid 값을 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움
          Positioned.fill(
            child: Container(
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),

          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),

          // 트립톡톡 버튼을 지도 위에 겹치도록 배치 (아래쪽에 위치, tid 값이 있을 때만)
          if (widget.tid.isNotEmpty) // tid가 빈 문자열이 아닌 경우에만 버튼을 표시
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                child: Text('트립톡톡'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                    token: widget.token, // token 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }


// 바텀 시트의 내용 구성
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠에 맞게 크기 조정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // X 아이콘과 북마크 아이콘을 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // X 아이콘 (닫기 기능)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // 바텀 시트 닫기
                },
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              // 북마크 아이콘
              GestureDetector(
                onTap: () {
                  // 북마크 추가 기능 구현
                },
                child: Icon(
                  Icons.bookmark_outline,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // X 아이콘과 콘텐츠 사이 공간 추가
          // Location 정보 컨테이너
          Row(
            children: [
              // 이미지나 아이콘 자리 (임의로 배경색을 넣어줌)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[200], // 사진처럼 연한 녹색 배경
                  borderRadius: BorderRadius.circular(12), // 둥근 모서리
                ),
              ),
              SizedBox(width: 16),
              // locationName과 address를 보여줌
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location name
                    Text(
                      widget.locationName, // SearchScreen에서 받은 locationName
                      style: TextStyle(
                        fontSize: 18, // 제목은 큰 글씨로
                        fontWeight: FontWeight.bold, // 굵은 글씨체
                        color: Colors.black, // 검정색 글씨
                      ),
                    ),
                    SizedBox(height: 4),
                    // Address
                    Text(
                      widget.address, // SearchScreen에서 받은 address
                      style: TextStyle(
                        fontSize: 14, // 주소는 작은 글씨로
                        color: Colors.black54, // 회색 글씨
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // 두 버튼 사이 공간
          Row(
            children: [
              // "경로 안내" 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 경로 안내 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              // "가이드" 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage, // 기존 가이드 메시지 기능
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }






  void _toggleGuideMessage() {
    // 가이드 메시지를 위한 함수 (기존 코드 유지)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildGuideOption(
                      '토커 마음대로 관광을 즐기고 싶다면',
                      '수동 가이드',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }




  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.green[900]),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}

*/


//////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid; // tid 전달받기 위한 필드 추가
  final String locationName; // Location Name
  final String address; // Addres

  // 생성자에서 토큰과 tid 받기
  TalkScreen({
    required this.token,
    this.tid = '', // 선택적인 필드로 설정, 기본값은 빈 문자열
    this.locationName = '', // Default empty string
    this.address = '', // Default empty string
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    print("[talk_screen] tid: ${widget.tid}"); // 전달받은 tid 값을 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면 전체에 꽉 채움

      /*
          Positioned.fill(
            child: WebView(
              initialUrl: 'about:blank',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
                _loadHtmlFromAssets();
              },
            ),
          ),
          */


          Positioned.fill(
            child: Container(
              //color: Colors.red.withOpacity(0.3),  // 임시 배경색으로 영역 확인
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            ),
          ),



          // 검색창을 지도 위에 겹치도록 배치 (위쪽에 위치)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 트립톡톡 버튼을 지도 위에 겹치도록 배치 (아래쪽에 위치, tid 값이 있을 때만)
          if (widget.tid.isNotEmpty) // tid가 빈 문자열이 아닌 경우에만 버튼을 표시
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                child: Text('트립톡톡'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                    token: widget.token, // token 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Colors.green[200],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '11.7 km', // 임의 거리 정보
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 경로 안내 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildGuideOption(
                      '토커 마음대로 관광을 즐기고 싶다면',
                      '수동 가이드',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.green[900]),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}
*/


//////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid; // tid 전달받기 위한 필드 추가

  // 생성자에서 토큰과 tid 받기
  TalkScreen({
    required this.token,
    this.tid = '', // 선택적인 필드로 설정, 기본값은 빈 문자열
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    print("[talk_screen] tid: ${widget.tid}"); // 전달받은 tid 값을 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          // 검색창을 지도 위에 겹치도록 배치
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치 (tid 값이 있을 때만)
          if (widget.tid.isNotEmpty) // tid가 빈 문자열이 아닌 경우에만 버튼을 표시
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                child: Text('트립톡톡'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                    token: widget.token, // token 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Colors.green[200],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '11.7 km', // 임의 거리 정보
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 경로 안내 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildGuideOption(
                      '토커 마음대로 관광을 즐기고 싶다면',
                      '수동 가이드',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.green[900]),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}

*/


/////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String tid; // tid 전달받기 위한 필드 추가

  // 생성자에서 토큰과 tid 받기
  TalkScreen({
    required this.token,
    //required this.tid,
    this.tid='', //선택적인 필드로 설정, 기본값은 빈 문자열
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    print("[talk_screen] tid: ${widget.tid}"); // 전달받은 tid 값을 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          // 검색창을 지도 위에 겹치도록 배치
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                    token: widget.token, // token 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Colors.green[200],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '11.7 km', // 임의 거리 정보
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 경로 안내 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildGuideOption(
                      '토커 마음대로 관광을 즐기고 싶다면',
                      '수동 가이드',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.green[900]),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}


*/

/////////////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가
  final String locationName; // 장소 이름 전달받기 위한 필드 추가
  final String address; // 주소 전달받기 위한 필드 추가
  final String tid;

  // 생성자에서 토큰, 장소 이름, 주소 받기
  TalkScreen({
    required this.token,
    required this.locationName,
    required this.address,
    final String tid;
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    print("[talk_screen] tid: ${widget.tid}"); // tid 값을 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면에 꽉 채움
          WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          // 검색창을 지도 위에 겹치도록 배치
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 검색창 빌드
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 하단 시트 컨텐츠 빌드
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Colors.green[200],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.locationName, // 전달받은 장소 이름 표시
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.address, // 전달받은 주소 표시
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '11.7 km', // 임의 거리 정보
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 경로 안내 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildGuideOption(
                      '토커 마음대로 관광을 즐기고 싶다면',
                      '수동 가이드',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 옵션 위젯
  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.green[900]),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}

*/

////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가

  TalkScreen({required this.token}); // 생성자에서 토큰 받기

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면에 꽉 채움
          WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          // 검색창을 지도 위에 겹치도록 배치
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 검색창 빌드
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Expanded(
            child: TextField(
              controller: _searchController, // 검색창 입력 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '장소, 관광지 검색',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {
              String searchText = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchText: searchText, // 검색어 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 하단 시트 보여주기
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _buildBottomSheetContent();
      },
    );
  }

  // 하단 시트 컨텐츠 빌드
  Widget _buildBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Colors.green[200],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감천문화마을',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '부산광역시 사하구 감내1로 200 (감천동)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '11.7 km',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 경로 안내 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('경로 안내'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleGuideMessage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '가이드',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: _buildGuideOption(
                        '트립톡의 추천 경로를 이용한다면',
                        '자동 가이드',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildGuideOption(
                      '토커 마음대로 관광을 즐기고 싶다면',
                      '수동 가이드',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 옵션 위젯
  Widget _buildGuideOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.green[900]),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }
}

*/

//////////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_screen.dart'; // search_screen.dart를 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가

  TalkScreen({required this.token}); // 생성자에서 토큰 받기

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController(); // 검색창 입력 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도를 화면에 꽉 채움
          WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          // 검색창을 지도 위에 겹치도록 배치
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                  Expanded(
                    child: TextField(
                      controller: _searchController, // 검색창 입력 컨트롤러 연결
                      decoration: InputDecoration(
                        hintText: '장소, 관광지 검색',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.green),
                    onPressed: () {
                      String searchText = _searchController.text;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            searchText: searchText, // 검색어 전달
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '트립톡의 추천 경로를 이용한다면',
                              style: TextStyle(color: Colors.green[900]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '자동 가이드',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '토커 마음대로 관광을 즐기고 싶다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '수동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

////////////////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가

  TalkScreen({required this.token}); // 생성자에서 토큰 받기

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 제거
      body: Stack(
        children: [
          // 지도를 화면에 꽉 채움
          WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          // 검색창을 지도 위에 겹치도록 배치
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '장소, 관광지 검색', // Placeholder
                        hintStyle: TextStyle(
                          color: Colors.grey, // Placeholder 텍스트 색상 설정
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.green),
                ],
              ),
            ),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
    // TODO: 네트워크 요청 시 토큰을 여기에 사용
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage, // 가이드 메시지 토글
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 왼쪽 말풍선: 자동 가이드
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '트립톡의 추천 경로를 이용한다면',
                              style: TextStyle(color: Colors.green[900]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '자동 가이드',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 오른쪽 말풍선: 수동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '토커 마음대로 관광을 즐기고 싶다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '수동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

*/


///////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가

  TalkScreen({required this.token}); // 생성자에서 토큰 받기

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 제거
      body: Stack(
        children: [
          // 지도를 화면에 꽉 채움
          WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          // 검색창을 지도 위에 겹치도록 배치
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '장소, 관광지 검색',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.green),
                ],
              ),
            ),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
    // TODO: 네트워크 요청 시 토큰을 여기에 사용
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage, // 가이드 메시지 토글
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 왼쪽 말풍선: 자동 가이드
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '트립톡의 추천 경로를 이용한다면',
                              style: TextStyle(color: Colors.green[900]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '자동 가이드',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 오른쪽 말풍선: 수동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '토커 마음대로 관광을 즐기고 싶다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '수동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

///////////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가

  TalkScreen({required this.token}); // 생성자에서 토큰 받기

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 제거
      body: Column(
        children: [
          // 지도를 화면에 꽉 채움
          Expanded(
            child: WebView(
              initialUrl: 'about:blank',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
                _loadHtmlFromAssets();
              },
            ),
          ),
          // 트립톡톡 버튼을 화면 아래에 배치
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
    // TODO: 네트워크 요청 시 토큰을 여기에 사용
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage, // 가이드 메시지 토글
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 왼쪽 말풍선: 자동 가이드
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 경로 안내 화면으로 이동하는 코드 추가
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '트립톡의 추천 경로를 이용한다면',
                              style: TextStyle(color: Colors.green[900]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '자동 가이드',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 오른쪽 말풍선: 수동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '토커 마음대로 관광을 즐기고 싶다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '수동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

//////////////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'TravelRouteScreen.dart'; // TravelRouteScreen을 불러옵니다.

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가

  TalkScreen({required this.token}); // 생성자에서 토큰 받기

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KakaoMap with WebView'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: WebView(
                  initialUrl: 'about:blank',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    _loadHtmlFromAssets();
                  },
                ),
              ),
              // 트립톡톡 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                  child: Text('트립톡톡'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
    // TODO: 네트워크 요청 시 토큰을 여기에 사용
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage, // 가이드 메시지 토글
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 왼쪽 말풍선: 자동 가이드
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TravelRouteScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '트립톡의 추천 경로를 이용한다면',
                              style: TextStyle(color: Colors.green[900]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '자동 가이드',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 오른쪽 말풍선: 수동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '토커 마음대로 관광을 즐기고 싶다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '수동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

*/

//////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  final String token; // 토큰을 전달받기 위한 필드 추가

  TalkScreen({required this.token}); // 생성자에서 토큰 받기

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    */
/*
      appBar: AppBar(
        title: Text('KakaoMap with WebView'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: WebView(
                  initialUrl: 'about:blank',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    _loadHtmlFromAssets();
                  },
                ),
              ),
              // 트립톡톡 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                  child: Text('트립톡톡'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }

    // 토큰 출력 (네트워크 요청 등에 사용 가능)
    print('Token: ${widget.token}');
    // TODO: 네트워크 요청 시 토큰을 여기에 사용
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage, // 가이드 메시지 토글
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 왼쪽 말풍선: 자동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '트립톡의 추천 경로를 이용한다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '자동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 오른쪽 말풍선: 수동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '토커 마음대로 관광을 즐기고 싶다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '수동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KakaoMap with WebView'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: WebView(
                  initialUrl: 'about:blank',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    _loadHtmlFromAssets();
                  },
                ),
              ),
              // 트립톡톡 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                  child: Text('트립톡톡'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage, // 가이드 메시지 토글
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 왼쪽 말풍선: 자동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '트립톡의 추천 경로를 이용한다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '자동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 오른쪽 말풍선: 수동 가이드
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '토끼 마을대로 관광을 즐기고 싶다면',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '수동 가이드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;
  bool _showGuideMessage = false; // 가이드 메시지 표시 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KakaoMap with WebView'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: WebView(
                  initialUrl: 'about:blank',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    _loadHtmlFromAssets();
                  },
                ),
              ),
              // 트립톡톡 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
                  child: Text('트립톡톡'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          // 가이드 버튼을 클릭하면 나타나는 말풍선 메시지
          if (_showGuideMessage) _buildGuideMessage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  // HTML 파일 불러오기
  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  // 마커 추가
  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleGuideMessage, // 가이드 메시지 토글
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 가이드 메시지 표시/숨기기 토글
  void _toggleGuideMessage() {
    setState(() {
      _showGuideMessage = !_showGuideMessage;
    });
  }

  // 가이드 메시지를 표시하는 위젯
  Widget _buildGuideMessage() {
    return Positioned(
      bottom: 80,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(16),
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
            Icon(Icons.chat_bubble, color: Colors.green),
            SizedBox(width: 10),
            Text(
              '토끼마을로 가는 길을 안내합니다.',
              style: TextStyle(color: Colors.green[900], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
*/

////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KakaoMap with WebView'),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebView(
              initialUrl: 'about:blank',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
                _loadHtmlFromAssets();
              },
            ),
          ),
          // 트립톡톡 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showBottomSheet, // 버튼을 눌렀을 때 하단 바가 나옴
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }
  }

  // 새로운 버튼의 기능
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.green[200],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감천문화마을',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '부산광역시 사하구 감내1로 200 (감천동)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '11.7 km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 경로 안내 기능 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('경로 안내'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // 가이드 기능 추가
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '가이드',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
*/

////////////////

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KakaoMap with WebView'),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebView(
              initialUrl: 'about:blank',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
                _loadHtmlFromAssets();
              },
            ),
          ),
          // 새롭게 추가된 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showMessage, // 버튼 눌렀을 때 실행될 함수
              child: Text('트립톡톡'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }
  }

  // 새로운 버튼의 기능
  void _showMessage() {
    _controller.runJavascript('window.alert("지도 리셋 버튼이 눌렸습니다!");');
  }
}

*/

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KakaoMap with WebView'),
      ),
      body: WebView(
        initialUrl: 'about:blank',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _loadHtmlFromAssets();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarkers,
        child: Icon(Icons.add_location),
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(context)
        .loadString('assets/kakao_map.html');
    _controller.loadUrl(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  void _addMarkers() {
    List<Map<String, dynamic>> markers = [
      {"lat": 37.5665, "lng": 126.9780, "title": "Marker 1"},
      {"lat": 37.5651, "lng": 126.98955, "title": "Marker 2"},
    ];

    for (var marker in markers) {
      String message = jsonEncode(marker);
      _controller.runJavascript('window.postMessage($message)');
    }
  }
}
*/

/////


/*
import 'package:flutter/material.dart';
import 'package:flutter_kakao_map/flutter_kakao_map.dart';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  // 마커 목록을 저장할 리스트
  final List<MapMarker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  // 마커 데이터를 로드하는 함수
  void _loadMarkers() {
    // 임의의 위치에 마커 추가
    _markers.add(MapMarker(
      latitude: 37.5665,
      longitude: 126.9780,
      markerId: 'marker_1',
      infoWindowText: InfoWindowText('Marker 1', '서울'),
    ));
    _markers.add(MapMarker(
      latitude: 37.5651,
      longitude: 126.98955,
      markerId: 'marker_2',
      infoWindowText: InfoWindowText('Marker 2', '광화문'),
    ));
    // 다른 마커도 추가 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KakaoMap with Markers'),
      ),
      body: KakaoMap(
        center: LatLng(37.5665, 126.9780),
        zoomLevel: 3,
        markers: _markers,
      ),
    );
  }
}
*/

///////////

/*
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'dart:convert';

const String kakaoMapKey = 'f79cb56dc8cd8d007a9c4c541395f9d1'; // 카카오 API 키

class TalkScreen extends StatefulWidget {
  const TalkScreen({Key? key}) : super(key: key);

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  String? kakaoMapHtml;

  @override
  void initState() {
    super.initState();
    _loadKakaoMapHtml();
  }

  Future<void> _loadKakaoMapHtml() async {
    // 여기에 마커를 포함한 Kakao 지도 HTML을 추가
    String mapHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Kakao 지도</title>
        <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoMapKey"></script>
    </head>
    <body>
    <div id="map" style="width:100%;height:400px;"></div>
    <script>
      var mapContainer = document.getElementById('map'), // 지도를 표시할 div
          mapOption = {
              center: new kakao.maps.LatLng(35.0976, 129.0105), // 지도의 중심좌표 (감천문화마을)
              level: 3 // 지도의 확대 레벨
          };

      var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성

      // 마커가 표시될 위치입니다
      var markerPosition  = new kakao.maps.LatLng(35.0976, 129.0105);

      // 마커를 생성합니다
      var marker = new kakao.maps.Marker({
          position: markerPosition
      });

      // 마커가 지도 위에 표시되도록 설정합니다
      marker.setMap(map);
    </script>
    </body>
    </html>
    ''';

    setState(() {
      kakaoMapHtml = mapHtml;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kakao map webview with marker')),
      body: kakaoMapHtml == null
          ? Center(child: CircularProgressIndicator()) // HTML 로딩 중일 때
          : WebView(
        initialUrl: Uri.dataFromString(
            kakaoMapHtml!,
            mimeType: 'text/html',
            encoding: utf8 // utf8 사용
        ).toString(),
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';

const String kakaoMapKey = 'yourKey';

class TalkScreen extends StatefulWidget {
  const TalkScreen({Key? key}) : super(key: key);

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  String? kakaoMapUrl;

  @override
  void initState() {
    super.initState();
    _loadKakaoMapUrl();
  }

  Future<void> _loadKakaoMapUrl() async {
    KakaoMapUtil util = KakaoMapUtil();
    String url = await util.getMapScreenURL(35.0976, 129.0105, name: '감천문화마을');

    setState(() {
      kakaoMapUrl = url; // 비동기 호출 후 URL을 설정
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kakao map webview test')),
      body: kakaoMapUrl == null
          ? Center(child: CircularProgressIndicator()) // URL을 불러오는 동안 로딩 표시
          : WebView(
        initialUrl: kakaoMapUrl, // Kakao 지도 URL을 사용
        javascriptMode: JavascriptMode.unrestricted, // 자바스크립트 허용
      ),
    );
  }
}
*/