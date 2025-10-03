import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerService {
  static bool isScanning = false;

  // Kiểm tra và yêu cầu quyền camera
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) {
      return true; // Web tự động xử lý permission
    }

    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // Mở QR scanner và trả về kết quả
  static Future<String?> scanQRCode(BuildContext context) async {
    try {
      isScanning = true;

      // Kiểm tra quyền camera trước
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      // Sử dụng Navigator để mở màn hình AiBarcodeScanner
      final String? result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AiBarcodeScanner(
            onDetect: (BarcodeCapture capture) {
              final String? scannedValue = capture.barcodes.firstOrNull?.rawValue;
              if (scannedValue != null) {
                Navigator.of(context).pop(scannedValue);
              }
            },
            onDispose: () {
              debugPrint('Scanner disposed');
            },
          ),
        ),
      );

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi scan QR code: $e');
      }
      return null;
    } finally {
      isScanning = false;
    }
  }

  // Kiểm tra xem có đang scan không
  static bool get isCameraActive => isScanning;

  // Validate QR code format
  static bool isValidQRCode(String qrData) {
    if (qrData.isEmpty) return false;

    // Check various QR formats
    return qrData.startsWith('MUSEUM:') ||
        qrData.contains('/artifact/') ||
        RegExp(r'^AR\d{3}$').hasMatch(qrData);
  }

  // Extract artifact ID from QR data
  static String extractArtifactId(String qrData) {
    if (qrData.startsWith('MUSEUM:')) {
      return qrData.substring(7); // Remove "MUSEUM:" prefix
    } else if (qrData.contains('/artifact/')) {
      final parts = qrData.split('/artifact/');
      return parts.length > 1 ? parts[1] : qrData;
    } else if (RegExp(r'^AR\d{3}$').hasMatch(qrData)) {
      return qrData;
    }
    return qrData;
  }
}
