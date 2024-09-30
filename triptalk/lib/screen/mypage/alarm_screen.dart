/*
import 'package:flutter/material.dart';
import 'alarm_mutes_period_settings_screen.dart'; // 새로운 파일 import
import 'alarm_mutes_list.dart'; // 알람 뮤트 리스트 화면 import

class AlarmScreen extends StatefulWidget {
  final String token; // token 필드 추가

  // 생성자에서 token 값을 받도록 설정
  const AlarmScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isPushAlarmOn = true; // Push 알람 스위치 상태
  double alarmDistance = 1.0; // 알람 거리 설정 슬라이더 값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black), // 글자색을 검정으로 설정
        ),
        backgroundColor: Colors.white, // 상단 바 배경을 흰색으로 설정
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상을 검정으로 설정
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // 구분선의 높이 설정
          child: Container(
            color: Color(0xFF549062), // 구분선 색상을 초록색으로 설정
            height: 1.0, // 구분선의 두께
          ),
        ),
        elevation: 0, // 상단바 그림자 제거
      ),
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push 알람 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Push 알람',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Switch(
                  value: isPushAlarmOn,
                  onChanged: (value) {
                    setState(() {
                      isPushAlarmOn = value;
                    });
                  },
                  activeColor: Color(0xFF549062), // 스위치 색상
                ),
              ],
            ),
            SizedBox(height: 16),

            // Push 알람 거리 설정 텍스트
            Text(
              'Push 알람 거리 설정',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),

            /*
            // 알람 거리 설정 슬라이더
            Slider(
              value: alarmDistance,
              min: 0,
              max: 4,
              divisions: 4,
              activeColor: Color(0xFF549062),
              inactiveColor: Colors.grey,
              onChanged: (double value) {
                setState(() {
                  alarmDistance = value;
                });
              },
            ),
            */


            SizedBox(height: 24),

            // 알람 뮤트 관광지 리스트 (클릭 시 alarm_mutes_list.dart로 이동)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesListScreen(token: widget.token)), // 페이지 전환
                );
              },
              child: Text(
                '알람 뮤트 관광지 리스트',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(height: 16),

            // 알람 뮤트 기간 설정
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesPeriodSettingsScreen()), // 페이지 전환
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '알람 뮤트 기간 설정',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      '영원히',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

*/

/*
import 'package:flutter/material.dart';
import 'alarm_mutes_period_settings_screen.dart'; // 새로운 파일 import
import 'alarm_mutes_list.dart'; // 알람 뮤트 리스트 화면 import
import 'package:triptalk/screen/map/map_screen.dart';
import 'package:triptalk/screen/main_screen.dart';

class AlarmScreen extends StatefulWidget {
  final String token; // token 필드 추가

  // 생성자에서 token 값을 받도록 설정
  const AlarmScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isPushAlarmOn = true; // Push 알람 스위치 상태
  String selectedDistance = "3km"; // 거리선택 기본값
  int distanceValue = 3; // 숫자 값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black), // 글자색을 검정으로 설정
        ),
        backgroundColor: Colors.white, // 상단 바 배경을 흰색으로 설정
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상을 검정으로 설정
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // 구분선의 높이 설정
          child: Container(
            color: Color(0xFF549062), // 구분선 색상을 초록색으로 설정
            height: 1.0, // 구분선의 두께
          ),
        ),
        elevation: 0, // 상단바 그림자 제거
      ),
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push 알람 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Push 알람',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Switch(
                  value: isPushAlarmOn,
                  onChanged: (value) {
                    setState(() {
                      isPushAlarmOn = value;
                    });
                  },
                  activeColor: Color(0xFF549062), // 스위치 색상
                ),
              ],
            ),
            SizedBox(height: 16),

            // Push 알람 거리 설정 텍스트
            Text(
              'Push 알람 거리 설정',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),


            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // 테두리 설정
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                value: selectedDistance,
                isExpanded: true, // 드롭다운이 가로로 확장되도록 설정
                underline: SizedBox(), // 기본 밑줄 제거
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDistance = newValue!;
                    distanceValue = int.parse(newValue.replaceAll('km', '')); // 'km' 제거 후 숫자로 변환
                  });
                },
                items: <String>['3km', '7km', '12km', '20km']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

// 다른 페이지로 값 전달

            ElevatedButton(
              onPressed: () {
                // 첫 번째 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      token: widget.token,
                      distanceValue: distanceValue,
                    ),
                  ),
                ).then((_) {
                  // 두 번째 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(
                        token: widget.token,
                        distanceValue: distanceValue,
                      ),
                    ),
                  );
                });
              },
              child: Text('다음 페이지로 이동'),
            )
          /*
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(token: widget.token, distanceValue: distanceValue),
                  ),
                );
              },
              child: Text('다음 페이지로 이동'),
            ),
           */





            /*
            // 거리 선택 드롭다운
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // 테두리 설정
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                value: selectedDistance,
                isExpanded: true, // 드롭다운이 가로로 확장되도록 설정
                underline: SizedBox(), // 기본 밑줄 제거
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDistance = newValue!;
                  });
                },
                items: <String>['3km', '7km', '12km', '20km']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            */
            ,SizedBox(height: 24),

            // 알람 뮤트 관광지 리스트 (클릭 시 alarm_mutes_list.dart로 이동)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesListScreen(token: widget.token)), // 페이지 전환
                );
              },
              child: Text(
                '알람 뮤트 관광지 리스트',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(height: 16),

            // 알람 뮤트 기간 설정
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesPeriodSettingsScreen()), // 페이지 전환
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '알람 뮤트 기간 설정',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      '영원히',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'alarm_mutes_period_settings_screen.dart'; // 새로운 파일 import
import 'alarm_mutes_list.dart'; // 알람 뮤트 리스트 화면 import
import 'package:triptalk/screen/map/map_screen.dart';
import 'package:triptalk/screen/main_screen.dart';

class AlarmScreen extends StatefulWidget {
  final String token; // token 필드 추가

  // 생성자에서 token 값을 받도록 설정
  const AlarmScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isPushAlarmOn = true; // Push 알람 스위치 상태
  String selectedDistance = "3km"; // 거리선택 기본값
  int distanceValue = 3; // 숫자 값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black), // 글자색을 검정으로 설정
        ),
        backgroundColor: Colors.white, // 상단 바 배경을 흰색으로 설정
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상을 검정으로 설정
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // 구분선의 높이 설정
          child: Container(
            color: Color(0xFF549062), // 구분선 색상을 초록색으로 설정
            height: 1.0, // 구분선의 두께
          ),
        ),
        elevation: 0, // 상단바 그림자 제거
      ),
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push 알람 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Push 알람',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Switch(
                  value: isPushAlarmOn,
                  onChanged: (value) {
                    setState(() {
                      isPushAlarmOn = value;
                    });
                  },
                  activeColor: Color(0xFF549062), // 스위치 색상
                ),
              ],
            ),
            SizedBox(height: 16),

            // Push 알람 거리 설정 텍스트
            Text(
              'Push 알람 거리 설정',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // 테두리 설정
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                value: selectedDistance,
                isExpanded: true, // 드롭다운이 가로로 확장되도록 설정
                underline: SizedBox(), // 기본 밑줄 제거
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDistance = newValue!;
                    distanceValue = int.parse(newValue.replaceAll('km', '')); // 'km' 제거 후 숫자로 변환
                  });
                },
                items: <String>['3km', '7km', '12km', '20km'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 24),

            // 거리 값을 MainScreen으로 전달 (pop)
            ElevatedButton(
              onPressed: () {
                // 선택한 distanceValue를 반환하며 이전 화면으로 이동
                Navigator.pop(context, distanceValue);
                print('[alarm] distanceValue 반환: $distanceValue');
              },
              child: Text('설정 완료'),
            ),

            SizedBox(height: 24),

            // 알람 뮤트 관광지 리스트 (클릭 시 alarm_mutes_list.dart로 이동)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesListScreen(token: widget.token)),
                );
              },
              child: Text(
                '알람 뮤트 관광지 리스트',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(height: 16),

            // 알람 뮤트 기간 설정
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesPeriodSettingsScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '알람 뮤트 기간 설정',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      '영원히',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'alarm_mutes_period_settings_screen.dart'; // 새로운 파일 import
import 'alarm_mutes_list.dart'; // 알람 뮤트 리스트 화면 import
import 'package:triptalk/screen/map/map_screen.dart';
import 'package:triptalk/screen/main_screen.dart';

class AlarmScreen extends StatefulWidget {
  final String token; // token 필드 추가

  // 생성자에서 token 값을 받도록 설정
  const AlarmScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isPushAlarmOn = true; // Push 알람 스위치 상태
  String selectedDistance = "3km"; // 거리선택 기본값
  int distanceValue = 3; // 숫자 값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black), // 글자색을 검정으로 설정
        ),
        backgroundColor: Colors.white, // 상단 바 배경을 흰색으로 설정
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상을 검정으로 설정
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // 구분선의 높이 설정
          child: Container(
            color: Color(0xFF549062), // 구분선 색상을 초록색으로 설정
            height: 1.0, // 구분선의 두께
          ),
        ),
        elevation: 0, // 상단바 그림자 제거
      ),
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push 알람 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Push 알람',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Switch(
                  value: isPushAlarmOn,
                  onChanged: (value) {
                    setState(() {
                      isPushAlarmOn = value;
                    });
                  },
                  activeColor: Color(0xFF549062), // 스위치 색상
                ),
              ],
            ),
            SizedBox(height: 16),

            // Push 알람 거리 설정 텍스트
            Text(
              'Push 알람 거리 설정',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // 테두리 설정
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                value: selectedDistance,
                isExpanded: true, // 드롭다운이 가로로 확장되도록 설정
                underline: SizedBox(), // 기본 밑줄 제거
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDistance = newValue!;
                    distanceValue = int.parse(newValue.replaceAll('km', '')); // 'km' 제거 후 숫자로 변환
                  });
                },
                items: <String>['3km', '7km', '12km', '20km']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 24),

            // 거리 값을 MainScreen으로 전달 (pop)
            ElevatedButton(
              onPressed: () {
                // 선택한 distanceValue를 반환하며 이전 화면으로 이동
                Navigator.pop(context, distanceValue);
              },
              child: Text('설정 완료'),
            ),

            SizedBox(height: 24),

            // 알람 뮤트 관광지 리스트 (클릭 시 alarm_mutes_list.dart로 이동)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesListScreen(token: widget.token)),
                );
              },
              child: Text(
                '알람 뮤트 관광지 리스트',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(height: 16),

            // 알람 뮤트 기간 설정
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmMutesPeriodSettingsScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '알람 뮤트 기간 설정',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      '영원히',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/

