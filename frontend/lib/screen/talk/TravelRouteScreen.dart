import 'package:flutter/material.dart';

class TravelRouteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Red curved arrow
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Icon(
              Icons.arrow_circle_up,
              size: 150,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 50),

          // Audio and text area
          Container(
            padding: EdgeInsets.all(20.0),
            color: Colors.green.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio playback status and prompt
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.pink),
                    SizedBox(width: 10),
                    Text(
                      '오디오 자동 재생 중',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '여행 루트에 맞춰 가주세요!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Place name
                Text(
                  '감천문화마을',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Slider for audio progress
                Slider(
                  value: 0.5,  // This value should be managed in a StatefulWidget
                  onChanged: (value) {
                    // Implement functionality for slider
                  },
                ),

                SizedBox(height: 10),

                // Text description
                Text(
                  '현재 읽고 있는 텍스트 파일. 지금 오디오 재생 중인 건 불투명하게 지나갔거나. 아직 읽히기 전인 것은 투명도를 낮춰서 표현하기',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
