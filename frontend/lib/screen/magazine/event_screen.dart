import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);  // const 생성자 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Event Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
