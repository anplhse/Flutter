import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import '../models/museum.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final _authService = AuthService();

  // Museum selection
  List<Museum> _museums = [];
  Museum? _selectedMuseum;

  @override
  void initState() {
    super.initState();
    _loadMuseums();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('chat_history');

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        final loadedMessages = historyList
            .map((item) => ChatMessage.fromJson(item))
            .toList();

        setState(() {
          _messages.clear();
          _messages.addAll(loadedMessages);
        });
      }
    } catch (e) {
      // Error loading chat history
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _messages.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString('chat_history', historyJson);
    } catch (e) {
      // Error saving chat history
    }
  }

  Future<void> _clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history');
      setState(() {
        _messages.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa lịch sử chat'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Error clearing chat history
    }
  }

  Future<void> _loadMuseums() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/museums?pageIndex=1&pageSize=100'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data']['items'];
        final loadedMuseums = items.map((item) => Museum.fromJson(item)).toList();
        setState(() {
          _museums = loadedMuseums;
        });
      }
    } catch (e) {
      // Error loading museums
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_isLoading) return; // Tránh spam request

    final userMessage = _messageController.text.trim();

    setState(() {
      _messages.insert(0, ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
        museumId: _selectedMuseum?.id, // attach context
      ));
      _messageController.clear();
      _isLoading = true;
    });

    // Gọi API chat AI
    try {
      final response = await ChatService.sendMessage(
        userMessage,
        museumId: _selectedMuseum?.id,
      );

      if (mounted) {
        setState(() {
          _messages.insert(0, ChatMessage(
            text: response ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này lúc này. Vui lòng thử lại sau.',
            isUser: false,
            timestamp: DateTime.now(),
            museumId: _selectedMuseum?.id, // attach context
          ));
          _isLoading = false;
        });
        // Lưu lịch sử chat
        _saveChatHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.insert(0, ChatMessage(
            text: 'Đã có lỗi xảy ra. Vui lòng thử lại sau.',
            isUser: false,
            timestamp: DateTime.now(),
            museumId: _selectedMuseum?.id, // attach context
          ));
          _isLoading = false;
        });
        // Lưu lịch sử chat
        _saveChatHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat với AI', style: TextStyle(fontSize: 18)),
            if (_selectedMuseum != null)
              Text(
                _selectedMuseum!.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
              );
            },
          ),
          // Clear history button
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Xóa lịch sử chat',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa lịch sử chat'),
                    content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử chat?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearChatHistory();
                        },
                        child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          // Museum selector button
          PopupMenuButton<Museum?>(
            icon: const Icon(Icons.museum),
            tooltip: 'Chọn bảo tàng',
            onSelected: (Museum? museum) {
              setState(() {
                _selectedMuseum = museum;
              });
              if (museum != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chọn: ${museum.name}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<Museum?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.clear, size: 20),
                      SizedBox(width: 8),
                      Text('Tất cả bảo tàng'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ..._museums.map((Museum museum) {
                  return PopupMenuItem<Museum>(
                    value: museum,
                    child: Row(
                      children: [
                        Icon(
                          _selectedMuseum?.id == museum.id
                              ? Icons.check_circle
                              : Icons.museum_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            museum.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Museum selection hint
          if (_selectedMuseum != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đang chat về: ${_selectedMuseum!.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && _isLoading) {
                        return _buildTypingIndicator();
                      }
                      final messageIndex = _isLoading ? index - 1 : index;
                      return _buildMessageBubble(_messages[messageIndex]);
                    },
                  ),
          ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bắt đầu trò chuyện',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hỏi tôi về các bảo tàng và hiện vật',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestChip('Thông tin bảo tàng'),
                _buildSuggestChip('List hiện vật'),
                _buildSuggestChip('Danh sách khu vực'),
                _buildSuggestChip('Tìm hiện vật theo thời kỳ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        setState(() {
          _messageController.text = text;
        });
        // Tự động gửi tin nhắn khi nhấn suggest
        _sendMessage();
      },
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            radius: 16,
            child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(200),
                const SizedBox(width: 4),
                _buildDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value * 2).clamp(0.0, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted) {
              setState(() {});
            }
          });
        }
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: message.isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        em: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                        code: TextStyle(
                          backgroundColor: Colors.grey[300],
                          color: Colors.black87,
                          fontFamily: 'monospace',
                        ),
                        listBullet: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      selectable: true,
                    ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
              child: const Icon(Icons.person, size: 16, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? museumId; // NEW: tie message to a museum context if any

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.museumId,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'museumId': museumId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      museumId: json['museumId'] as String?,
    );
  }
}
