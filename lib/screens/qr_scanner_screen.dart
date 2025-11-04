import 'package:flutter/material.dart';
import '../services/qr_scanner_service.dart';
import '../services/museum_service.dart';
import 'artifact_detail_screen.dart';
import '../utils/app_utils.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;

  Future<void> _scanQRCode() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final result = await QRScannerService.scanQRCode(context);

      if (result != null && mounted) {
        if (QRScannerService.isValidQRCode(result)) {
          final artifactCode = QRScannerService.extractArtifactId(result);

          // Hiển thị loading
          if (mounted) {
            AppUtils.showSnackBar(
              context,
              'Đang tìm kiếm hiện vật...',
            );
          }

          // Lấy thông tin hiện vật từ API thật
          final artifact = await MuseumService.getArtifactByCode(artifactCode);

          if (artifact != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtifactDetailScreen(artifact: artifact),
              ),
            );
          } else {
            if (mounted) {
              AppUtils.showSnackBar(
                context,
                'Không tìm thấy thông tin hiện vật với mã: $artifactCode',
                isError: true,
              );
            }
          }
        } else {
          if (mounted) {
            AppUtils.showSnackBar(
              context,
              'Mã QR không hợp lệ. Vui lòng quét mã QR của hiện vật trong bảo tàng.',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Lỗi khi quét mã QR: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon QR code lớn
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Tiêu đề
              const Text(
                'Quét mã QR hiện vật',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Mô tả
              Text(
                'Nhấn nút bên dưới để mở camera và quét mã QR trên hiện vật để xem thông tin chi tiết',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Nút quét QR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : _scanQRCode,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner),
                  label: Text(
                    isProcessing ? 'Đang xử lý...' : 'Bắt đầu quét QR',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hướng dẫn
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mã QR có thể được tìm thấy trên biển hiệu bên cạnh mỗi hiện vật trong bảo tàng',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
