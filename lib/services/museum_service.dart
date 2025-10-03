import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/artifact.dart';

class MuseumService {
  // URL base của API (có thể thay đổi theo backend thực tế)
  static const String baseUrl = 'https://api.museum.com';

  // Lấy thông tin hiện vật từ ID (được quét từ QR code)
  static Future<Artifact?> getArtifactById(String artifactId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/artifacts/$artifactId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Artifact.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint('Error fetching artifact: $e');
    }
    return null;
  }

  // Lấy danh sách tất cả hiện vật
  static Future<List<Artifact>> getAllArtifacts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/artifacts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Artifact.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching artifacts: $e');
    }
    return [];
  }

  // Tìm kiếm hiện vật theo từ khóa
  static Future<List<Artifact>> searchArtifacts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/artifacts/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Artifact.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error searching artifacts: $e');
    }
    return [];
  }

  // Dữ liệu mẫu cho demo (khi không có backend)
  static Future<Artifact?> getMockArtifact(String artifactId) async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập độ trễ API

    final mockData = {
      'AR001': {
        'id': 'AR001',
        'name': 'Bình gốm Hàn',
        'description': 'Bình gốm cổ từ thời Hàn, được phát hiện tại di chỉ khảo cổ Cổ Loa. Bình có hình dáng đặc trưng với thân tròn, cổ cao và được trang trí bằng các họa tiết hình học tinh xảo.',
        'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'period': 'Thời Hàn (207 TCN - 938 SCN)',
        'origin': 'Cổ Loa, Hà Nội',
        'material': 'Gốm nung',
        'category': 'Đồ gốm',
        'discoveryDate': '1995-03-15T00:00:00.000Z',
        'location': 'Phòng trưng bày A1',
        'tags': ['gốm cổ', 'thời Hàn', 'Cổ Loa']
      },
      'AR002': {
        'id': 'AR002',
        'name': 'Kiếm đồng cổ',
        'description': 'Thanh kiếm bằng đồng có niên đại khoảng 3000 năm. Kiếm được chế tác tinh xảo với lưỡi sắc bén và cán được khắc nhiều hoa văn trang trí.',
        'imageUrl': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'period': 'Thời đại đồ đồng',
        'origin': 'Đông Sơn, Thanh Hóa',
        'material': 'Đồng',
        'category': 'Vũ khí',
        'discoveryDate': '1988-07-22T00:00:00.000Z',
        'location': 'Phòng trưng bày B2',
        'tags': ['đồng cổ', 'vũ khí', 'Đông Sơn']
      },
      'AR003': {
        'id': 'AR003',
        'name': 'Tượng Phật gỗ',
        'description': 'Tượng Phật bằng gỗ quý được chế tác vào thế kỷ 15. Tượng thể hiện nghệ thuật điêu khắc tinh xảo của nghệ nhân Việt Nam thời Lê sơ.',
        'imageUrl': 'https://images.unsplash.com/photo-1588611355744-28d6e914a8ac?w=800',
        'period': 'Thời Lê sơ (1428-1527)',
        'origin': 'Chùa Trấn Quốc, Hà Nội',
        'material': 'Gỗ lim',
        'category': 'Tôn giáo',
        'discoveryDate': '1960-12-08T00:00:00.000Z',
        'location': 'Phòng trưng bày C1',
        'tags': ['tượng Phật', 'gỗ lim', 'Lê sơ']
      }
    };

    if (mockData.containsKey(artifactId)) {
      return Artifact.fromJson(mockData[artifactId]!);
    }
    return null;
  }
}
