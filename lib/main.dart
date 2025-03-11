import 'package:flutter/material.dart'; // นำเข้าชุดเครื่องมือสำหรับการสร้าง UI ใน Flutter
import 'package:flutter/services.dart'; // ใช้สำหรับจัดการการตั้งค่าระบบ เช่น การล็อกทิศทางของหน้าจอ
import 'package:camera/camera.dart'; // ไลบรารีสำหรับการทำงานกับกล้องใน Flutter
import 'source/history.dart'; //
import 'source/camera_screen.dart'; // ไฟล์ที่มีหน้าจอแสดงกล้อง
import 'source/result.dart'; // ไฟล์ที่มีหน้าจอแสดงผลลัพธ์รูปภาพ

// ฟังก์ชัน main() เป็นจุดเริ่มต้นของแอป
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // แน่ใจว่า Flutter framework ถูกเตรียมพร้อมก่อนเรียกใช้ API อื่นๆ

  final cameras = await availableCameras();
  // เรียกหาอุปกรณ์กล้องที่มีอยู่ในเครื่อง (อาจมีทั้งกล้องหน้าและกล้องหลัง)

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // กำหนดให้หน้าจอแอปล็อกในแนวตั้งเท่านั้น (ทั้งแบบหงายและคว่ำ)

  runApp(MainApp(cameras: cameras));
  // เริ่มต้นแอปพลิเคชันและส่งข้อมูลกล้องที่พร้อมใช้งานไปยัง MainApp
}

// คลาส MainApp เป็นคลาสหลักที่แสดงผล UI ของแอป
class MainApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  // รับรายการกล้องที่มีอยู่ในเครื่องจาก main()

  const MainApp({super.key, required this.cameras});
  // คอนสตรัคเตอร์ที่ต้องการให้ส่งค่ากล้องมาเมื่อสร้างวัตถุ MainApp

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ซ่อนแถบแสดง "Debug" ที่มุมขวาบนของหน้าจอ

      initialRoute: '/',
      // กำหนดเส้นทางเริ่มต้นของแอปเป็นหน้า '/'

      routes: {
        '/': (context) => MainPage(cameras: cameras),
        // เส้นทาง '/' จะนำไปที่หน้าหลัก (MainPage) พร้อมส่งข้อมูลกล้อง

        '/result': (context) => const ResultPage(
              imagePath: '',
              processedImage: '',
            ),
        // เส้นทาง '/result' จะนำไปที่หน้าผลลัพธ์ (ResultPage) โดยกำหนดค่า imagePath เริ่มต้นเป็นค่าว่าง

        '/history': (context) => HistoryPage(),
      },
    );
  }
}
