import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Hàm main là điểm bắt đầu của ứng dụng
void main() {
  runApp(const MainApp()); // Chạy ứng dụng với widget MainApp
}

/// Widget MainApp là widget gốc của ứng dụng, sử dụng một StatelessWidget
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt biểu tượng debug ở góc phải trên
      title: 'Ứng dụng full-stack flutter đơn giản',
      home: MyHomePage(),
    );
  }
}

/// Widget MyHomePage là trang chính của ứng dụng, sử dụng StatefulWidget
/// để quản lý trạng thái do có nội dung cần thay đổi trên trang này
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Lớp state cho MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  /// Controller để lấy dữ liệu từ Widget TextField
  final controller = TextEditingController();

  /// Biến để lưu thông điệp phản hồi từ server
  String responseMessage = '';

  /// Biến để theo dõi quá trình gửi yêu cầu
  bool isLoading = false;

  /// Sử dụng địa chỉ IP thích hợp cho backend
  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080'; // hoặc sử dụng IP LAN nếu cần
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // cho emulator
    } else {
      return 'http://localhost:8080';
    }
  }

  /// Hàm để gửi tên tới server
  Future<void> sendName() async {
    final name = controller.text.trim();

    // Kiểm tra nếu tên trống
    if (name.isEmpty) {
      _showSnackbar('Vui lòng nhập tên');
      return;
    }

    // Sau khi lấy được tên thì xóa nội dung trong controller
    controller.clear();

    setState(() {
      isLoading = true; // Bắt đầu hiển thị tiến trình
    });

    final backendUrl = getBackendUrl();
    final url = Uri.parse('$backendUrl/api/v1/submit');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.body.isNotEmpty) {
        final data = json.decode(response.body);

        setState(() {
          responseMessage = data['message'] ?? 'Phản hồi không rõ ràng';
        });
      } else {
        setState(() {
          responseMessage = 'Không nhận được phản hồi từ server';
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Đã xảy ra lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false; // Kết thúc hiển thị tiến trình
      });
    }
  }

  /// Hiển thị Snackbar với thông báo
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng full-stack flutter đơn giản'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Tên',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: sendName,
                      child: const Text('Gửi', style: TextStyle(fontSize: 16)),
                    ),
                  ),
            const SizedBox(height: 20),
            if (responseMessage.isNotEmpty)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Card(
                  color: Colors.lightBlueAccent.shade100,
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      responseMessage,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
