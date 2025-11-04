import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'auth_service.dart';

class ChatService {
  static final _authService = AuthService();

  // Gửi tin nhắn đến AI chat bot
  static Future<String?> sendMessage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/chat/generate'),
        headers: {
          ..._authService.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'prompt': prompt,
        }),
      );

      if (response.statusCode == 200) {
        // API trả về plain text response
        final responseText = response.body;
        debugPrint('Chat response: $responseText');
        return responseText;
      } else {
        debugPrint('Failed to send message: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }
}

