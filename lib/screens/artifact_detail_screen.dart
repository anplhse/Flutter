import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/artifact.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';

class ArtifactDetailScreen extends StatefulWidget {
  final Artifact artifact;

  const ArtifactDetailScreen({super.key, required this.artifact});

  @override
  State<ArtifactDetailScreen> createState() => _ArtifactDetailScreenState();
}

class _ArtifactDetailScreenState extends State<ArtifactDetailScreen> {
  Artifact? detailedArtifact;
  bool isLoading = true;
  final _authService = AuthService();
  int _currentImageIndex = 0;

  // Rating & Comment
  int _userRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmittingRating = false;

  // Other visitors' ratings
  List<_OtherRating> _otherRatings = [];
  bool _isLoadingOtherRatings = true;
  int _ratingsPage = 1;
  int _ratingsTotalPages = 1;
  double _averageRating = 0.0;
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    detailedArtifact = widget.artifact;
    _loadArtifactDetail();
    _loadOtherRatings();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadArtifactDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/artifacts/${widget.artifact.id}'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final artifactData = data['data'];
          setState(() {
            detailedArtifact = Artifact.fromJson(artifactData);
          });
        }
      }
    } catch (e) {
      // Error loading artifact detail
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadOtherRatings() async {
    setState(() {
      _isLoadingOtherRatings = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/artifacts/${widget.artifact.id}/interactions?pageIndex=$_ratingsPage&pageSize=10'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final ratingsData = data['data'];
          final List<dynamic> items = ratingsData['items'];
          final List<_OtherRating> loadedRatings = items.map((item) => _OtherRating.fromJson(item)).toList();

          setState(() {
            _otherRatings = loadedRatings;
            _ratingsTotalPages = ratingsData['totalPages'] ?? 1;
            _totalRatings = ratingsData['totalItems'] ?? 0;

            // Calculate average rating
            if (loadedRatings.isNotEmpty) {
              final sum = loadedRatings.fold<int>(0, (prev, rating) => prev + rating.rating);
              _averageRating = sum / loadedRatings.length;
            }
          });
        }
      }
    } catch (e) {
      // Error loading other ratings
    } finally {
      setState(() {
        _isLoadingOtherRatings = false;
      });
    }
  }

  Future<void> _submitRating() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
      );
      return;
    }

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/visitors/interactions'),
        headers: {
          ..._authService.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'artifactId': widget.artifact.id,
          'rating': _userRating,
          'comment': _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đánh giá của bạn đã được gửi thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          // Reset form
          setState(() {
            _userRating = 0;
            _commentController.clear();
          });
          // Reload other ratings
          _loadOtherRatings();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể gửi đánh giá. Vui lòng thử lại.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã có lỗi xảy ra. Vui lòng thử lại.')),
        );
      }
    } finally {
      setState(() {
        _isSubmittingRating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final artifact = detailedArtifact ?? widget.artifact;
    final images = artifact.mediaItems.where((m) => m.isImage && m.isActive).toList();
    final hasImages = images.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image gallery app bar
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: hasImages
                  ? _buildImageGallery(images)
                  : _buildPlaceholderImage(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: isLoading
                ? Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          artifact.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Badges row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildBadge(
                              artifact.status == 'OnDisplay' ? 'Đang trưng bày' : 'Trong kho',
                              artifact.status == 'OnDisplay' ? Colors.green : Colors.orange,
                              artifact.status == 'OnDisplay' ? Icons.visibility : Icons.inventory_2,
                            ),
                            if (artifact.isOriginal)
                              _buildBadge('Hiện vật gốc', Colors.amber, Icons.verified),
                            _buildBadge(artifact.period, Colors.blue, Icons.calendar_today),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Description
                        _buildSectionTitle('Mô tả', Icons.description),
                        const SizedBox(height: 12),
                        Text(
                          artifact.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),

                        // Display information
                        if (artifact.area != null || artifact.displayPosition != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionTitle('Vị trí trưng bày', Icons.place),
                          const SizedBox(height: 16),
                          // Area section
                          if (artifact.area != null && artifact.area!.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Khu vực',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    artifact.area!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (artifact.areaDescription != null && artifact.areaDescription!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  artifact.areaDescription!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                            if (artifact.displayPosition != null && artifact.displayPosition!.isNotEmpty)
                              const SizedBox(height: 20),
                          ],

                          // Display position section
                          if (artifact.displayPosition != null && artifact.displayPosition!.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vị trí',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    artifact.displayPosition!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (artifact.displayPositionDescription != null && artifact.displayPositionDescription!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  artifact.displayPositionDescription!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],

                        // Specifications
                        if (artifact.weight != null ||
                            artifact.height != null ||
                            artifact.width != null ||
                            artifact.length != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionTitle('Thông số kỹ thuật', Icons.straighten),
                          const SizedBox(height: 16),
                          if (artifact.weight != null)
                            _buildInfoRow('Trọng lượng', '${artifact.weight} kg'),
                          if (artifact.height != null)
                            _buildInfoRow('Chiều cao', '${artifact.height} cm'),
                          if (artifact.width != null)
                            _buildInfoRow('Chiều rộng', '${artifact.width} cm'),
                          if (artifact.length != null)
                            _buildInfoRow('Chiều dài', '${artifact.length} cm'),
                        ],

                        // Rating section
                        const SizedBox(height: 40),
                        _buildSectionTitle('Đánh giá hiện vật', Icons.star),
                        const SizedBox(height: 20),

                        // Star rating
                        Row(
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < _userRating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 36,
                              ),
                              onPressed: () {
                                setState(() {
                                  _userRating = index + 1;
                                });
                              },
                            );
                          }),
                        ),

                        if (_userRating > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            _getRatingText(_userRating),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Comment field
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Chia sẻ cảm nhận của bạn về hiện vật này...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmittingRating ? null : _submitRating,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmittingRating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Gửi đánh giá',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Other visitors' ratings
                        _buildSectionTitle('Đánh giá của khách tham quan', Icons.people),
                        const SizedBox(height: 16),
                        if (_isLoadingOtherRatings)
                          const Center(child: CircularProgressIndicator())
                        else if (_otherRatings.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'Chưa có đánh giá nào từ khách tham quan.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else ...[
                          // Average rating
                          _buildAverageRating(),

                          // Ratings list
                          ListView.builder(
                            itemCount: _otherRatings.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final rating = _otherRatings[index];
                              return _buildRatingItem(rating);
                            },
                          ),

                          // Load more button
                          if (_ratingsPage < _ratingsTotalPages)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: _loadMoreRatings,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Xem thêm đánh giá',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List images) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Mở full screen image viewer
                _openImageViewer(images, index);
              },
              child: CachedNetworkImage(
                imageUrl: images[index].filePath,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            );
          },
        ),
        // Gradient overlay (ignore pointer để không chặn swipe)
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        // Image counter
        if (images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.museum,
        size: 120,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _openImageViewer(List images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }


  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Không hài lòng';
      case 2:
        return 'Tạm được';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Xuất sắc';
      default:
        return '';
    }
  }

  Widget _buildAverageRating() {
    final fullStars = _averageRating.floor();
    final halfStar = _averageRating - fullStars >= 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá trung bình: ${_averageRating.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(fullStars, (index) {
              return const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              );
            }),
            if (halfStar)
              const Icon(
                Icons.star_half,
                color: Colors.amber,
                size: 20,
              ),
            ...List.generate(5 - fullStars - (halfStar ? 1 : 0), (index) {
              return const Icon(
                Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRatingItem(_OtherRating rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.visitorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(rating.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),

          // Comment
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
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
        ],
      ),
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

  void _loadMoreRatings() {
    if (_isLoadingOtherRatings || _ratingsPage >= _ratingsTotalPages) return;

    setState(() {
      _isLoadingOtherRatings = true;
    });

    http.get(
      Uri.parse('${AppConstants.baseUrl}/visitors/artifacts/${widget.artifact.id}/interactions?pageIndex=${_ratingsPage + 1}&pageSize=10'),
      headers: _authService.getAuthHeaders(),
    ).then((response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final ratingsData = data['data'];
          final List<dynamic> items = ratingsData['items'];
          final List<_OtherRating> loadedRatings = items.map((item) => _OtherRating.fromJson(item)).toList();

          setState(() {
            _otherRatings.addAll(loadedRatings);
            _ratingsPage++;
            _ratingsTotalPages = ratingsData['totalPages'] ?? 1;
            _totalRatings = ratingsData['totalItems'] ?? 0;
          });
        }
      }
    }).catchError((e) {
      // Handle error
    }).whenComplete(() {
      setState(() {
        _isLoadingOtherRatings = false;
      });
    });
  }
}

// Full Screen Image Viewer with Zoom
class _FullScreenImageViewer extends StatefulWidget {
  final List images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image viewer with zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index].filePath,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top bar with close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 8,
                right: 8,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction (only show if multiple images)
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swipe, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Vuốt để xem ảnh khác • Pinch để zoom',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OtherRating {
  final String visitorId;
  final String visitorName;
  final String interactionId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  _OtherRating({
    required this.visitorId,
    required this.visitorName,
    required this.interactionId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory _OtherRating.fromJson(Map<String, dynamic> json) {
    return _OtherRating(
      visitorId: json['visitorId'] as String,
      visitorName: json['visitorName'] as String,
      interactionId: json['interactionId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
