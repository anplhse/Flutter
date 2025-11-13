import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'auth_service.dart';

class ChatService {
  static final _authService = AuthService();

  // Gửi tin nhắn đến AI chat bot
  static Future<String?> sendMessage(String prompt, {String? museumId}) async {
    try {
      final body = <String, dynamic>{
        'prompt': prompt,
      };

      // Thêm museumId nếu có
      if (museumId != null && museumId.isNotEmpty) {
        body['museumId'] = museumId;
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/chat/generate'),
        headers: {
          ..._authService.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // API trả về plain text response
        final responseText = response.body;
        return responseText;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

