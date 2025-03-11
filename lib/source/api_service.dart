import 'package:http/http.dart' as http;
import 'dart:convert';

// URL ของเซิร์ฟเวอร์ (แก้ไข IP เป็น 192.168.0.109 ตามที่ต้องการ)
const String baseUrl = 'http://172.16.13.182:3000';

// ฟังก์ชันบันทึกข้อมูลลงฐานข้อมูล โดยส่งทั้ง rawImage และ processedImage ไปยัง Server
Future<void> saveDataToDatabase(
  String imagePath, // รูปจากกล้อง/Gallery
  String processedImage, // รูปที่ผ่านการประมวลผลจาก API
  String size,
  String seedSize,
  String stage,
  DateTime createdAt,
  int seedCount,
) async {
  final url = Uri.parse('$baseUrl/save-data');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'imagePath': imagePath,
      'processedImage': processedImage,
      'size': size,
      'seedSize': seedSize,
      'stage': stage,
      'createdAt': createdAt.toIso8601String(),
      'seedCount': seedCount,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save data');
  }
}

// ฟังก์ชันดึงข้อมูลประวัติจากฐานข้อมูล (ไม่จำเป็นต้องแก้ไขเพิ่มเติม)
Future<List<Map<String, dynamic>>> fetchHistoryFromDatabase() async {
  final url = Uri.parse('$baseUrl/get-history');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to fetch history');
  }
}
