class Service {
  final String? id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final String? imageUrl;
  final double? basePrice;
  final String? priceUnit; // per hour, per day, fixed
  final bool isActive;
  final DateTime? createdAt;

  Service({
    this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    this.imageUrl,
    this.basePrice,
    this.priceUnit,
    this.isActive = true,
    this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName'] ?? '',
      imageUrl: json['imageUrl'],
      basePrice: json['basePrice']?.toDouble(),
      priceUnit: json['priceUnit'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (basePrice != null) 'basePrice': basePrice,
      if (priceUnit != null) 'priceUnit': priceUnit,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  String get displayPrice {
    if (basePrice == null) return 'Contact for price';
    final price = basePrice!.toStringAsFixed(0);
    final unit = priceUnit ?? '';
    return 'Rs. $price${unit.isNotEmpty ? '/$unit' : ''}';
  }
}

class Category {
  final String? id;
  final String name;
  final String? description;
  final String? iconName;
  final bool isActive;

  Category({
    this.id,
    required this.name,
    this.description,
    this.iconName,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'],
      iconName: json['iconName'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (iconName != null) 'iconName': iconName,
      'isActive': isActive,
    };
  }
}
