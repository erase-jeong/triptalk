import 'package:flutter/material.dart';

class AlarmMutesPeriodSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알람 뮤트 기간 설정'),
        backgroundColor: Color(0xFF549062), // AppBar의 색상
      ),
      body: Center(
        child: Text(
          '알람 뮤트 설정 페이지입니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
