import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    detailedArtifact = widget.artifact;
    _loadArtifactDetail();
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
      } else {
        debugPrint('Failed to load artifact detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading artifact detail: $e');
    } finally {
      setState(() {
        isLoading = false;
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
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and badges
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

                            const SizedBox(height: 16),

                            // Code
                            Row(

                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // QR Code Section
                      _buildSection(
                        'Mã QR Code',
                        Icons.qr_code_2,
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: QrImageView(
                                data: 'ARTIFACT:${artifact.code}',
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                                errorStateBuilder: (ctx, err) {
                                  return const Center(
                                    child: Text(
                                      'Lỗi tạo QR code',
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      _buildSection(
                        'Mô tả',
                        Icons.description,
                        Text(
                          artifact.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),

                      // Display information
                      if (artifact.area != null || artifact.displayPosition != null)
                        _buildSection(
                          'Vị trí trưng bày',
                          Icons.place,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (artifact.area != null)
                                _buildInfoRow('Khu vực', artifact.area!),
                              if (artifact.displayPosition != null)
                                _buildInfoRow('Vị trí', artifact.displayPosition!),
                            ],
                          ),
                        ),

                      // Specifications
                      if (artifact.weight != null ||
                          artifact.height != null ||
                          artifact.width != null ||
                          artifact.length != null)
                        _buildSection(
                          'Thông số kỹ thuật',
                          Icons.straighten,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (artifact.weight != null)
                                _buildInfoRow('Trọng lượng', '${artifact.weight} kg'),
                              if (artifact.height != null)
                                _buildInfoRow('Chiều cao', '${artifact.height} cm'),
                              if (artifact.width != null)
                                _buildInfoRow('Chiều rộng', '${artifact.width} cm'),
                              if (artifact.length != null)
                                _buildInfoRow('Chiều dài', '${artifact.length} cm'),
                            ],
                          ),
                        ),

                      // Image count
                      if (hasImages && images.length > 1)
                        _buildSection(
                          'Hình ảnh',
                          Icons.photo_library,
                          Text(
                            '${images.length} ảnh',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
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
            return CachedNetworkImage(
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
            );
          },
        ),
        // Gradient overlay
        Container(
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

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          const SizedBox(height: 12),
          content,
        ],
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
}

