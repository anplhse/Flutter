class Artifact {
  final String id;
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

  Artifact({
    required this.id,
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
  });

  factory Artifact.fromJson(Map<String, dynamic> json) {
    return Artifact(
      id: json['id'] ?? '',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}
