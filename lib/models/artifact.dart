import 'media_item.dart';

class Artifact {
  final String id;
  final String code; // artifactCode
  final String name;
  final String description;
  final String imageUrl;
  final String period; // periodTime
  final String origin;
  final String material;
  final String category;
  final DateTime discoveryDate;
  final String location;
  final List<String> tags;
  final String museumId;
  final String? area; // areaName
  final String? displayPosition; // displayPositionName
  final String? areaDescription; // NEW - areaDescription
  final String? displayPositionDescription; // NEW - displayPositionDescription

  // New fields from API
  final bool isOriginal;
  final double? weight;
  final double? height;
  final double? width;
  final double? length;
  final String status; // OnDisplay, InStorage, etc.
  final String? areaId;
  final String? displayPositionId;
  final DateTime? updatedAt;
  final List<MediaItem> mediaItems; // NEW

  Artifact({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.period,
    required this.origin,
    required this.material,
    required this.category,
    required this.discoveryDate,
    required this.location,
    required this.tags,
    required this.museumId,
    this.area,
    this.displayPosition,
    this.areaDescription,
    this.displayPositionDescription,
    this.isOriginal = true,
    this.weight,
    this.height,
    this.width,
    this.length,
    this.status = 'OnDisplay',
    this.areaId,
    this.displayPositionId,
    this.updatedAt,
    this.mediaItems = const [], // NEW
  });

  factory Artifact.fromJson(Map<String, dynamic> json) {
    // Parse media items
    List<MediaItem> mediaList = [];
    if (json['mediaItems'] != null && json['mediaItems'] is List) {
      mediaList = (json['mediaItems'] as List)
          .map((item) => MediaItem.fromJson(item))
          .toList();
    }

    // Get first image URL from mediaItems or use imageUrl field
    String imageUrl = json['imageUrl'] ?? '';
    if (imageUrl.isEmpty && mediaList.isNotEmpty) {
      final firstImage = mediaList.firstWhere(
        (item) => item.isImage && item.isActive,
        orElse: () => mediaList.first,
      );
      imageUrl = firstImage.filePath;
    }

    return Artifact(
      id: json['id'] ?? '',
      code: json['artifactCode'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? 'Không có mô tả',
      imageUrl: imageUrl,
      period: json['periodTime'] ?? '',
      origin: json['origin'] ?? '',
      material: json['material'] ?? '',
      category: json['category'] ?? '',
      discoveryDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      location: json['location'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      museumId: json['museumId'] ?? '',
      area: json['areaName'],
      displayPosition: json['displayPositionName'],
      areaDescription: json['areaDescription'],
      displayPositionDescription: json['displayPositionDescription'],
      isOriginal: json['isOriginal'] ?? true,
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      width: json['width']?.toDouble(),
      length: json['length']?.toDouble(),
      status: json['status'] ?? 'OnDisplay',
      areaId: json['areaId'],
      displayPositionId: json['displayPositionId'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      mediaItems: mediaList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'period': period,
      'origin': origin,
      'material': material,
      'category': category,
      'discoveryDate': discoveryDate.toIso8601String(),
      'location': location,
      'tags': tags,
      'museumId': museumId,
      'area': area,
      'displayPosition': displayPosition,
    };
  }
}

