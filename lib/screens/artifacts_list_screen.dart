import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArtifactsListScreen extends StatefulWidget {
  final String museumId;
  final String museumName;

  const ArtifactsListScreen({
    super.key,
    required this.museumId,
    required this.museumName,
  });

  @override
  State<ArtifactsListScreen> createState() => _ArtifactsListScreenState();
}

class _ArtifactsListScreenState extends State<ArtifactsListScreen> {
  List<dynamic> artifacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtifacts();
  }

  Future<void> _loadArtifacts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://museum-system-api-160202770359.asia-southeast1.run.app/api/v1/artifacts?museumId=${widget.museumId}&pageIndex=1&pageSize=10&includeDeleted=true'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          artifacts = data['data']['items'];
        });
      } else {
        debugPrint('Failed to load artifacts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading artifacts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hiện vật - ${widget.museumName}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : artifacts.isEmpty
              ? const Center(child: Text('Không có hiện vật nào'))
              : ListView.builder(
                  itemCount: artifacts.length,
                  itemBuilder: (context, index) {
                    final artifact = artifacts[index];
                    return ListTile(
                      title: Text(artifact['name'] ?? 'Không có tên'),
                      subtitle: Text('Thời kỳ: ${artifact['periodTime'] ?? 'Không rõ'}'),
                      trailing: Text(artifact['status'] ?? ''),
                    );
                  },
                ),
    );
  }
}
