import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_camera_application_1/source/result.dart';
import 'history.dart';

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MainPage({super.key, required this.cameras});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  bool isFlashOn = false;
  bool isGridEnabled = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    startCamera(0);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void startCamera(int cameraIndex) {
    cameraController = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  // Helper function สำหรับ map stage จากภาษาอังกฤษเป็นภาษาไทย
  String mapStage(String stage) {
    // หากมีหลายค่า (คั่นด้วย comma) ให้แยกและ map แต่ละส่วนแล้ว join กลับ
    List<String> parts = stage.split(',');
    List<String> mappedParts = parts.map((s) {
      s = s.trim().toLowerCase();
      if (s == 'unripe') {
        return 'อ่อน';
      } else if (s == 'ripe') {
        return 'สุก';
      } else if (s == 'overripe') {
        return 'แก่เกินสุก';
      } else {
        return s;
      }
    }).toList();
    return mappedParts.join(', ');
  }

  void takePicture() async {
    if (!cameraController.value.isInitialized ||
        cameraController.value.isTakingPicture) {
      return;
    }

    try {
      if (isFlashOn) {
        await cameraController.setFlashMode(FlashMode.torch);
      } else {
        await cameraController.setFlashMode(FlashMode.off);
      }

      final image = await cameraController.takePicture();

      // ปิด flash mode หากเปิดอยู่
      if (cameraController.value.flashMode == FlashMode.torch) {
        await cameraController.setFlashMode(FlashMode.off);
      }

      if (!context.mounted) return;

      // บันทึกเวลาเริ่มต้นก่อนส่ง API
      final startTime = DateTime.now();

      // แสดง pop-up แจ้ง "กำลังประมวลผลอยู่ กรุณารอสักครู่"
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.lightGreen, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "กำลังประมวลผลอยู่ กรุณารอสักครู่",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // ส่งรูปต้นฉบับไปยัง API (โดยไม่ลบพื้นหลัง)
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://solely-driving-grackle.ngrok-free.app/detect'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      var response = await request.send();

      // อ่าน response body
      var responseBody = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseBody);

      // คำนวณเวลาที่ API ใช้และถ้ายังไม่ครบ 2 วินาที ให้รอเพิ่ม
      final elapsed = DateTime.now().difference(startTime);
      const minDuration = Duration(seconds: 2);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }

      // ปิด pop-up หลังจากครบเวลาและ API ส่งค่ากลับมา
      Navigator.pop(context);

      if (response.statusCode == 200) {
        int seedCount = jsonData['seedCount'];
        String createdAt = jsonData['createdAt'];
        String processedImage = jsonData['processedImage'] ?? "";

        // รับข้อมูล detections จาก API
        List<dynamic> detections = jsonData['detections'] ?? [];
        String stage;
        String width_cm = "";
        String height_cm = "";
        String avgBseedWidth = "";
        String avgBseedHeight = "";
        if (detections.isNotEmpty) {
          var firstDet = detections.first;
          width_cm = firstDet['width_cm']?.toString() ?? "";
          height_cm = firstDet['height_cm']?.toString() ?? "";
          avgBseedWidth = jsonData['avgBseedWidth']?.toString() ?? "";
          avgBseedHeight = jsonData['avgBseedHeight']?.toString() ?? "";
          stage = detections.map((d) => d['class']).join(', ');
          stage = mapStage(stage);
        } else {
          stage = 'ไม่ระบุ';
        }

        if (!context.mounted) return;

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(
              imagePath: image.path,
              processedImage: processedImage,
              stage: stage,
              seedCount: seedCount,
              createdAt: DateTime.parse(createdAt),
              width_cm: width_cm,
              height_cm: height_cm,
              avgBseedWidth: avgBseedWidth,
              avgBseedHeight: avgBseedHeight,
            ),
          ),
        );
      } else {
        debugPrint('Error: API ส่งค่ากลับมาไม่สำเร็จ');
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> selectImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      try {
        final startTime = DateTime.now();

        // แสดง pop-up แจ้ง "กำลังประมวลผลอยู่ กรุณารอสักครู่"
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.lightGreen, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "กำลังประมวลผลอยู่ กรุณารอสักครู่",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // ส่งรูปต้นฉบับไปยัง API (โดยไม่ลบพื้นหลัง)
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://solely-driving-grackle.ngrok-free.app/detect'),
        );
        request.files.add(
          await http.MultipartFile.fromPath('file', pickedFile.path),
        );

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);

        final elapsed = DateTime.now().difference(startTime);
        const minDuration = Duration(seconds: 2);
        if (elapsed < minDuration) {
          await Future.delayed(minDuration - elapsed);
        }

        Navigator.pop(context);

        if (response.statusCode == 200) {
          String processedImage = jsonData['processedImage'] ?? "";
          int seedCount = jsonData['seedCount'];
          String createdAt = jsonData['createdAt'];

          List<dynamic> detections = jsonData['detections'] ?? [];
          String stage;
          String width_cm = "";
          String height_cm = "";
          String avgBseedWidth = "";
          String avgBseedHeight = "";
          if (detections.isNotEmpty) {
            var firstDet = detections.first;
            width_cm = firstDet['width_cm']?.toString() ?? "";
            height_cm = firstDet['height_cm']?.toString() ?? "";
            avgBseedWidth = jsonData['avgBseedWidth']?.toString() ?? "";
            avgBseedHeight = jsonData['avgBseedHeight']?.toString() ?? "";
            stage = detections.map((d) => d['class']).join(', ');
            stage = mapStage(stage);
          } else {
            stage = 'ไม่ระบุ';
          }

          if (!context.mounted) return;

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResultPage(
                imagePath: pickedFile.path,
                processedImage: processedImage,
                stage: stage,
                seedCount: seedCount,
                createdAt: DateTime.parse(createdAt),
                width_cm: width_cm,
                height_cm: height_cm,
                avgBseedWidth: avgBseedWidth,
                avgBseedHeight: avgBseedHeight,
              ),
            ),
          );
        } else {
          debugPrint('Error: API ส่งค่ากลับมาไม่สำเร็จ');
        }
      } catch (e) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        debugPrint('Error selecting image from gallery: $e');
      }
    }
  }

  // Build the camera preview with optional grid
  Widget buildCameraPreview(Size size) {
    double previewWidth = 340;
    double previewHeight = 450;

    return SafeArea(
      child: FutureBuilder(
        future: cameraValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Container(
                width: previewWidth,
                height: previewHeight,
                // Container นี้เป็น "กรอบ" ที่มี gradient border
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.lightGreen, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                // Padding เพื่อสร้างพื้นที่สำหรับ border thickness
                child: Padding(
                  padding: const EdgeInsets.all(
                      3), // ปรับความหนาของ border ได้ที่นี่
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Container(
                          width: previewWidth,
                          height: previewHeight,
                          color: Colors.black,
                          child: CameraPreview(cameraController),
                        ),
                        if (isGridEnabled)
                          SizedBox(
                            width: previewWidth,
                            height: previewHeight,
                            child: CustomPaint(
                              painter: GridPainter(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  // Build the top menu bar
  Widget buildTopMenuBar() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ปุ่มแกลลอรี่ที่มีเส้นกรอบแบบ gradient
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.lightGreen, Colors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: FloatingActionButton.extended(
                    heroTag: 'gallery',
                    backgroundColor: Colors
                        .transparent, // ให้โปร่งใสเพื่อให้เห็นพื้นหลังจาก Container ชั้นใน
                    elevation: 0,
                    onPressed: selectImageFromGallery,
                    icon: const Icon(Icons.photo_album,
                        size: 24, color: Colors.white),
                    label: const Text(
                      'แกลลอรี่',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // ปุ่มประวัติที่มีเส้นกรอบแบบ gradient
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.lightGreen, Colors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: FloatingActionButton.extended(
                    heroTag: 'history',
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryPage()),
                      );
                    },
                    icon: const Icon(Icons.history,
                        size: 24, color: Colors.white),
                    label: const Text(
                      'ประวัติ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the bottom menu bar
  // Helper widget สำหรับสร้าง FloatingActionButton ที่มีพื้นหลัง gradient แบบ circular
  // Helper widget สำหรับสร้าง FloatingActionButton ที่มีเส้นกรอบ gradient แบบ circular
  Widget _buildGradientBorderFAB({
    required Widget child,
    required VoidCallback onPressed,
    String? heroTag,
  }) {
    return Container(
      width: 60, // กำหนดความกว้างของปุ่ม
      height: 60, // กำหนดความสูงของปุ่ม
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.white, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2), // ความหนาของเส้นกรอบ
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: Colors
              .transparent, // ให้โปร่งใสเพื่อให้เห็นพื้นหลังของ Container ชั้นใน
          elevation: 0,
          shape: const CircleBorder(),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }

  Widget buildBottomMenuBar() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGradientBorderFAB(
                heroTag: 'toggle_grid',
                onPressed: () {
                  setState(() {
                    isGridEnabled = !isGridEnabled;
                  });
                },
                child: const Icon(
                  Icons.grid_4x4,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              _buildGradientBorderFAB(
                heroTag: 'camera',
                onPressed: takePicture,
                child: const Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              _buildGradientBorderFAB(
                heroTag: 'flash_toggle',
                onPressed: () {
                  setState(() {
                    isFlashOn = !isFlashOn;
                  });
                },
                child: Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // ตั้งค่า backgroundColor ให้เป็น transparent หากต้องการให้ gradient ปรากฏขึ้นทั่วทั้งหน้าจอ
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen], // เปลี่ยนสีตามที่ต้องการ
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            buildCameraPreview(size),
            buildTopMenuBar(),
            buildBottomMenuBar(),
          ],
        ),
      ),
    );
  }
}

// Draw grid lines for the camera
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final stepX = size.width / 3;
    for (double x = stepX; x < size.width; x += stepX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final stepY = size.height / 3;
    for (double y = stepY; y < size.height; y += stepY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
