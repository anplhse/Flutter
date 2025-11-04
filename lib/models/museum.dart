class Museum {
  final String id;
  final String name;
  final String location;
  final String description;
  final String status;

  Museum({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.status,
  });

  factory Museum.fromJson(Map<String, dynamic> json) {
    return Museum(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'status': status,
    };
  }

  bool get isActive => status == 'Active';
}

