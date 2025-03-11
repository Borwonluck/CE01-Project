import 'package:flutter/material.dart';

void main() {
  runApp(const GalleryPage());
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.green),
      home: const GalleryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String dropdownValue = 'All'; // เก็บสถานะของ Dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f9e6), // สีเขียวอ่อนพื้นหลัง
      appBar: AppBar(
        backgroundColor: const Color(0xff7fbf4d), // สีเขียวเข้ม
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ปุ่ม Back
            GestureDetector(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 30),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Dropdown อยู่ตรงกลาง
            Expanded(
              child: Center(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  dropdownColor: const Color(0xff7fbf4d),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text(
                        'All',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Album',
                      child: Text(
                        'Album',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!; // อัปเดตค่าที่เลือก
                    });
                  },
                ),
              ),
            ),
            // Spacer เพื่อจัดตำแหน่ง
            const SizedBox(width: 50),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 คอลัมน์
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 7, // จำนวนภาพ
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                color: const Color(0xfff3f9e6),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            );
          },
        ),
      ),
      // แถบ Navigation ด้านล่าง
      bottomNavigationBar: Container(
        color: const Color(0xff7fbf4d), // สีเขียวเข้ม
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.menu, color: Colors.white, size: 30),
            Icon(Icons.circle_outlined, color: Colors.white, size: 30),
            Icon(Icons.arrow_back, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}
