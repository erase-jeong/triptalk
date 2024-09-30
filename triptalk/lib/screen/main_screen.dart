/*
import 'package:flutter/material.dart';
import 'package:triptalk/screen/map/map_screen.dart';
import 'package:triptalk/screen/magazine/magazine_screen.dart';
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/mypage/mypage_screen.dart';
import 'package:triptalk/screen/splash_screen.dart'; // 로그아웃 시 사용할 화면 추가

class MainScreen extends StatefulWidget {
  final String token;
  final int distanceValue;

  MainScreen({required this.token, required this.distanceValue});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  late int distanceValue; // distanceValue를 동적으로 업데이트할 수 있게 설정

  @override
  void initState() {
    super.initState();
    distanceValue = widget.distanceValue; // 초기 distanceValue 설정

    print('[init] 초기 distanceValue: $distanceValue'); // 초기 distanceValue 확인
  }

  // BottomNavigationBar에서 페이지 전환 처리
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('[onItemTapped] 현재 선택된 페이지: $_selectedIndex'); // 현재 선택된 페이지 확인
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[build] MainScreen이 다시 빌드됨, _selectedIndex: $_selectedIndex, distanceValue: $distanceValue'); // 빌드 확인

    // 화면 옵션 리스트 정의: build 메소드 안에서 생성하여 distanceValue 업데이트 반영
    List<Widget> _widgetOptions = [
      _buildNavigator(MypageScreen(
        token: widget.token,
        onDistanceSelected: (int value) {
          setState(() {
            distanceValue = value; // distanceValue 업데이트
            _selectedIndex = 2; // MapScreen으로 이동
            print('[Main] 선택된 distanceValue: $distanceValue'); // 선택된 거리 값 확인
          });
        },
      )),
      MagazineScreen(),
      _buildNavigator(MapScreen(token: widget.token, distanceValue: distanceValue)),  // 동적 distanceValue 사용
      _buildNavigator(TalkScreen(token: widget.token)),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('TripTalk'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile.png'), // 사용자 프로필 이미지
                  ),
                  SizedBox(height: 10),
                  Text(
                    '트립톡에 오신것을 환영합니다',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('로그아웃'),
              onTap: () {
                //_logout(); // 로그아웃 함수 호출
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions, // 선택된 페이지를 보여주는 옵션
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45.0),
            topRight: Radius.circular(45.0),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/mypageIconGray.png',
                    'assets/images/mainIcon/mypageIconGreen.png',
                    '마이페이지',
                    0),
                label: '마이페이지',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/magazineIconGray.png',
                    'assets/images/mainIcon/magazineIconGreen.png',
                    '매거진',
                    1),
                label: '매거진',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/mapIconGray.png',
                    'assets/images/mainIcon/mapIconGreen.png',
                    '주변공간',
                    2),
                label: '주변공간',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/talkIconGray.png',
                    'assets/images/mainIcon/talkIconGreen.png',
                    '트립톡',
                    3),
                label: '트립톡',
              ),
            ],
            currentIndex: _selectedIndex, // 현재 선택된 인덱스
            selectedItemColor: Color(0xFF549062), // 선택 시 초록색
            unselectedItemColor: Colors.grey, // 선택되지 않은 경우 회색
            onTap: _onItemTapped, // 아이템 선택 시 호출
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // 각 화면을 Navigator로 분리하여 하단바 유지
  Widget _buildNavigator(Widget screen) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => screen,
        );
      },
    );
  }

  // 하단바 아이템 생성 함수
  Widget _buildNavItem(String unselectedIconPath, String selectedIconPath, String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 상하 여백 추가
      child: Image.asset(
        _selectedIndex == index ? selectedIconPath : unselectedIconPath, // 선택 여부에 따라 아이콘 변경
        width: 24.0,
        height: 24.0,
      ),
    );
  }
}

*/

/*
import 'package:flutter/material.dart';
import 'package:triptalk/screen/map/map_screen.dart';
import 'package:triptalk/screen/magazine/magazine_screen.dart';
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/mypage/mypage_screen.dart';
import 'package:triptalk/screen/splash_screen.dart'; // 로그아웃 시 사용할 화면 추가

class MainScreen extends StatefulWidget {
  final String token;
  final int distanceValue;

  MainScreen({required this.token, required this.distanceValue});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  late int distanceValue; // distanceValue를 동적으로 업데이트할 수 있게 설정

  late List<Widget> _widgetOptions; // 위젯 리스트 초기화

  @override
  void initState() {
    super.initState();
    distanceValue = widget.distanceValue; // 초기 distanceValue 설정

    print('[init] 초기 distanceValue: $distanceValue'); // 초기 distanceValue 확인

    // 화면 옵션 리스트 정의
    _widgetOptions = [
      _buildNavigator(MypageScreen(
        token: widget.token,
        onDistanceSelected: (int value) {
          setState(() {
            distanceValue = value; // distanceValue 업데이트
            _selectedIndex = 2; // MapScreen으로 이동
            print('[Main] 선택된 distanceValue: $distanceValue'); // 선택된 거리 값 확인
          });
        },
      )),
      MagazineScreen(),
      _buildNavigator(MapScreen(token: widget.token, distanceValue: distanceValue)),  // 동적 distanceValue 사용
      _buildNavigator(TalkScreen(token: widget.token)),
    ];
  }

  // 각 화면을 Navigator로 분리하여 하단바 유지
  Widget _buildNavigator(Widget screen) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        print('[Navigator] 호출된 화면: ${screen.toString()}'); // 호출된 화면 출력
        return MaterialPageRoute(
          builder: (context) => screen,
        );
      },
    );
  }

  // BottomNavigationBar에서 페이지 전환 처리
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('[onItemTapped] 현재 선택된 페이지: $_selectedIndex'); // 현재 선택된 페이지 확인
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[하하하] distanceValue :  $widget.distanceValue');
    print('[build] MainScreen이 다시 빌드됨, _selectedIndex: $_selectedIndex'); // 빌드 확인
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('TripTalk'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile.png'), // 사용자 프로필 이미지
                  ),
                  SizedBox(height: 10),
                  Text(
                    '트립톡에 오신것을 환영합니다',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('로그아웃'),
              onTap: () {
                //_logout(); // 로그아웃 함수 호출
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions, // 선택된 페이지를 보여주는 옵션
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45.0),
            topRight: Radius.circular(45.0),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/mypageIconGray.png',
                    'assets/images/mainIcon/mypageIconGreen.png',
                    '마이페이지',
                    0),
                label: '마이페이지',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/magazineIconGray.png',
                    'assets/images/mainIcon/magazineIconGreen.png',
                    '매거진',
                    1),
                label: '매거진',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/mapIconGray.png',
                    'assets/images/mainIcon/mapIconGreen.png',
                    '주변공간',
                    2),
                label: '주변공간',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/talkIconGray.png',
                    'assets/images/mainIcon/talkIconGreen.png',
                    '트립톡',
                    3),
                label: '트립톡',
              ),
            ],
            currentIndex: _selectedIndex, // 현재 선택된 인덱스
            selectedItemColor: Color(0xFF549062), // 선택 시 초록색
            unselectedItemColor: Colors.grey, // 선택되지 않은 경우 회색
            backgroundColor: Colors.white,
            onTap: _onItemTapped, // 아이템 선택 시 호출
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // 하단바 아이템 생성 함수
  Widget _buildNavItem(String unselectedIconPath, String selectedIconPath, String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 상하 여백 추가
      child: Image.asset(
        _selectedIndex == index ? selectedIconPath : unselectedIconPath, // 선택 여부에 따라 아이콘 변경
        width: 24.0,
        height: 24.0,
      ),
    );
  }
}
*/


////////



import 'package:flutter/material.dart';
import 'package:triptalk/screen/map/map_screen.dart';
import 'package:triptalk/screen/magazine/magazine_screen.dart';
import 'package:triptalk/screen/talk/talk_screen.dart';
import 'package:triptalk/screen/mypage/mypage_screen.dart';
import 'package:triptalk/screen/splash_screen.dart'; // 로그아웃 시 사용할 화면 추가
import 'package:triptalk/screen/service/location_notification_service.dart';
import 'package:triptalk/screen/service/notification_service.dart';

class MainScreen extends StatefulWidget {
  final String token;
  final int distanceValue; // 초기값을 받는 필드

  MainScreen({required this.token, required this.distanceValue});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // LocationNotificationService 즉시 초기화
  LocationNotificationService locationNotificationService = LocationNotificationService();

  int _selectedIndex = 0;
  late int distanceValue; // distanceValue를 동적으로 업데이트할 수 있게 선언

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    distanceValue = widget.distanceValue; // 초기 distanceValue를 설정
    print('[main] 초기 distanceValue: $distanceValue'); // 초기값 확인

    // LocationNotificationService 초기화
    locationNotificationService = LocationNotificationService();
    // 로그인 후 위치 추적 시작
    locationNotificationService.checkLocationPermission();
    locationNotificationService.startLocationUpdates();

    _widgetOptions = <Widget>[
      _buildNavigator(MypageScreen(
        token: widget.token,
        onDistanceSelected: (int value) {
          setState(() {
            distanceValue = value; // distanceValue 업데이트
            _selectedIndex = 2; // MapScreen으로 이동
            print('[main]선택된 distanceValue: $distanceValue');
          });
        },
      )),
      MagazineScreen(),
      _buildNavigator(MapScreen(token: widget.token, distanceValue: widget.distanceValue)),  // MapScreen에 distanceValue 전달
      _buildNavigator(TalkScreen(token: widget.token)), // TalkScreen에 Navigator 적용
    ];
  }

  @override
  void dispose() {
    // 서비스에서 스트림 취소
    locationNotificationService.dispose();
    super.dispose();
  }

/*
class MainScreen extends StatefulWidget {
  final String token;
  final int distanceValue;

  MainScreen({required this.token,required this.distanceValue});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  late int distanceValue;

  static late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
     // _buildNavigator(MypageScreen(token: widget.token)),
      _buildNavigator(MypageScreen(token: widget.token, onDistanceSelected: (int value) {
        setState(() {
          distanceValue = value; // distanceValue 업데이트
          _selectedIndex = 2; // MapScreen으로 이동
        });
      })),
      MagazineScreen(),
      _buildNavigator(MapScreen(token: widget.token, distanceValue:widget.distanceValue)),  // MapScreen에 Navigator 적용
      _buildNavigator(TalkScreen(token: widget.token)), // TalkScreen에 Navigator 적용
    ];
  }
  */

  // 각 화면을 Navigator로 분리하여 하단바 유지
  Widget _buildNavigator(Widget screen) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        print('[main] Navigator에서 호출된 화면: ${screen.toString()}');
        return MaterialPageRoute(
          builder: (context) => screen,
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('[main] 현재 선택된 페이지: $_selectedIndex'); // 페이지 이동 확인
    });
  }

  // 로그아웃 처리 함수
  void _logout() async {
    // 로그아웃 시 기존 네비게이션 스택을 제거하고 SplashScreen으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => SplashScreen(), // 로그아웃 후 SplashScreen으로 이동
      ),
          (Route<dynamic> route) => false, // 모든 이전 페이지 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[main] MainScreen이 다시 빌드됨, _selectedIndex: $_selectedIndex');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('TripTalk'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile.png'), // 사용자 프로필 이미지
                  ),
                  SizedBox(height: 10),
                  Text(
                    '트립톡에 오신것을 환영합니다',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  /*
                  Text(
                    '@사용자이름',
                    style: TextStyle(color: Colors.white70),
                  ),
                   */
                ],
              ),
            ),
            ListTile(
              title: Text('로그아웃'),
              onTap: () {
                _logout(); // 로그아웃 함수 호출
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45.0),
            topRight: Radius.circular(45.0),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/mypageIconGray.png',
                    'assets/images/mainIcon/mypageIconGreen.png',
                    '마이페이지',
                    0),
                label: '마이페이지',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/magazineIconGray.png',
                    'assets/images/mainIcon/magazineIconGreen.png',
                    '매거진',
                    1),
                label: '매거진',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/mapIconGray.png',
                    'assets/images/mainIcon/mapIconGreen.png',
                    '주변공간',
                    2),
                label: '주변공간',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(
                    'assets/images/mainIcon/talkIconGray.png',
                    'assets/images/mainIcon/talkIconGreen.png',
                    '트립톡',
                    3),
                label: '트립톡',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF549062), // 클릭 시 초록색
            unselectedItemColor: Colors.grey, // 기본 회색
            backgroundColor: Colors.white,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildNavItem(String unselectedIconPath, String selectedIconPath, String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 상하 여백 추가
      child: Image.asset(
        _selectedIndex == index ? selectedIconPath : unselectedIconPath,
        width: 24.0,
        height: 24.0,
      ),
    );
  }
}

