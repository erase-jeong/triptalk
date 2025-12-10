/*
import 'package:flutter/material.dart';
import 'package:triptalk/screen/splash_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Kakao SDK 추가
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';  // 백그라운드 서비스
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

void main() async {
  // 앱 실행 전에 NotificationService 인스턴스 생성
  final notificationService = NotificationService();

  WidgetsFlutterBinding.ensureInitialized();

  /*
  // 백그라운드 서비스 시작
  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // 백그라운드 서비스가 시작될 때 실행되는 함수
      isForegroundMode: true,
    ),
  );
   */

  // 백그라운드 서비스 시작
  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // 백그라운드 서비스가 시작될 때 실행되는 함수
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(

      /*
      onForeground: onStart, // iOS에서는 백그라운드 대신 포그라운드 작업
      autoStart: false,  // iOS에서는 수동으로 시작하도록 설정 (필요 시 true로 설정)
      onBackground: (service) {
        WidgetsFlutterBinding.ensureInitialized();
        return true;
      },
      */
    ),
  );

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '325c5a672343c5d92c665b311ee6bad6'); // 네이티브 키

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(MyApp());

}


void onStart(ServiceInstance service) {
  Timer.periodic(Duration(minutes: 5), (timer) async {
    // 위치 서비스가 켜져 있는지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      service.stopSelf();  // 위치 서비스가 꺼져있다면 백그라운드 작업 종료
      return;
    }

    // 위치 권한 확인 및 요청
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        service.stopSelf();  // 권한이 영구적으로 거부된 경우 작업 종료
        return;
      }
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // 관광지 데이터 로드
    List<dynamic> locations = await loadLocations();

    double distanceValue = 3.0;  // 기본 거리 값 설정
    for (var location in locations) {
      double locationLat = double.parse(location['mapY']);
      double locationLon = double.parse(location['mapX']);
      double distance = calculateDistance(position.latitude, position.longitude, locationLat, locationLon);

      // 거리 값에 따른 알림 전송
      if (distance <= distanceValue) {
        NotificationService().showNotification(
          location['title'],
          '${location['title']}가 설정한 거리인 ${distanceValue.toInt()}km 내에 있습니다.',
        );
      }
    }
  });
}

// 거리 계산 함수 (기존에 사용하던 함수와 동일하게 작성)
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371.0; // 지구의 반지름 (단위: km)
  double dLat = _degToRad(lat2 - lat1);
  double dLon = _degToRad(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLon / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;  // km 단위의 거리 반환
}

double _degToRad(double degree) {
  return degree * pi / 180;
}

// 관광지 데이터를 로드하는 함수 (JSON 파일 또는 API 호출)
Future<List<dynamic>> loadLocations() async {
  String jsonString = await rootBundle.loadString('assets/data/locations.json');
  final jsonResponse = json.decode(jsonString);
  return jsonResponse['data'];
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTalk',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          hintColor: Colors.white),
      home: SplashScreen(), // Set SplashScreen as first screen
    );
  }
}

// NotificationService 클래스 정의 (로컬 알림 처리)
class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your_channel_id', 'your_channel_name',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
*/




import 'package:flutter/material.dart';
import 'package:triptalk/screen/splash_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Kakao SDK 추가
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:triptalk/screen/service/notification_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() async {
  // 앱 실행 전에 NotificationService 인스턴스 생성
  final notificationService = NotificationService();

  WidgetsFlutterBinding.ensureInitialized();

  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  // 로컬 푸시 알림 초기화
  await notificationService.init();

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '325c5a672343c5d92c665b311ee6bad6'); //네이티브 키

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(MyApp());

}



class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTalk',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          hintColor: Colors.white),
      home: SplashScreen(), // Set SplashScreen as first screen
    );
  }
}
