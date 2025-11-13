import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  final _authService = AuthService();
  List<_RatingItem> _ratings = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/interactions?pageIndex=$_currentPage&pageSize=$_pageSize'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> items = data['data']['items'];
          final loadedRatings = items.map((item) => _RatingItem.fromJson(item)).toList();
          setState(() {
            _ratings = loadedRatings;
            _totalPages = data['data']['totalPages'] ?? 1;
            _totalItems = data['data']['totalItems'] ?? 0;
          });
        }
      }
    } catch (e) {
      // Error loading ratings
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;

    setState(() {
      _currentPage = page;
    });

    await _loadRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá của tôi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ratings.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Header with count
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        'Tổng số đánh giá: $_totalItems',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    // List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _ratings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildRatingCard(_ratings[index]);
                        },
                      ),
                    ),

                    // Pagination
                    if (_totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildPaginationControls(),
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
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đánh giá nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tham quan bảo tàng và đánh giá hiện vật',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(_RatingItem rating) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to artifact detail if needed
          // For now, just show the rating details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artifact name
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rating.artifactName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Stars
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Museum name
              Row(
                children: [
                  Icon(
                    Icons.museum_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rating.museumName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),

              // Comment
              if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rating.comment!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(rating.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          onPressed: _currentPage > 1 ? () => _loadPage(_currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage > 1
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            foregroundColor: _currentPage > 1
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),

        const SizedBox(width: 8),

        // Page numbers
        ...List.generate(_totalPages, (index) {
          final pageNum = index + 1;
          if (pageNum == 1 ||
              pageNum == _totalPages ||
              (pageNum >= _currentPage - 1 && pageNum <= _currentPage + 1)) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => _loadPage(pageNum),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: pageNum == _currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: pageNum == _currentPage
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$pageNum',
                      style: TextStyle(
                        color: pageNum == _currentPage ? Colors.white : Colors.grey[700],
                        fontWeight: pageNum == _currentPage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          if (pageNum == _currentPage - 2 || pageNum == _currentPage + 2) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: Colors.grey[600])),
            );
          }
          return const SizedBox.shrink();
        }),

        const SizedBox(width: 8),

        // Next
        IconButton(
          onPressed: _currentPage < _totalPages ? () => _loadPage(_currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage < _totalPages
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            foregroundColor: _currentPage < _totalPages
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _RatingItem {
  final String interactionId;
  final String? comment;
  final int rating;
  final DateTime createdAt;
  final String artifactId;
  final String artifactName;
  final String museumId;
  final String museumName;

  _RatingItem({
    required this.interactionId,
    this.comment,
    required this.rating,
    required this.createdAt,
    required this.artifactId,
    required this.artifactName,
    required this.museumId,
    required this.museumName,
  });

  factory _RatingItem.fromJson(Map<String, dynamic> json) {
    return _RatingItem(
      interactionId: json['interactionId'] as String,
      comment: json['comment'] as String?,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      artifactId: json['artifactId'] as String,
      artifactName: json['artifactName'] as String,
      museumId: json['museumId'] as String,
      museumName: json['museumName'] as String,
    );
  }
}

