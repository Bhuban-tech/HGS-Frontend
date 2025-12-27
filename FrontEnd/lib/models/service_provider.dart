class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool active;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.active,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      active: json['active'],
    );
  }
}

class ServiceProvider {
  final String service;
  final String name;
  final String rate;
  final String location;
  final String? imageUrl;

  ServiceProvider({
    required this.service,
    required this.name,
    required this.rate,
    required this.location,
    this.imageUrl,
  });

  get userName => null;

  bool? get active => null;

  String? get phoneNumber => null;

  String? get email => null;

  String? get id => null;
}