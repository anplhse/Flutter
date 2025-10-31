import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/artifact.dart';
import '../models/museum.dart';

class MuseumService {
  // URL base của API (có thể thay đổi theo backend thực tế)
  static const String baseUrl = 'https://api.museum.com';

  // ==================== MUSEUM APIs ====================

  // Lấy danh sách tất cả bảo tàng (cho visitor)
  static Future<List<Museum>> getAllMuseums() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/museums'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Museum.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching museums: $e');
    }
    return [];
  }

  // Lấy thông tin bảo tàng theo ID
  static Future<Museum?> getMuseumById(String museumId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/museums/$museumId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Museum.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint('Error fetching museum: $e');
    }
    return null;
  }

  // ==================== ARTIFACT APIs ====================

  // Lấy thông tin hiện vật từ code (được quét từ QR code)
  static Future<Artifact?> getArtifactByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/artifacts/code/$code'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Artifact.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint('Error fetching artifact by code: $e');
    }
    return null;
  }

  // Lấy thông tin hiện vật từ ID
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

  // Lấy danh sách hiện vật của một bảo tàng
  static Future<List<Artifact>> getArtifactsByMuseumId(String museumId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/museums/$museumId/artifacts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Artifact.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching artifacts by museum: $e');
    }
    return [];
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

  // ==================== MOCK DATA (cho demo) ====================

  // Dữ liệu mẫu bảo tàng
  static Future<List<Museum>> getMockMuseums() async {
    await Future.delayed(const Duration(seconds: 1));

    final mockData = [
      {
        'id': 'MUS001',
        'name': 'Bảo Tàng Lịch Sử Quốc Gia',
        'description': 'Bảo tàng lưu giữ các hiện vật lịch sử quan trọng của Việt Nam từ thời tiền sử đến nay. Với hơn 200,000 hiện vật, đây là nơi lưu giữ di sản văn hóa vô giá của dân tộc.',
        'address': '1 Tràng Tiền, Hoàn Kiếm, Hà Nội',
        'imageUrl': 'https://images.unsplash.com/photo-1566127318020-3de21204d7ea?w=800',
        'phone': '024 3825 2853',
        'email': 'btlsqg@museum.gov.vn',
        'openingHours': 'Thứ 2 - Chủ nhật: 8:00 - 17:00',
        'latitude': 21.0245,
        'longitude': 105.8412,
        'tags': ['lịch sử', 'văn hóa', 'di sản'],
        'createdAt': '2020-01-01T00:00:00.000Z',
      },
      {
        'id': 'MUS002',
        'name': 'Bảo Tàng Mỹ Thuật Việt Nam',
        'description': 'Nơi trưng bày các tác phẩm nghệ thuật tiêu biểu của Việt Nam qua các thời kỳ. Bảo tàng có bộ sưu tập phong phú về hội họa, điêu khắc và nghệ thuật dân gian.',
        'address': '66 Nguyễn Thái Học, Ba Đình, Hà Nội',
        'imageUrl': 'https://images.unsplash.com/photo-1582555172866-f73bb12a2ab3?w=800',
        'phone': '024 3733 2131',
        'email': 'btmt@museum.gov.vn',
        'openingHours': 'Thứ 3 - Chủ nhật: 8:30 - 17:00',
        'latitude': 21.0333,
        'longitude': 105.8356,
        'tags': ['mỹ thuật', 'hội họa', 'điêu khắc'],
        'createdAt': '2020-02-01T00:00:00.000Z',
      },
      {
        'id': 'MUS003',
        'name': 'Bảo Tàng Dân Tộc Học',
        'description': 'Bảo tàng giới thiệu về đời sống văn hóa của 54 dân tộc Việt Nam. Với không gian trưng bày ngoài trời rộng lớn, du khách có thể trải nghiệm kiến trúc truyền thống của các dân tộc.',
        'address': 'Đường Nguyễn Văn Huyên, Cầu Giấy, Hà Nội',
        'imageUrl': 'https://images.unsplash.com/photo-1563784462041-5f97ac9523dd?w=800',
        'phone': '024 3756 2193',
        'email': 'btdth@museum.gov.vn',
        'openingHours': 'Thứ 2 - Chủ nhật: 8:30 - 17:30',
        'latitude': 21.0401,
        'longitude': 105.7938,
        'tags': ['dân tộc', 'văn hóa', 'truyền thống'],
        'createdAt': '2020-03-01T00:00:00.000Z',
      },
    ];

    return mockData.map((json) => Museum.fromJson(json)).toList();
  }

  // Dữ liệu mẫu hiện vật
  static Future<Artifact?> getMockArtifact(String artifactId) async {
    await Future.delayed(const Duration(seconds: 1));

    final mockData = {
      'AR001': {
        'id': 'AR001',
        'code': 'AR001',
        'name': 'Bình gốm Hàn',
        'description': 'Bình gốm cổ từ thời Hàn, được phát hiện tại di chỉ khảo cổ Cổ Loa. Bình có hình dáng đặc trưng với thân tròn, cổ cao và được trang trí bằng các họa tiết hình học tinh xảo.',
        'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'period': 'Thời Hàn (207 TCN - 938 SCN)',
        'origin': 'Cổ Loa, Hà Nội',
        'material': 'Gốm nung',
        'category': 'Đồ gốm',
        'discoveryDate': '1995-03-15T00:00:00.000Z',
        'location': 'Phòng trưng bày A1',
        'tags': ['gốm cổ', 'thời Hàn', 'Cổ Loa'],
        'museumId': 'MUS001',
        'area': 'Khu A - Tầng 1',
        'displayPosition': 'Tủ kính số 3',
      },
      'AR002': {
        'id': 'AR002',
        'code': 'AR002',
        'name': 'Kiếm đồng cổ',
        'description': 'Thanh kiếm bằng đồng có niên đại khoảng 3000 năm. Kiếm được chế tác tinh xảo với lưỡi sắc bén và cán được khắc nhiều hoa văn trang trí.',
        'imageUrl': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'period': 'Thời đại đồ đồng',
        'origin': 'Đông Sơn, Thanh Hóa',
        'material': 'Đồng',
        'category': 'Vũ khí',
        'discoveryDate': '1988-07-22T00:00:00.000Z',
        'location': 'Phòng trưng bày B2',
        'tags': ['đồng cổ', 'vũ khí', 'Đông Sơn'],
        'museumId': 'MUS001',
        'area': 'Khu B - Tầng 2',
        'displayPosition': 'Bàn trưng bày số 5',
      },
      'AR003': {
        'id': 'AR003',
        'code': 'AR003',
        'name': 'Tượng Phật gỗ',
        'description': 'Tượng Phật bằng gỗ quý được chế tác vào thế kỷ 15. Tượng thể hiện nghệ thuật điêu khắc tinh xảo của nghệ nhân Việt Nam thời Lê sơ.',
        'imageUrl': 'https://images.unsplash.com/photo-1588611355744-28d6e914a8ac?w=800',
        'period': 'Thời Lê sơ (1428-1527)',
        'origin': 'Chùa Trấn Quốc, Hà Nội',
        'material': 'Gỗ lim',
        'category': 'Tôn giáo',
        'discoveryDate': '1960-12-08T00:00:00.000Z',
        'location': 'Phòng trưng bày C1',
        'tags': ['tượng Phật', 'gỗ lim', 'Lê sơ'],
        'museumId': 'MUS002',
        'area': 'Khu C - Tầng 1',
        'displayPosition': 'Bệ đá số 2',
      }
    };

    if (mockData.containsKey(artifactId)) {
      return Artifact.fromJson(mockData[artifactId]!);
    }
    return null;
  }

  // Lấy hiện vật theo code (cho QR scanner)
  static Future<Artifact?> getMockArtifactByCode(String code) async {
    return await getMockArtifact(code);
  }

  // Lấy hiện vật theo museum ID
  static Future<List<Artifact>> getMockArtifactsByMuseumId(String museumId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final allArtifacts = [
      await getMockArtifact('AR001'),
      await getMockArtifact('AR002'),
      await getMockArtifact('AR003'),
    ];

    return allArtifacts
        .where((artifact) => artifact != null && artifact.museumId == museumId)
        .cast<Artifact>()
        .toList();
  }
}
