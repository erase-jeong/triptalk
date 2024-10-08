import 'package:flutter/material.dart';

class AiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Screen'),
        backgroundColor: Colors.green, // 상단바 색상 설정
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.computer, // AI 관련 아이콘 (변경 가능)
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to AI Screen!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'This is where AI features will be displayed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // 버튼을 눌렀을 때 동작할 로직 추가
                  Navigator.pop(context); // 이전 화면으로 돌아가기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // 버튼 색상 설정
                ),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
