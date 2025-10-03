import 'package:flutter/material.dart';
import '../services/qr_scanner_service.dart';
import '../services/museum_service.dart';
import 'artifact_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon QR code lớn
            Icon(
              Icons.qr_code_scanner,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),

            // Tiêu đề
            const Text(
              'Quét mã QR hiện vật',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Nhấn nút bên dưới để mở camera và quét mã QR trên hiện vật để xem thông tin chi tiết',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Nút quét QR
            if (!isProcessing)
              ElevatedButton.icon(
                onPressed: _scanQRCode,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Quét mã QR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              )
            else
              // Loading indicator khi đang xử lý
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải thông tin hiện vật...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Hướng dẫn
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Hướng dẫn sử dụng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Tìm mã QR trên biển thông tin hiện vật\n'
                    '• Nhấn "Quét mã QR" để mở camera\n'
                    '• Hướng camera về phía mã QR\n'
                    '• Chờ ứng dụng tự động nhận diện',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanQRCode() async {
    setState(() {
      isProcessing = true;
    });

    try {
      // Gọi service để quét QR code với BuildContext
      final String? qrData = await QRScannerService.scanQRCode(context);

      if (qrData != null && qrData.isNotEmpty) {
        await _processQRCode(qrData);
      } else {
        // Người dùng hủy quét hoặc không quét được
        _showMessage('Quét mã QR bị hủy');
      }
    } catch (e) {
      _showErrorDialog('Lỗi', 'Có lỗi xảy ra khi quét mã QR: $e');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _processQRCode(String qrData) async {
    try {
      // Validate QR code format
      if (!QRScannerService.isValidQRCode(qrData)) {
        _showErrorDialog('Mã QR không hợp lệ',
            'Đây không phải là mã QR của hiện vật bảo tàng.\n\nMã QR: $qrData');
        return;
      }

      // Extract artifact ID from QR data
      final String artifactId = QRScannerService.extractArtifactId(qrData);

      // Get artifact details from service
      final artifact = await MuseumService.getArtifactById(artifactId);

      if (artifact != null) {
        // Navigate to artifact detail screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ArtifactDetailScreen(artifact: artifact),
            ),
          );
        }
      } else {
        _showErrorDialog('Không tìm thấy hiện vật',
            'Hiện vật có ID "$artifactId" không tồn tại trong hệ thống.');
      }
    } catch (e) {
      _showErrorDialog('Lỗi', 'Có lỗi xảy ra khi tải thông tin hiện vật: $e');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _scanQRCode(); // Thử quét lại
                },
                child: const Text('Quét lại'),
              ),
            ],
          );
        },
      );
    }
  }
}
