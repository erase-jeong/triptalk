import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationNotificationService {
  // flutterLocalNotificationsPlugin을 non-nullable로 즉시 초기화
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // positionStream은 nullable로 선언
  StreamSubscription<Position>? positionStream;

  // 생성자에서 알림 초기화
  LocationNotificationService() {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 위치 추적 권한 체크
  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스를 활성화하세요.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 필요합니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }
  }

  // 위치 업데이트 시작
  void startLocationUpdates() {
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // 100미터 마다 업데이트
    );

    // 위치 업데이트 스트림 시작
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _showLocationNotification(position.latitude, position.longitude);
    });
  }

  // 알림 표시
  Future<void> _showLocationNotification(double latitude, double longitude) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // 채널 ID
      'your_channel_name', // 채널 이름
      channelDescription: 'your_channel_description', // 채널 설명
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // 알림 ID
      '현재 위치 정보', // 알림 제목
      '위도: $latitude, 경도: $longitude', // 알림 본문
      platformChannelSpecifics, // 알림 세부 설정
      payload: '위치 정보 알림', // 선택적 인자 (null 가능)
    );
  }

  // 스트림 취소 (리소스 해제)
  void dispose() {
    // positionStream이 null이 아닌 경우에만 취소
    positionStream?.cancel();
  }
}


/*
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationNotificationService {
  // flutterLocalNotificationsPlugin을 non-nullable로 즉시 초기화
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // positionStream은 nullable로 선언
  StreamSubscription<Position>? positionStream;

  // 생성자에서 알림 초기화
  LocationNotificationService() {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 위치 추적 권한 체크
  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스를 활성화하세요.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 필요합니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }
  }

  // 위치 업데이트 시작
  void startLocationUpdates() {
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // 100미터 마다 업데이트
    );

    // 위치 업데이트 스트림 시작
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _showLocationNotification(position.latitude, position.longitude);
    });
  }

  // 알림 표시
  Future<void> _showLocationNotification(double latitude, double longitude) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, // 알림 ID
        '현재 위치 정보', // 알림 제목
        '위도: $latitude, 경도: $longitude', // 알림 내용
        platformChannelSpecifics, // 알림 세부 설정
        payload: '위치 정보 알림' // 선택적 인자
    );
  }

  // 스트림 취소 (리소스 해제)
  void dispose() {
    // positionStream이 null이 아닌 경우에만 취소
    positionStream?.cancel();
  }
}
*/


/*
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationNotificationService {
  // flutterLocalNotificationsPlugin을 non-nullable로 즉시 초기화
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // positionStream은 nullable로 선언
  StreamSubscription<Position>? positionStream;

  // 생성자에서 알림 초기화
  LocationNotificationService() {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 위치 추적 권한 체크
  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스를 활성화하세요.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 필요합니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }
  }

  // 위치 업데이트 시작
  void startLocationUpdates() {
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // 100미터 마다 업데이트
    );

    // 위치 업데이트 스트림 시작
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _showLocationNotification(position.latitude, position.longitude);
    });
  }


  // 알림 표시
  Future<void> _showLocationNotification(double latitude, double longitude) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      '현재 위치 정보',
      '위도: $latitude, 경도: $longitude',
      platformChannelSpecifics,
      payload: '위치 정보 알림',
    );
  }

  // 스트림 취소 (리소스 해제)
  void dispose() {
    // positionStream이 null이 아닌 경우에만 취소
    positionStream?.cancel();
  }
}

*/