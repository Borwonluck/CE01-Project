import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String processedImage; // Base64 string ของภาพที่ประมวลผลจาก API
  final String size;
  final String seedSize;
  final String stage;
  final bool isFromHistory;
  final DateTime? createdAt;
  final int? seedCount;

  const ResultPage({
    super.key,
    required this.imagePath,
    this.processedImage = "",
    this.size = '...',
    this.seedSize = '...',
    this.stage = '...',
    this.isFromHistory = false,
    this.createdAt,
    this.seedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ห่อด้วย Container ที่มี gradient เป็นพื้นหลังของทั้งหน้าจอ
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: _buildResultBox(),
                  ),
                  const SizedBox(height: 20),
                  _backButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultBox() {
    Widget imageWidget;

    // หากมี processedImage (Base64 string) ให้นำมาแสดง
    if (processedImage.isNotEmpty) {
      Uint8List imageBytes = base64Decode(processedImage);
      imageWidget = Image.memory(
        imageBytes,
        fit: BoxFit.contain,
      );
    }
    // หากไม่มี processedImage แต่มีไฟล์ imagePath อยู่ ให้แสดงภาพจากไฟล์นั้น
    else if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.contain,
      );
    } else {
      imageWidget = const Text(
        'No Image Available',
        style: TextStyle(color: Colors.grey),
      );
    }

    // ฟอร์แมตวันที่และเวลาให้อยู่ในรูปแบบที่ต้องการ
    String formattedDate = 'ไม่ระบุ';
    String formattedTime = 'ไม่ระบุ';
    if (createdAt != null) {
      formattedDate = DateFormat('yyyy/MM/dd').format(createdAt!);
      formattedTime = DateFormat('HH:mm').format(createdAt!);
    }
    // รวมวันที่และเวลาเป็นสตริงเดียวกัน
    String dateTimeDisplay = '$formattedDate  $formattedTime';

    return Container(
      width: 600,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงภาพใน AspectRatio ที่กำหนดไว้
            Container(
              color: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: imageWidget,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailBox('ขนาด:', size),
            _buildDetailBox('ขนาดของเมล็ด:', seedSize),
            _buildDetailBox('ระยะ:', stage),
            _buildDetailBox('จำนวนเมล็ด:', seedCount?.toString() ?? '...'),
            // แสดงวันที่และเวลาในกล่องเดียวกัน
            _buildDetailBox('วันที่และเวลา:', dateTimeDisplay),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ปุ่มย้อนกลับที่อยู่ด้านล่าง
  Widget _backButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Container ชั้นนอก: ใช้สำหรับเส้นกรอบ gradient
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.lightGreen, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(2), // ความหนาของเส้นกรอบ
            // Container ชั้นใน: ใช้สำหรับพื้นหลังของปุ่มแบบ gradient
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .transparent, // โปร่งใสเพื่อให้เห็น gradient ของ Container ชั้นใน
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'ย้อนกลับ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
