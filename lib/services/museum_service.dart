import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/artifact.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class MuseumService {
  static final _authService = AuthService();

  // ==================== ARTIFACT APIs ====================

  // Lấy thông tin hiện vật từ code (được quét từ QR code)
  static Future<Artifact?> getArtifactByCode(String artifactCode) async {
    try {
      // Tìm kiếm hiện vật theo artifactCode
      // Backend cần có API search artifacts với filter theo artifactCode
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/artifacts?artifactCode=$artifactCode&pageSize=1'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200 && jsonData['data']['items'] != null) {
          final items = jsonData['data']['items'] as List;
          if (items.isNotEmpty) {
            // Lấy chi tiết artifact đầu tiên tìm được
            final artifactId = items[0]['id'];
            return await getArtifactById(artifactId);
          }
        }
      }
      debugPrint('Artifact not found with code: $artifactCode');
    } catch (e) {
      debugPrint('Error fetching artifact by code: $e');
    }
    return null;
  }

  // Lấy thông tin hiện vật từ ID
  static Future<Artifact?> getArtifactById(String artifactId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/artifacts/$artifactId'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200) {
          return Artifact.fromJson(jsonData['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching artifact: $e');
    }
    return null;
  }

  // Lấy danh sách hiện vật của một bảo tàng
  static Future<List<Artifact>> getArtifactsByMuseumId(String museumId, {int pageIndex = 1, int pageSize = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/museums/$museumId/artifacts?pageIndex=$pageIndex&pageSize=$pageSize'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200) {
          final items = jsonData['data']['items'] as List;
          return items.map((json) => Artifact.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching artifacts by museum: $e');
    }
    return [];
  }


}
