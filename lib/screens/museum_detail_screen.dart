import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/museum.dart';
import '../models/artifact.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import 'artifact_detail_screen.dart';

class MuseumDetailScreen extends StatefulWidget {
  final Museum museum;

  const MuseumDetailScreen({super.key, required this.museum});

  @override
  State<MuseumDetailScreen> createState() => _MuseumDetailScreenState();
}

class _MuseumDetailScreenState extends State<MuseumDetailScreen> {
  List<Artifact> artifacts = [];
  bool isLoading = true;
  bool isLoadingMuseum = false;
  bool isLoadingMore = false;
  final _authService = AuthService();
  Museum? detailedMuseum;

  // Pagination variables
  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;
  final int pageSize = 10;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    detailedMuseum = widget.museum;
    _loadMuseumDetail();
    _loadArtifacts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMuseumDetail() async {
    setState(() {
      isLoadingMuseum = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/museums/${widget.museum.id}'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final museumData = data['data'];
          setState(() {
            detailedMuseum = Museum.fromJson(museumData);
          });
        }
      }
    } catch (e) {
      // Error loading museum detail
    } finally {
      setState(() {
        isLoadingMuseum = false;
      });
    }
  }

  Future<void> _loadArtifacts() async {
    setState(() {
      isLoading = true;
      currentPage = 1;
      artifacts.clear();
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/museums/${widget.museum.id}/artifacts?pageIndex=$currentPage&pageSize=$pageSize'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> items = data['data']['items'];
          final loadedArtifacts = items.map((item) => Artifact.fromJson(item)).toList();
          setState(() {
            artifacts = loadedArtifacts;
            totalPages = data['data']['totalPages'] ?? 1;
            totalItems = data['data']['totalItems'] ?? 0;
          });
        }
      }
    } catch (e) {
      // Error loading artifacts
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPage(int page) async {
    if (isLoadingMore || page < 1 || page > totalPages || page == currentPage) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/museums/${widget.museum.id}/artifacts?pageIndex=$page&pageSize=$pageSize'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> items = data['data']['items'];
          final loadedArtifacts = items.map((item) => Artifact.fromJson(item)).toList();
          setState(() {
            artifacts = loadedArtifacts; // Replace instead of append
            currentPage = page;
          });
          // Scroll to top of artifact list
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              400, // Scroll to artifacts section
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    } catch (e) {
      // Error loading page
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final museum = detailedMuseum ?? widget.museum;

    return Scaffold(
      appBar: AppBar(
        title: Text(museum.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoadingMuseum
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon và status
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.museum,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: museum.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: museum.isActive
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: museum.isActive ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              museum.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: museum.isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Museum name
                  Text(
                    museum.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          museum.location,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    museum.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),


            // Artifacts section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.collections, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Hiện vật',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (!isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalItems',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Artifacts list or loading
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (artifacts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.collections_bookmark_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có hiện vật nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: artifacts.length,
                          itemBuilder: (context, index) {
                            final artifact = artifacts[index];
                            return _buildArtifactCard(artifact);
                          },
                        ),
                        // Pagination controls
                        if (totalPages > 1 && !isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: _buildPaginationControls(),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Column(
      children: [
        // Loading indicator
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: CircularProgressIndicator(),
          ),

        // Pagination buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            IconButton(
              onPressed: currentPage > 1 && !isLoadingMore ? () => _loadPage(currentPage - 1) : null,
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: currentPage > 1 && !isLoadingMore
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                foregroundColor: currentPage > 1 && !isLoadingMore
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),

            const SizedBox(width: 8),

            // Page numbers
            ...List.generate(totalPages, (index) {
              final pageNum = index + 1;

              // Show first page, last page, current page and adjacent pages
              if (pageNum == 1 ||
                  pageNum == totalPages ||
                  (pageNum >= currentPage - 1 && pageNum <= currentPage + 1)) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: !isLoadingMore ? () => _loadPage(pageNum) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: pageNum == currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: pageNum == currentPage
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$pageNum',
                          style: TextStyle(
                            color: pageNum == currentPage
                                ? Colors.white
                                : Colors.grey[700],
                            fontWeight: pageNum == currentPage
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Show ellipsis
              if (pageNum == currentPage - 2 || pageNum == currentPage + 2) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: Colors.grey[600])),
                );
              }

              return const SizedBox.shrink();
            }),

            const SizedBox(width: 8),

            // Next button
            IconButton(
              onPressed: currentPage < totalPages && !isLoadingMore ? () => _loadPage(currentPage + 1) : null,
              icon: const Icon(Icons.chevron_right),
              style: IconButton.styleFrom(
                backgroundColor: currentPage < totalPages && !isLoadingMore
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                foregroundColor: currentPage < totalPages && !isLoadingMore
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Page info text
        Text(
          'Trang $currentPage / $totalPages',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildArtifactCard(Artifact artifact) {
    // Status color
    Color statusColor;
    IconData statusIcon;
    String statusText;
    switch (artifact.status) {
      case 'OnDisplay':
        statusColor = Colors.green;
        statusIcon = Icons.visibility;
        statusText = 'Trưng bày';
        break;
      case 'InStorage':
        statusColor = Colors.orange;
        statusIcon = Icons.inventory_2;
        statusText = 'Trong kho';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Khác';
    }

    // Get first image if available
    final hasImage = artifact.mediaItems.isNotEmpty;
    final imageUrl = hasImage ? artifact.mediaItems.first.filePath : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtifactDetailScreen(artifact: artifact),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image or Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: hasImage && imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.museum,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            );
                          },
                        )
                      : Icon(
                          Icons.museum,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      artifact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Period and Status in one row
                    Row(
                      children: [
                        // Period
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 11, color: Colors.blue[700]),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    artifact.period,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 11, color: statusColor),
                              const SizedBox(width: 3),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Area or Original badge
                    Row(
                      children: [
                        if (artifact.area != null)
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.place, size: 11, color: Colors.grey[600]),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    artifact.area!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (artifact.area != null && artifact.isOriginal)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('•', style: TextStyle(color: Colors.grey[400])),
                          ),

                        if (artifact.isOriginal)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 11, color: Colors.amber[700]),
                              const SizedBox(width: 3),
                              Text(
                                'Hiện vật gốc',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

