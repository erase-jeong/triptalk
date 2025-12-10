import 'package:flutter/material.dart';

class AutoGuideScreen extends StatelessWidget {
  const AutoGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자동 가이드'),
      ),
      body: const Center(
        child: Text(
          '여기는 자동 가이드 화면입니다.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
