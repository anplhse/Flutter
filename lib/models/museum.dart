class Museum {
  final String id;
  final String name;
  final String description;
  final String address;
  final String imageUrl;
  final String phone;
  final String email;
  final String openingHours;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final DateTime createdAt;

  Museum({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.imageUrl,
    required this.phone,
    required this.email,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
    required this.tags,
    required this.createdAt,
  });

  factory Museum.fromJson(Map<String, dynamic> json) {
    return Museum(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      openingHours: json['openingHours'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,
      'phone': phone,
      'email': email,
      'openingHours': openingHours,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

