import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final _authService = AuthService();
  List<_HistoryItem> _items = [];
  List<_HistoryItem> _filtered = [];
  String _keyword = '';

  // Museum filter state
  List<_MuseumOption> _museums = [];
  String? _selectedMuseumId;
  final Map<String, String> _museumNameById = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadMuseums();
  }

  Future<void> _loadMuseums() async {
    try {
      final resp = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/museums?pageIndex=1&pageSize=100'),
        headers: _authService.getAuthHeaders(),
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final List<dynamic> items = data['data']['items'];
        final list = items.map((e) => _MuseumOption(id: e['id'] as String, name: e['name'] as String)).toList();
        setState(() {
          _museums = list;
          for (final m in list) { _museumNameById[m.id] = m.name; }
          _filtered = _applyFilter(_items); // re-apply to attach names
        });
      }
    } catch (_) {
      // ignore network errors for history screen
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history');
    if (historyJson == null) return;

    final List<dynamic> raw = json.decode(historyJson);
    final parsed = raw.map((e) => _HistoryItem.fromJson(e)).toList();
    setState(() {
      _items = parsed..sort((a,b) => b.timestamp.compareTo(a.timestamp));
      _filtered = _applyFilter(parsed);
    });
  }

  List<_HistoryItem> _applyFilter(List<_HistoryItem> data) {
    final kw = _keyword.trim().toLowerCase();
    return data.where((e) {
      final matchKw = kw.isEmpty || e.text.toLowerCase().contains(kw);
      final matchMuseum = _selectedMuseumId == null || (_selectedMuseumId!.isEmpty && e.museumId == null) || e.museumId == _selectedMuseumId;
      return matchKw && matchMuseum;
    }).toList();
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      _items.clear();
      _filtered.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa toàn bộ lịch sử')),
      );
    }
  }

  Future<void> _removeAt(int indexInFiltered) async {
    // Map index in filtered to index in items by identity
    final item = _filtered[indexInFiltered];
    _items.remove(item);
    setState(() {
      _filtered.removeAt(indexInFiltered);
    });
    // Persist
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_items.map((e) => e.toPersistMap()).toList());
    await prefs.setString('chat_history', encoded);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa 1 mục')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chat'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Xóa toàn bộ',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xóa toàn bộ lịch sử?'),
                    content: const Text('Bạn không thể hoàn tác thao tác này.'),
                    actions: [
                      TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Hủy')),
                      TextButton(onPressed: (){ Navigator.pop(ctx); _clearAll(); }, child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(12,12,12,4),
            child: DropdownButtonFormField<String?> (
              value: _selectedMuseumId,
              items: [
                const DropdownMenuItem<String?> (
                  value: null,
                  child: Text('Tất cả bảo tàng'),
                ),
                ..._museums.map((m) => DropdownMenuItem<String?> (
                  value: m.id,
                  child: Text(m.name, overflow: TextOverflow.ellipsis),
                )),
              ],
              onChanged: (val) => setState(() { _selectedMuseumId = val; _filtered = _applyFilter(_items); }),
              decoration: InputDecoration(
                labelText: 'Lọc theo bảo tàng',
                prefixIcon: const Icon(Icons.museum_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12,4,12,8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo nội dung...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v){
                setState(() {
                  _keyword = v;
                  _filtered = _applyFilter(_items);
                });
              },
            ),
          ),
          // List
          Expanded(
            child: _filtered.isEmpty
              ? const Center(child: Text('Chưa có lịch sử'))
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (ctx, i){
                    final it = _filtered[i];
                    final museName = it.museumId != null ? (_museumNameById[it.museumId!] ?? 'Bảo tàng') : null;
                    return Dismissible(
                      key: ValueKey('${it.timestamp.toIso8601String()}-${it.isUser}-$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeAt(i),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(it.isUser ? Icons.person : Icons.smart_toy),
                        ),
                        title: Text(it.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text([
                          it.isUser ? 'Bạn' : 'AI',
                          it.timestamp.toLocal().toString(),
                          if (museName != null) 'Bảo tàng: $museName',
                        ].join(' · ')),
                        trailing: it.museumId != null ? const Icon(Icons.museum_outlined) : null,
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? museumId;

  _HistoryItem({required this.text, required this.isUser, required this.timestamp, this.museumId});

  factory _HistoryItem.fromJson(Map<String, dynamic> json){
    return _HistoryItem(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      museumId: json['museumId'] as String?,
    );
  }

  Map<String, dynamic> toPersistMap() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'museumId': museumId,
  };
}

class _MuseumOption {
  final String id;
  final String name;
  _MuseumOption({required this.id, required this.name});
}
