import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 알림을 여러 개 쌓을 수 있도록 고유한 ID 부여
  Future<void> showNotification(String title, String message) async {
    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000); // 고유한 알림 ID 생성

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'location_channel',
      'Location Channel',
      channelDescription: 'This channel is used for location notifications',
      importance: Importance.high,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      notificationId, // 고유한 ID 사용
      title,
      message,
      notificationDetails,
    );
  }

  Future<PermissionStatus> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status;
  }
}


/*
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // 싱글톤 패턴을 사용하기 위한 private static 변수
  static final NotificationService _instance = NotificationService._();

  // NotificationService 인스턴스 반환
  factory NotificationService() {
    return _instance;
  }

  // private 생성자
  NotificationService._();

  // 로컬 푸시 알림을 사용하기 위한 플러그인 인스턴스 생성
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 초기화 작업을 위한 메서드 정의
  Future<void> init() async {
    // 알림을 표시할 때 사용할 로고를 지정
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 안드로이드 플랫폼에서 사용할 초기화 설정
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    // 로컬 푸시 알림을 초기화
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 푸시 알림 생성
  Future<void> showNotification(String title, String message) async {
    const int notificationId = 0;

    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'location_channel', // 알림 채널 ID
      'Location Channel', // 알림 채널 이름
      channelDescription: 'This channel is used for location-related notifications',
      importance: Importance.high, // 알림 중요도
    );

    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title, // 알림 제목 (관광지 이름)
      message, // 알림 메시지 (관광지에 대한 정보)
      notificationDetails,
    );
  }

  // 푸시 알림 권한 요청
  Future<PermissionStatus> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status;
  }
}
*/


//단순 알림 띄우기

/*
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // 싱글톤 패턴을 사용하기 위한 private static 변수
  static final NotificationService _instance = NotificationService._();
  // NotificationService 인스턴스 반환
  factory NotificationService() {
    return _instance;
  }
  // private 생성자
  NotificationService._();
  // 로컬 푸시 알림을 사용하기 위한 플러그인 인스턴스 생성
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 초기화 작업을 위한 메서드 정의
  Future<void> init() async {
    // 알림을 표시할 때 사용할 로고를 지정
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    // 안드로이드 플랫폼에서 사용할 초기화 설정
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    // 로컬 푸시 알림을 초기화
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 푸시 알림 생성
  Future<void> showNotification() async {
    // 푸시 알림의 ID
    const int notificationId = 0;
    // 알림 채널 설정값 구성
    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'counter_channel', // 알림 채널 ID
      'Counter Channel', // 알림 채널 이름
      channelDescription: 'This channel is used for counter-related notifications',
      // 알림 채널 설명
      importance: Importance.high, // 알림 중요도
    );
    // 알림 상세 정보 설정
    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    // 알림 보이기
    await flutterLocalNotificationsPlugin.show(
      notificationId, // 알림 ID
      '알림', // 알림 제목 (수정됨)
      '알림이 출력되었습니다', // 알림 메시지 (수정됨)
      notificationDetails, // 알림 상세 정보
    );
  }

  // 푸시 알림 권한 요청
  Future<PermissionStatus> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status;
  }
}
*/

/*
//타이머 알림바 코드
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // 싱글톤 패턴을 사용하기 위한 private static 변수
  static final NotificationService _instance = NotificationService._();
  // NotificationService 인스턴스 반환
  factory NotificationService() {
    return _instance;
  }
  // private 생성자
  NotificationService._();
  // 로컬 푸시 알림을 사용하기 위한 플러그인 인스턴스 생성
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  // 초기화 작업을 위한 메서드 정의
  Future<void> init() async {
    // 알림을 표시할 때 사용할 로고를 지정
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    // 안드로이드 플랫폼에서 사용할 초기화 설정
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    // 로컬 푸시 알림을 초기화
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  // 푸시 알림 생성
  Future<void> showNotification(int targetNumber) async {
    // 푸시 알림의 ID
    const int notificationId = 0;
    // 알림 채널 설정값 구성
    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'counter_channel', // 알림 채널 ID
      'Counter Channel', // 알림 채널 이름
      channelDescription:
      'This channel is used for counter-related notifications',
      // 알림 채널 설명
      importance: Importance.high, // 알림 중요도
    );
    // 알림 상세 정보 설정
    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    // 알림 보이기
    await flutterLocalNotificationsPlugin.show(
      notificationId, // 알림 ID
      '목표 도달', // 알림 제목
      '$targetNumber 회 눌렀습니다!', // 알림 메시지
      notificationDetails, // 알림 상세 정보
    );
  }
  // 푸시 알림 권한 요청
  Future<PermissionStatus> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status;
  }
}

 */

