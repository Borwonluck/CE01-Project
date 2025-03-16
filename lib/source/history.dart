import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryItem {
  final int id;
  final String className;
  final double confidence;
  final int seedCount;
  final String widthCm;
  final String heightCm;
  final String outputImage; // Base64 encoded image
  final DateTime createdAt;
  final String avgBseedWidth;
  final String avgBseedHeight;

  HistoryItem({
    required this.id,
    required this.className,
    required this.confidence,
    required this.seedCount,
    required this.widthCm,
    required this.heightCm,
    required this.outputImage,
    required this.createdAt,
    required this.avgBseedWidth,
    required this.avgBseedHeight,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      className: json['class_name'] ?? "",
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      seedCount: json['seed_count'] ?? 0,
      widthCm:
          json['width_cm'] != null ? json['width_cm'].toString() : "ไม่ระบุ",
      heightCm:
          json['height_cm'] != null ? json['height_cm'].toString() : "ไม่ระบุ",
      outputImage: json['output_image'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
      avgBseedWidth:
          json['width_cm'] != null ? json['width_cm'].toString() : "ไม่ระบุ",
      avgBseedHeight:
          json['height_cm'] != null ? json['height_cm'].toString() : "ไม่ระบุ",
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // เราจะเก็บ HistoryItem เป็น list แม้ว่าจะมีเพียงรายการเดียวจาก API
  List<HistoryItem> historyItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    final url =
        Uri.parse('https://obviously-native-locust.ngrok-free.app/history');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          // ตรวจสอบว่าตัว widget ยังอยู่ใน tree หรือไม่
          setState(() {
            historyItems =
                data.map((item) => HistoryItem.fromJson(item)).toList();
          });
        }
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  // แสดงรายละเอียดของ HistoryItem ใน Dialog
  void _showResultDialog(HistoryItem item) {
    final formattedDate =
        DateFormat('yyyy/MM/dd HH:mm').format(item.createdAt.toLocal());
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
                          child: item.outputImage.isNotEmpty
                              ? Image.memory(
                                  base64Decode(item.outputImage),
                                  fit: BoxFit.contain,
                                )
                              : const Text(
                                  'No Image Available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailBox(
                          'ขนาด:', '${item.widthCm} x ${item.heightCm} ซม.'),
                      _buildDetailBox('ขนาดเมล็ด:',
                          '${item.avgBseedWidth} x ${item.avgBseedHeight} ซม.'),
                      _buildDetailBox('ระยะ:', item.className),
                      _buildDetailBox('จำนวนเมล็ด:', item.seedCount.toString()),
                      _buildDetailBox('วันที่และเวลา:', formattedDate),
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

  Widget _backButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                                  child: item.outputImage.isNotEmpty
                                      ? Image.memory(
                                          base64Decode(item.outputImage),
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
