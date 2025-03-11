import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'result.dart';

class HistoryItem {
  final String
      imagePath; // เนื่องจาก API ไม่ส่ง raw image กลับมา เราจะกำหนดเป็นค่าว่าง
  final String processedImage; // ใช้ field output_image จาก API (Base64 string)
  final String size; // ไม่มีข้อมูลจริงจาก API => กำหนดเป็น "ไม่ระบุ"
  final String seedSize; // ไม่มีข้อมูลจริงจาก API => กำหนดเป็น "ไม่ระบุ"
  final String
      stage; // ใช้ field class_name จาก API (คุณอาจแปลเป็นภาษาไทยเพิ่มเติมภายหลัง)
  final DateTime createdAt; // ดึงจาก created_at ใน API
  final int seedCount; // จาก seed_count ใน API

  HistoryItem({
    required this.imagePath,
    required this.processedImage,
    required this.size,
    required this.seedSize,
    required this.stage,
    required this.createdAt,
    required this.seedCount,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      imagePath: "", // API ไม่ส่ง raw image กลับมา
      processedImage: json['output_image'] ?? '',
      size: json['size'] ?? "ไม่ระบุ",
      seedSize: json['seedSize'] ?? "ไม่ระบุ",
      stage: json['class_name'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
      seedCount: json['seed_count'] ?? 0,
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> historyItems = [];

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    // URL ของ API จาก bitterbeanAPI.py ที่ดึงข้อมูลประวัติจาก PostgreSQL
    final url =
        Uri.parse('https://solely-driving-grackle.ngrok-free.app/history');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          historyItems =
              data.map((item) => HistoryItem.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  // ฟังก์ชันแสดงรายละเอียดใน pop-up (Dialog) เมื่อผู้ใช้กดที่รายการประวัติ
  void _showResultDialog(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightGreen, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container สำหรับแสดงภาพ (คล้ายกับใน result.dart)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.processedImage.isNotEmpty
                              ? Image.memory(
                                  base64Decode(item.processedImage),
                                  fit: BoxFit.contain,
                                )
                              : const Text(
                                  'No Image Available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailBox('ขนาด:', item.size),
                      _buildDetailBox('ขนาดของเมล็ด:', item.seedSize),
                      _buildDetailBox('ระยะ:', item.stage),
                      _buildDetailBox('จำนวนเมล็ด:', item.seedCount.toString()),
                      _buildDetailBox(
                        'วันที่และเวลา:',
                        DateFormat('yyyy/MM/dd HH:mm')
                            .format(item.createdAt.toLocal()),
                      ),
                      const SizedBox(height: 16),
                      _backButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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

  // ปุ่มย้อนกลับที่อยู่ด้านล่างของหน้าประวัติ
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
                colors: [Colors.white, Colors.lightGreen],
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
                  colors: [Colors.lightGreen, Colors.green],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightGreen, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: historyItems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding:
                      const EdgeInsets.only(top: 20), // เพิ่ม padding top 10px
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: historyItems.length,
                          itemBuilder: (context, index) {
                            final item = historyItems[index];
                            final formattedDateTime =
                                DateFormat('yyyy/MM/dd HH:mm')
                                    .format(item.createdAt.toLocal());
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.green, width: 2),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item.processedImage.isNotEmpty
                                      ? Image.memory(
                                          base64Decode(item.processedImage),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image,
                                          size: 50, color: Colors.green),
                                ),
                                title: Text(
                                  'วันที่และเวลา: $formattedDateTime',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  _showResultDialog(item);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      _backButtons(context),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
