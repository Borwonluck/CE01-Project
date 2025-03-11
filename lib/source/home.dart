import 'package:flutter/material.dart';
import 'gallery.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: const CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe8f2e0), // สีพื้นหลังเขียวอ่อน
      appBar: AppBar(
        backgroundColor: const Color(0xff7fbf4d),
        title: const Text(
          '02:25',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Icon(Icons.signal_cellular_4_bar, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.battery_full, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // กล่องใหญ่ตรงกลางเป็นปุ่ม
          Expanded(
            child: GestureDetector(
              // ใช้ GestureDetector เพื่อทำให้กล่องนี้คลิกได้
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(10),
                color: const Color(0xff7fbf4d), // สีเขียวเข้ม
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // ส่วนล่างของ UI
          Container(
            color: const Color(0xffe8f2e0),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ปุ่มซ้าย
                IconButton(
                  icon: const Icon(Icons.add_box, size: 40),
                  color: Colors.green,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GalleryPage()),
                    );
                  },
                ),
                // ปุ่มตรงกลาง
                IconButton(
                  icon: const Icon(Icons.access_time, size: 40),
                  color: Colors.green,
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const HistoryPage()),
                    // );
                  },
                ),
                // ปุ่มขวา - IMAGE PROCESSING
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.green),
                  ),
                  icon: const Icon(Icons.image_search, color: Colors.green),
                  label: const Text(
                    'IMAGE PROCESSING',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          // Bottom navigation bar
          Container(
            color: const Color(0xff7fbf4d), // สีเขียวเข้ม
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.menu, color: Colors.white, size: 30),
                Icon(Icons.circle, color: Colors.white, size: 30),
                Icon(Icons.arrow_back, color: Colors.white, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
