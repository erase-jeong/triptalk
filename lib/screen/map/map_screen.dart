/*
//슬라이더 코드
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Geolocator 패키지 추가

class MapScreen extends StatefulWidget {
  final String token;
  final int distanceValue;

  const MapScreen({Key? key, required this.token, required this.distanceValue}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> locations = [];
  double? currentLat;
  double? currentLon;
  double _currentSliderValue = 3.0;  // 슬라이더 기본값 (3km로 설정)

  int currentPage = 0; // 현재 페이지 번호
  final int itemsPerPage = 3; // 페이지당 항목 수
  String? clickedMarkerId; // 클릭된 마커의 id 저장

  // 알람 및 북마크 상태 변수
  bool isAlarmOn = false; // 기본값은 alarmOff
  bool isBookmarked = false; // 기본값은 bookmarkEmpty

  @override
  void initState() {
    super.initState();

    // 초기 distanceValue 설정 (0일 경우 3km로 설정)
    if (widget.distanceValue >= 3) {
      _currentSliderValue = widget.distanceValue.toDouble();
    } else {
      _currentSliderValue = 3.0;
    }

    getCurrentLocation(); // 현재 위치 가져오기
    loadJsonData(); // JSON 데이터 로드
  }

  // JSON 파일을 불러오는 함수
  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data/locations.json');
    final jsonResponse = json.decode(jsonString);
    setState(() {
      locations = jsonResponse['data'];
    });
  }

  // 현재 위치를 가져오는 함수
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLat = position.latitude;
      currentLon = position.longitude;
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // 지구의 반지름 (단위: km)
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
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
    print('[map - build] MapScreen이 빌드됨, distanceValue: ${widget.distanceValue}');
    if (currentLat == null || currentLon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Map Screen'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 슬라이더 값을 사용하여 거리 필터링
    double maxDistanceKm = _currentSliderValue;
    List<Map<String, dynamic>> filteredLocations = locations.where((location) {
      double locationLat = double.parse(location['mapY']);
      double locationLon = double.parse(location['mapX']);
      double distance = calculateDistance(currentLat!, currentLon!, locationLat, locationLon);
      return distance <= maxDistanceKm;
    }).map((location) {
      return {
        'tid': location['tid'],
        'tlid': location['tlid'],
        'title': location['title'],
      };
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 지도 배경 설정 (아직 지도 관련 UI 추가 필요)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/surroundingIcon/surroundingPageBackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 텍스트 및 슬라이더 UI
            Positioned(
              left: 16.0,
              top: 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 주변 관광지 뭐가 있을까?',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'HSSantokki',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_currentSliderValue.toInt()}km 내의 숨겨진 공간을 확인해보세요.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ),
            // 거리 슬라이더 추가
            Positioned(
              left: 16.0,
              right: 16.0,
              top: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '거리설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  SizedBox(height: 10),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.green,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _currentSliderValue,
                      min: 3,  // 최소값 설정
                      max: 20,  // 최대값 설정
                      divisions: 4,
                      label: '${_currentSliderValue.toInt()} km',
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                  ),

                ],
              ),
            ),
            // 지도에 마커 표시 로직 추가 필요
          ],
        ),
      ),
    );
  }
}

*/


/*
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final String token;
  final int distanceValue;

  const MapScreen({Key? key, required this.token, required this.distanceValue}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> locations = [];
  double? currentLat;
  double? currentLon;
  double _currentSliderValue = 3;  // 기본 슬라이더 값 (3km)

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.distanceValue.toDouble();  // 초기 distanceValue 설정
    getCurrentLocation(); // 현재 위치 가져오기
    loadJsonData(); // JSON 데이터 로드
  }

  // JSON 파일을 불러오는 함수
  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data/locations.json');
    final jsonResponse = json.decode(jsonString);
    setState(() {
      locations = jsonResponse['data'];
    });
  }

  // 현재 위치를 가져오는 함수
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLat = position.latitude;
      currentLon = position.longitude;
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // 지구의 반지름 (단위: km)
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    if (currentLat == null || currentLon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Map Screen'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 슬라이더 값을 이용해 거리에 따른 위치 필터링
    double maxDistanceKm = _currentSliderValue;
    List<Map<String, dynamic>> filteredLocations = locations.where((location) {
      double locationLat = double.parse(location['mapY']);
      double locationLon = double.parse(location['mapX']);
      double distance = calculateDistance(currentLat!, currentLon!, locationLat, locationLon);
      return distance <= maxDistanceKm;
    }).map((location) {
      return {
        'tid': location['tid'],
        'tlid': location['tlid'],
        'title': location['title'],
      };
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 지도 배경 설정
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/surroundingIcon/surroundingPageBackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 텍스트 및 슬라이더 UI
            Positioned(
              left: 16.0,
              top: 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 주변 관광지 뭐가 있을까?',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'HSSantokki',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_currentSliderValue.toInt()}km 내의 숨겨진 공간을 확인해보세요.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ),
            // 거리 슬라이더 UI
            Positioned(
              left: 16.0,
              right: 16.0,
              top: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '거리설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  SizedBox(height: 10),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.green,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _currentSliderValue,
                      min: 3,
                      max: 20,
                      divisions: 4,
                      label: '${_currentSliderValue.toInt()} km',
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('3km', style: TextStyle(fontSize: 16)),
                        Text('7km', style: TextStyle(fontSize: 16)),
                        Text('12km', style: TextStyle(fontSize: 16)),
                        Text('20km', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 필터링된 위치 및 마커 표시
            // 아래에 마커와 관련된 위치 정보 표시 로직을 추가할 수 있습니다.
          ],
        ),
      ),
    );
  }
}
*/


import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Geolocator 패키지 추가
import 'package:triptalk/screen/service/notification_service.dart';

class MapScreen extends StatefulWidget {
  final String token;
  final int distanceValue;

  const MapScreen({Key? key, required this.token, required this.distanceValue}) : super(key: key);
  //const MapScreen({Key? key, required this.token}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> locations = [];
  double? currentLat;
  double? currentLon;
  double _currentSliderValue = 3.0;  // 슬라이더 기본값 (3km로 설정)

  int currentPage = 0; // 현재 페이지 번호
  final int itemsPerPage = 3; // 페이지당 항목 수
  String? clickedMarkerId; // 클릭된 마커의 id 저장

  // 알람 및 북마크 상태 변수
  bool isAlarmOn = false; // 기본값은 alarmOff
  bool isBookmarked = false; // 기본값은 bookmarkEmpty

  @override
  void initState() {
    super.initState();

    // 초기 distanceValue 설정 (0일 경우 3km로 설정)
    if (widget.distanceValue >= 1) {
      _currentSliderValue = widget.distanceValue.toDouble();
    } else {
      _currentSliderValue = 1.0;
    }
    //final int distanceValue = widget.distanceValue; // 초기 distanceValue 설정
    //print('[map - initState] 초기 distanceValue: ${distanceValue}');
    getCurrentLocation(); // 현재 위치 가져오기
    loadJsonData();
  }


  // JSON 파일을 불러오는 함수
  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data/locations.json');
    final jsonResponse = json.decode(jsonString);
    setState(() {
      locations = jsonResponse['data'];
    });
  }


  // 현재 위치를 가져오는 함수
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLat = position.latitude;
      currentLon = position.longitude;
    });

  }



  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // 지구의 반지름 (단위: km)
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
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



  // 알람뮤트 추가 API 호출 함수
  Future<void> addAlarmMute(int locationId) async {
    final url = 'https://triptalk.store/v1/alarm-mutes/$locationId';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Alarm mute added successfully');
    } else {
      print('Failed to add alarm mute');
    }
  }



  // 알람뮤트 삭제 API 호출 함수
  Future<void> deleteAlarmMute(int locationId) async {
    final url = 'https://triptalk.store/v1/alarm-mutes/$locationId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Alarm mute deleted successfully');
    } else {
      print('Failed to delete alarm mute');
    }
  }


  Future<Map<String, dynamic>?> fetchLocationDetails(String tid, String tlid) async {
    final url = 'https://triptalk.store/v1/nearby-locations?tid=$tid&tlid=$tlid';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse['data'];
    } else {
      print('Failed to load location details');
      return null;
    }
  }


  Future<void> showLocationDetailsModal(Map<String, dynamic> location) async {
    final locationDetails = await fetchLocationDetails(location['tid'], location['tlid']);
    if (locationDetails != null) {
      setState(() {
        isBookmarked = locationDetails['bookmarked'];
        isAlarmOn = locationDetails['alarmMuted']; // 알람 상태를 가져오기
      });

      /*
      // 알림바로 알림 출력
      NotificationService().showNotification(
          locationDetails['locationName'], // 알림 제목 (관광지 이름)
          '관광지가 ${_currentSliderValue.toInt()}km 이내에 있습니다.' // 알림 메시지
      );

       */

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row containing Image, Location Name, Bookmark, and Alarm icons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container
                        Container(
                          width: 60.0, // Adjust the size as needed
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],  // Placeholder color
                            borderRadius: BorderRadius.circular(8.0),
                            image: locationDetails['imageUrl'] != null
                                ? DecorationImage(
                              image: NetworkImage(locationDetails['imageUrl']),
                              fit: BoxFit.cover,
                            )
                                : null,  // Default image if 'imageUrl' is null
                          ),
                        ),
                        SizedBox(width: 16.0),
                        // Location Name and Bookmark/Alarm Row
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Location Title
                                  Expanded(
                                    child: Text(
                                      locationDetails['locationName'] ?? 'No title',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'HSSantokki',
                                        color: Color(0xFF539262),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Alarm Icon Toggle
                                      GestureDetector(
                                        onTap: () async {
                                          setModalState(() {
                                            isAlarmOn = !isAlarmOn; // Toggle alarm status
                                          });
                                          if (isAlarmOn) {
                                            await addAlarmMute(locationDetails['locationId']);
                                          } else {
                                            await deleteAlarmMute(locationDetails['locationId']);
                                          }
                                          print("Alarm icon clicked");
                                        },
                                        child: Image.asset(
                                          isAlarmOn
                                              ? 'assets/images/surroundingIcon/alarmOff.png'
                                              : 'assets/images/surroundingIcon/alarmOn.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // Bookmark Icon Toggle
                                      GestureDetector(
                                        onTap: () async {
                                          setModalState(() {
                                            isBookmarked = !isBookmarked; // Toggle bookmark status
                                          });
                                          if (isBookmarked) {
                                            await addBookmark(locationDetails['locationId']);
                                          } else {
                                            await deleteBookmark(locationDetails['locationId']);
                                          }
                                          print("Bookmark icon clicked");
                                        },
                                        child: Image.asset(
                                          isBookmarked
                                              ? 'assets/images/surroundingIcon/bookmarkFull.png'
                                              : 'assets/images/surroundingIcon/bookmarkEmpty.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              // Address Information
                              Text(
                                locationDetails['address'] ?? 'No address information',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                              // Distance
                              SizedBox(height: 4.0),

                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Scrollable locationInfo section
                    Container(
                      height: 100.0,  // You can adjust the height limit as needed
                      child: Scrollbar(
                        thumbVisibility: true,  // Make the scrollbar visible
                        child: SingleChildScrollView(
                          child: Text(
                            locationDetails['locationInfo'] ?? 'No detailed information available',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    print('[map - build] MapScreen이 빌드됨, distanceValue: ${widget.distanceValue}');
    if (currentLat == null || currentLon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Map Screen'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 슬라이더 값을 사용하여 거리 필터링
    double maxDistanceKm = _currentSliderValue;
    List<Map<String, dynamic>> filteredLocations = locations.where((location) {
      double locationLat = double.parse(location['mapY']);
      double locationLon = double.parse(location['mapX']);
      double distance = calculateDistance(
          currentLat!, currentLon!, locationLat, locationLon);
      return distance <= maxDistanceKm;
    }).map((location) {
      return {
        'tid': location['tid'],
        'tlid': location['tlid'],
        'title': location['title'],
      };
    }).toList();

    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    List<Map<String, dynamic>> paginatedLocations =
    filteredLocations.sublist(startIndex, endIndex > filteredLocations.length ? filteredLocations.length : endIndex);

    print('[map2 - build] MapScreen이 빌드됨, distanceValue: ${widget.distanceValue}');
    return Scaffold(
      body: SafeArea( // Ensures content doesn't overlap with status bar
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/surroundingIcon/surroundingPageBackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 16.0,
              top: 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 주변 관광지 뭐가 있을까?',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'HSSantokki',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_currentSliderValue.toInt()}km 내의 숨겨진 공간을 확인해보세요.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16.0,
              right: 16.0,
              top: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      '거리설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'HSSantokki',
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.green,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _currentSliderValue,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '${_currentSliderValue.toInt()} km',
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });

                        // Check if any locations are within the new distance value and trigger notifications
                        for (var location in locations) {
                          double locationLat = double.parse(location['mapY']);
                          double locationLon = double.parse(location['mapX']);
                          double distance = calculateDistance(currentLat!, currentLon!, locationLat, locationLon);

                          if (distance <= _currentSliderValue) {
                            NotificationService().showNotification(
                                location['title'],
                                '${location['title']} is within ${_currentSliderValue.toInt()}km.'
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            /*
            if (paginatedLocations.isEmpty)
              Center(
                child: Text(
                  '주변에 숨겨진 관광지가 없습니다.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Pretendard',
                  ),
                ),
              )
              */
            if (paginatedLocations.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 이미지와 텍스트를 수직 중앙 정렬
                  children: [
                    Image.asset(
                      'assets/images/magazine/warning.png', // 이미지 경로 (로컬 이미지일 경우)
                      width: 100,  // 이미지의 가로 크기
                      height: 100, // 이미지의 세로 크기
                    ),
                    SizedBox(height: 16), // 이미지와 텍스트 사이 간격 조정
                    Text(
                      '주변에 숨겨진 관광지가 없습니다.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              if (paginatedLocations.isNotEmpty)
                ..._buildMarkerWithBubble(context, paginatedLocations[0], 0.2, 0.25),
              if (paginatedLocations.length > 1)
                ..._buildMarkerWithBubble(context, paginatedLocations[1], 0.5, 0.35),
              if (paginatedLocations.length > 2)
                ..._buildMarkerWithBubble(context, paginatedLocations[2], 0.3, 0.45),
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_left, color: Color(0xFF3F3F3F)),
                      onPressed: currentPage > 0
                          ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                          : null,
                    ),
                    Text(
                      'Page ${currentPage + 1}',
                      style: TextStyle(
                        color: Color(0xFF3F3F3F),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_right, color: Color(0xFF3F3F3F)),
                      onPressed: endIndex < filteredLocations.length
                          ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  List<Widget> _buildMarkerWithBubble(BuildContext context, Map<String, dynamic> location, double left, double top) {
    bool isClicked = clickedMarkerId == location['tid']; // 현재 마커가 클릭되었는지 여부 확인
    return [
      Positioned(
        left: MediaQuery.of(context).size.width * left - 25,
        top: MediaQuery.of(context).size.height * (top + 0.07),
        //top: MediaQuery.of(context).size.height * top - 60,
        child: Image.asset(
          isClicked
              ? 'assets/images/surroundingIcon/speechBubbleDot.png' // 클릭된 마커는 speechBubbleDot.png로 변경
              : 'assets/images/surroundingIcon/speechBubble.png',   // 그렇지 않은 마커는 기본 speechBubble.png
          width: 80,
          height: 40,
        ),
      ),
      Positioned(
        left: MediaQuery.of(context).size.width * left,
        //top: MediaQuery.of(context).size.height * top,
        top: MediaQuery.of(context).size.height * (top+0.13),
        child: GestureDetector(
          onTap: () async {
            setState(() {
              clickedMarkerId = location['tid']; // 클릭된 마커의 ID 업데이트
            });
            await showLocationDetailsModal(location); // 상태 반영된 모달 호출
          },
          child: Image.asset(
            'assets/images/surroundingIcon/surroundingMarker.png',
            width: 30,
            height: 30,
          ),
        ),
      ),
    ];
  }
}




//기존코드
/*
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Geolocator 패키지 추가

class MapScreen extends StatefulWidget {
  final String token;
  final int distanceValue;

  const MapScreen({Key? key, required this.token, required this.distanceValue}) : super(key: key);
  //const MapScreen({Key? key, required this.token}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> locations = [];
  double? currentLat;
  double? currentLon;
  double _currentSliderValue = 3.0;  // 슬라이더 기본값 (3km로 설정)

  int currentPage = 0; // 현재 페이지 번호
  final int itemsPerPage = 3; // 페이지당 항목 수
  String? clickedMarkerId; // 클릭된 마커의 id 저장

  // 알람 및 북마크 상태 변수
  bool isAlarmOn = false; // 기본값은 alarmOff
  bool isBookmarked = false; // 기본값은 bookmarkEmpty

  @override
  void initState() {
    super.initState();

    // 초기 distanceValue 설정 (0일 경우 3km로 설정)
    if (widget.distanceValue >= 3) {
      _currentSliderValue = widget.distanceValue.toDouble();
    } else {
      _currentSliderValue = 3.0;
    }
    //final int distanceValue = widget.distanceValue; // 초기 distanceValue 설정
    //print('[map - initState] 초기 distanceValue: ${distanceValue}');
    getCurrentLocation(); // 현재 위치 가져오기
    loadJsonData();
  }


  // JSON 파일을 불러오는 함수
  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data/locations.json');
    final jsonResponse = json.decode(jsonString);
    setState(() {
      locations = jsonResponse['data'];
    });
  }


  // 현재 위치를 가져오는 함수
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLat = position.latitude;
      currentLon = position.longitude;
    });
  }


  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // 지구의 반지름 (단위: km)
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
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



  // 알람뮤트 추가 API 호출 함수
  Future<void> addAlarmMute(int locationId) async {
    final url = 'https://triptalk.store/v1/alarm-mutes/$locationId';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Alarm mute added successfully');
    } else {
      print('Failed to add alarm mute');
    }
  }



  // 알람뮤트 삭제 API 호출 함수
  Future<void> deleteAlarmMute(int locationId) async {
    final url = 'https://triptalk.store/v1/alarm-mutes/$locationId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Alarm mute deleted successfully');
    } else {
      print('Failed to delete alarm mute');
    }
  }


  Future<Map<String, dynamic>?> fetchLocationDetails(String tid, String tlid) async {
    final url = 'https://triptalk.store/v1/nearby-locations?tid=$tid&tlid=$tlid';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse['data'];
    } else {
      print('Failed to load location details');
      return null;
    }
  }


  Future<void> showLocationDetailsModal(Map<String, dynamic> location) async {
    final locationDetails = await fetchLocationDetails(location['tid'], location['tlid']);
    if (locationDetails != null) {
      setState(() {
        isBookmarked = locationDetails['bookmarked'];
        isAlarmOn = locationDetails['alarmMuted']; // 알람 상태를 가져오기
      });

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row containing Image, Location Name, Bookmark, and Alarm icons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container
                        Container(
                          width: 60.0, // Adjust the size as needed
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],  // Placeholder color
                            borderRadius: BorderRadius.circular(8.0),
                            image: locationDetails['imageUrl'] != null
                                ? DecorationImage(
                              image: NetworkImage(locationDetails['imageUrl']),
                              fit: BoxFit.cover,
                            )
                                : null,  // Default image if 'imageUrl' is null
                          ),
                        ),
                        SizedBox(width: 16.0),
                        // Location Name and Bookmark/Alarm Row
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Location Title
                                  Expanded(
                                    child: Text(
                                      locationDetails['locationName'] ?? 'No title',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'HSSantokki',
                                        color: Color(0xFF539262),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Alarm Icon Toggle
                                      GestureDetector(
                                        onTap: () async {
                                          setModalState(() {
                                            isAlarmOn = !isAlarmOn; // Toggle alarm status
                                          });
                                          if (isAlarmOn) {
                                            await addAlarmMute(locationDetails['locationId']);
                                          } else {
                                            await deleteAlarmMute(locationDetails['locationId']);
                                          }
                                          print("Alarm icon clicked");
                                        },
                                        child: Image.asset(
                                          isAlarmOn
                                              ? 'assets/images/surroundingIcon/alarmOff.png'
                                              : 'assets/images/surroundingIcon/alarmOn.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // Bookmark Icon Toggle
                                      GestureDetector(
                                        onTap: () async {
                                          setModalState(() {
                                            isBookmarked = !isBookmarked; // Toggle bookmark status
                                          });
                                          if (isBookmarked) {
                                            await addBookmark(locationDetails['locationId']);
                                          } else {
                                            await deleteBookmark(locationDetails['locationId']);
                                          }
                                          print("Bookmark icon clicked");
                                        },
                                        child: Image.asset(
                                          isBookmarked
                                              ? 'assets/images/surroundingIcon/bookmarkFull.png'
                                              : 'assets/images/surroundingIcon/bookmarkEmpty.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              // Address Information
                              Text(
                                locationDetails['address'] ?? 'No address information',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                              // Distance
                              SizedBox(height: 4.0),

                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Scrollable locationInfo section
                    Container(
                      height: 100.0,  // You can adjust the height limit as needed
                      child: Scrollbar(
                        thumbVisibility: true,  // Make the scrollbar visible
                        child: SingleChildScrollView(
                          child: Text(
                            locationDetails['locationInfo'] ?? 'No detailed information available',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[map - build] MapScreen이 빌드됨, distanceValue: ${widget.distanceValue}');
    if (currentLat == null || currentLon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Map Screen'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
// 슬라이더 값을 사용하여 거리 필터링
    double maxDistanceKm = _currentSliderValue;
    //double maxDistanceKm = 1;
    List<Map<String, dynamic>> filteredLocations = locations.where((location) {
      double locationLat = double.parse(location['mapY']);
      double locationLon = double.parse(location['mapX']);
      double distance = calculateDistance(
          currentLat!, currentLon!, locationLat, locationLon);
      return distance <= maxDistanceKm;
    }).map((location) {
      return {
        'tid': location['tid'],
        'tlid': location['tlid'],
        'title': location['title'],
      };
    }).toList();

    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    List<Map<String, dynamic>> paginatedLocations =
    filteredLocations.sublist(startIndex, endIndex > filteredLocations.length ? filteredLocations.length : endIndex);



    print('[map2 - build] MapScreen이 빌드됨, distanceValue: ${widget.distanceValue}');
    return Scaffold(

      body: SafeArea( // Ensures content doesn't overlap with status bar
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/surroundingIcon/surroundingPageBackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 16.0,
              top: 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 주변 관광지 뭐가 있을까?',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'HSSantokki',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_currentSliderValue.toInt()}km 내의 숨겨진 공간을 확인해보세요.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFF2C2C2C),
                    ),
                  ),


                ],
              ),
            ),
            Positioned(
              left: 16.0,
              right: 16.0,
              top: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: 16.0), // 왼쪽에 16.0만큼의 패딩 추가
                    child: Text(
                      '거리설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'HSSantokki',
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.green,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _currentSliderValue,
                      min: 3,  // 최소값 설정
                      max: 20,  // 최대값 설정
                      divisions: 4,
                      label: '${_currentSliderValue.toInt()} km',
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                  ),

                ],
              ),
            ),


            if (paginatedLocations.isNotEmpty)
              ..._buildMarkerWithBubble(context, paginatedLocations[0], 0.2, 0.25),
            if (paginatedLocations.length > 1)
              ..._buildMarkerWithBubble(context, paginatedLocations[1], 0.5, 0.35),
            if (paginatedLocations.length > 2)
              ..._buildMarkerWithBubble(context, paginatedLocations[2], 0.3, 0.45),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: Color(0xFF3F3F3F)),
                    onPressed: currentPage > 0
                        ? () {
                      setState(() {
                        currentPage--;
                      });
                    }
                        : null,
                  ),
                  Text(
                    'Page ${currentPage + 1}',
                    style: TextStyle(
                      color: Color(0xFF3F3F3F),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, color: Color(0xFF3F3F3F)),
                    onPressed: endIndex < filteredLocations.length
                        ? () {
                      setState(() {
                        currentPage++;
                      });
                    }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMarkerWithBubble(BuildContext context, Map<String, dynamic> location, double left, double top) {
    bool isClicked = clickedMarkerId == location['tid']; // 현재 마커가 클릭되었는지 여부 확인
    return [
      Positioned(
        left: MediaQuery.of(context).size.width * left - 25,
        top: MediaQuery.of(context).size.height * (top + 0.07),
        //top: MediaQuery.of(context).size.height * top - 60,
        child: Image.asset(
          isClicked
              ? 'assets/images/surroundingIcon/speechBubbleDot.png' // 클릭된 마커는 speechBubbleDot.png로 변경
              : 'assets/images/surroundingIcon/speechBubble.png',   // 그렇지 않은 마커는 기본 speechBubble.png
          width: 80,
          height: 40,
        ),
      ),
      Positioned(
        left: MediaQuery.of(context).size.width * left,
        //top: MediaQuery.of(context).size.height * top,
        top: MediaQuery.of(context).size.height * (top+0.17),
        child: GestureDetector(
          onTap: () async {
            setState(() {
              clickedMarkerId = location['tid']; // 클릭된 마커의 ID 업데이트
            });
            await showLocationDetailsModal(location); // 상태 반영된 모달 호출
          },
          child: Image.asset(
            'assets/images/surroundingIcon/surroundingMarker.png',
            width: 50,
            height: 50,
          ),
        ),
      ),
    ];
  }
}

*/


/*
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Geolocator 패키지 추가

class MapScreen extends StatefulWidget {
  final String token;

  const MapScreen({Key? key, required this.token}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> locations = [];
  double? currentLat;
  double? currentLon;

  int currentPage = 0; // 현재 페이지 번호
  final int itemsPerPage = 3; // 페이지당 항목 수
  String? clickedMarkerId; // 클릭된 마커의 id 저장

  // 알람 및 북마크 상태 변수
  bool isAlarmOn = false; // 기본값은 alarmOff
  bool isBookmarked = false; // 기본값은 bookmarkEmpty

  @override
  void initState() {
    super.initState();
    getCurrentLocation(); // 현재 위치 가져오기
    loadJsonData();
  }

  // JSON 파일을 불러오는 함수
  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data/locations.json');
    final jsonResponse = json.decode(jsonString);
    setState(() {
      locations = jsonResponse['data'];
    });
  }

  // 현재 위치를 가져오는 함수
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLat = position.latitude;
      currentLon = position.longitude;
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // 지구의 반지름 (단위: km)
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
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

  // 알람뮤트 추가 API 호출 함수
  Future<void> addAlarmMute(int locationId) async {
    final url = 'https://triptalk.store/v1/alarm-mutes/$locationId';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Alarm mute added successfully');
    } else {
      print('Failed to add alarm mute');
    }
  }

  // 알람뮤트 삭제 API 호출 함수
  Future<void> deleteAlarmMute(int locationId) async {
    final url = 'https://triptalk.store/v1/alarm-mutes/$locationId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Alarm mute deleted successfully');
    } else {
      print('Failed to delete alarm mute');
    }
  }

  Future<Map<String, dynamic>?> fetchLocationDetails(String tid, String tlid) async {
    final url = 'https://triptalk.store/v1/nearby-locations?tid=$tid&tlid=$tlid';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse['data'];
    } else {
      print('Failed to load location details');
      return null;
    }
  }

  Future<void> showLocationDetailsModal(Map<String, dynamic> location) async {
    final locationDetails = await fetchLocationDetails(location['tid'], location['tlid']);
    if (locationDetails != null) {
      setState(() {
        isBookmarked = locationDetails['bookmarked'];
        isAlarmOn = locationDetails['alarmMuted']; // 알람 상태를 가져오기
      });

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row containing Image, Location Name, Bookmark, and Alarm icons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container
                        Container(
                          width: 60.0, // Adjust the size as needed
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],  // Placeholder color
                            borderRadius: BorderRadius.circular(8.0),
                            image: locationDetails['imageUrl'] != null
                                ? DecorationImage(
                              image: NetworkImage(locationDetails['imageUrl']),
                              fit: BoxFit.cover,
                            )
                                : null,  // Default image if 'imageUrl' is null
                          ),
                        ),
                        SizedBox(width: 16.0),
                        // Location Name and Bookmark/Alarm Row
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Location Title
                                  Expanded(
                                    child: Text(
                                      locationDetails['locationName'] ?? 'No title',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Alarm Icon Toggle
                                      GestureDetector(
                                        onTap: () async {
                                          setModalState(() {
                                            isAlarmOn = !isAlarmOn; // Toggle alarm status
                                          });
                                          if (isAlarmOn) {
                                            await addAlarmMute(locationDetails['locationId']);
                                          } else {
                                            await deleteAlarmMute(locationDetails['locationId']);
                                          }
                                          print("Alarm icon clicked");
                                        },
                                        child: Image.asset(
                                          isAlarmOn
                                              ? 'assets/images/surroundingIcon/alarmOff.png'
                                              : 'assets/images/surroundingIcon/alarmOn.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // Bookmark Icon Toggle
                                      GestureDetector(
                                        onTap: () async {
                                          setModalState(() {
                                            isBookmarked = !isBookmarked; // Toggle bookmark status
                                          });
                                          if (isBookmarked) {
                                            await addBookmark(locationDetails['locationId']);
                                          } else {
                                            await deleteBookmark(locationDetails['locationId']);
                                          }
                                          print("Bookmark icon clicked");
                                        },
                                        child: Image.asset(
                                          isBookmarked
                                              ? 'assets/images/surroundingIcon/bookmarkFull.png'
                                              : 'assets/images/surroundingIcon/bookmarkEmpty.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              // Address Information
                              Text(
                                locationDetails['address'] ?? 'No address information',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                              // Distance
                              SizedBox(height: 4.0),

                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // locationInfo section remains the same as per your request
                    Text(
                      locationDetails['locationInfo'] ?? 'No detailed information available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLat == null || currentLon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Map Screen'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double maxDistanceKm = 3;
    List<Map<String, dynamic>> filteredLocations = locations.where((location) {
      double locationLat = double.parse(location['mapY']);
      double locationLon = double.parse(location['mapX']);
      double distance = calculateDistance(
          currentLat!, currentLon!, locationLat, locationLon);
      return distance <= maxDistanceKm;
    }).map((location) {
      return {
        'tid': location['tid'],
        'tlid': location['tlid'],
        'title': location['title'],
      };
    }).toList();

    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    List<Map<String, dynamic>> paginatedLocations =
    filteredLocations.sublist(startIndex, endIndex > filteredLocations.length ? filteredLocations.length : endIndex);

    return Scaffold(
      body: SafeArea( // Ensures content doesn't overlap with status bar
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/surroundingIcon/surroundingPageBackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 16.0,
              top: 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 주변 관광지 뭐가 있을까?',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'HSSantokki',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3km 내의 숨겨진 공간을 확인해보세요.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ),
            if (paginatedLocations.isNotEmpty)
              ..._buildMarkerWithBubble(context, paginatedLocations[0], 0.2, 0.25),
            if (paginatedLocations.length > 1)
              ..._buildMarkerWithBubble(context, paginatedLocations[1], 0.5, 0.35),
            if (paginatedLocations.length > 2)
              ..._buildMarkerWithBubble(context, paginatedLocations[2], 0.3, 0.45),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: Color(0xFF3F3F3F)),
                    onPressed: currentPage > 0
                        ? () {
                      setState(() {
                        currentPage--;
                      });
                    }
                        : null,
                  ),
                  Text(
                    'Page ${currentPage + 1}',
                    style: TextStyle(
                      color: Color(0xFF3F3F3F),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, color: Color(0xFF3F3F3F)),
                    onPressed: endIndex < filteredLocations.length
                        ? () {
                      setState(() {
                        currentPage++;
                      });
                    }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMarkerWithBubble(BuildContext context, Map<String, dynamic> location, double left, double top) {
    bool isClicked = clickedMarkerId == location['tid']; // 현재 마커가 클릭되었는지 여부 확인
    return [
      Positioned(
        left: MediaQuery.of(context).size.width * left - 25,
        top: MediaQuery.of(context).size.height * top - 60,
        child: Image.asset(
          isClicked
              ? 'assets/images/surroundingIcon/speechBubbleDot.png' // 클릭된 마커는 speechBubbleDot.png로 변경
              : 'assets/images/surroundingIcon/speechBubble.png',   // 그렇지 않은 마커는 기본 speechBubble.png
          width: 80,
          height: 40,
        ),
      ),
      Positioned(
        left: MediaQuery.of(context).size.width * left,
        top: MediaQuery.of(context).size.height * top,
        child: GestureDetector(
          onTap: () async {
            setState(() {
              clickedMarkerId = location['tid']; // 클릭된 마커의 ID 업데이트
            });
            await showLocationDetailsModal(location); // 상태 반영된 모달 호출
          },
          child: Image.asset(
            'assets/images/surroundingIcon/surroundingMarker.png',
            width: 50,
            height: 50,
          ),
        ),
      ),
    ];
  }
}
*/

