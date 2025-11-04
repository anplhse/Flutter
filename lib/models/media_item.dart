class MediaItem {
  final String id;
  final String mediaType; // Image, Video, Audio
  final String filePath; // URL
  final String? fileName;
  final String? mimeType;
  final String? fileFormat; // jpeg, png, mp4, etc.
  final String? caption;
  final String status; // Active, Inactive
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MediaItem({
    required this.id,
    required this.mediaType,
    required this.filePath,
    this.fileName,
    this.mimeType,
    this.fileFormat,
    this.caption,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      mediaType: json['mediaType'] ?? 'Image',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'],
      mimeType: json['mimeType'],
      fileFormat: json['fileFormat'],
      caption: json['caption'],
      status: json['status'] ?? 'Active',
      createdAt: json['createdAt'] != null && json['createdAt'] != '0001-01-01T00:00:00'
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaType': mediaType,
      'filePath': filePath,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileFormat': fileFormat,
      'caption': caption,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isImage => mediaType.toLowerCase() == 'image';
  bool get isVideo => mediaType.toLowerCase() == 'video';
  bool get isAudio => mediaType.toLowerCase() == 'audio';
  bool get isActive => status == 'Active';
}

