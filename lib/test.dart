import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(const ResultPage(
    imagePath: '',
  ));
}

class ResultPage extends StatelessWidget {
  final String imagePath;

  const ResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20), // Margin จากขอบจอ 20px
          decoration: BoxDecoration(
            color: Colors.white, // พื้นหลังของกรอบ
            border: Border.all(color: Colors.green, width: 2), // ขอบสีเขียว
            borderRadius: BorderRadius.circular(8), // มุมโค้ง
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // เงา
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16), // ระยะห่างขอบในของกรอบ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูปภาพ
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8), // เพิ่มมุมโค้งรูป
                    child: imagePath.isNotEmpty && File(imagePath).existsSync()
                        ? AspectRatio(
                            aspectRatio: 3 / 4, // อัตราส่วนที่เหมาะสม 3:4
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover, // ใช้สำหรับให้รูปพอดีกับกรอบ
                            ),
                          )
                        : const Text(
                            'No Image Selected',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ),
                  const SizedBox(height: 16), // ระยะห่างระหว่างรูปกับรายละเอียด

                  // รายละเอียด
                  const Text(
                    'Image Details:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // ระยะห่างระหว่างหัวข้อกับเนื้อหา
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'More details go here. You can keep adding more lines to test the scrolling.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // ข้อความเพิ่มเติมเพื่อทำให้ยาวพอสำหรับเลื่อน
                  const Text(
                    'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7\nLine 8\n'
                    'Line 9\nLine 10\nLine 11\nLine 12\nLine 13\nLine 14\nLine 15',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
