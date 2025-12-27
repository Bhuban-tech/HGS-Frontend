class ServiceCategory {
  final String id;
  final String name;
  final String? description;

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}