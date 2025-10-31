class Artifact {
  final String id;
  final String code; // Mã hiện vật dùng cho QR code
  final String name;
  final String description;
  final String imageUrl;
  final String period;
  final String origin;
  final String material;
  final String category;
  final DateTime discoveryDate;
  final String location;
  final List<String> tags;
  final String museumId; // ID của bảo tàng
  final String? area; // Khu vực trưng bày (vd: "Khu A", "Tầng 2")
  final String? displayPosition; // Vị trí trưng bày cụ thể (vd: "Tủ 1", "Bàn 3")

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
  });

  factory Artifact.fromJson(Map<String, dynamic> json) {
    return Artifact(
      id: json['id'] ?? '',
      code: json['code'] ?? json['id'] ?? '', // Fallback to id if code not provided
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      period: json['period'] ?? '',
      origin: json['origin'] ?? '',
      material: json['material'] ?? '',
      category: json['category'] ?? '',
      discoveryDate: DateTime.parse(json['discoveryDate'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      museumId: json['museumId'] ?? '',
      area: json['area'],
      displayPosition: json['displayPosition'],
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
