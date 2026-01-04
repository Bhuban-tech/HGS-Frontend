class ServiceProvider {
  final String id;
  final String userName;
  final String email;
  final String phoneNumber;
  final bool active;

  ServiceProvider({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.active,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['_id'] ?? json['id'] ?? '',
      userName: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      active: json['isActive'] == true || 
             json['active'] == true || 
             json['status'] == 'approved' ||
             json['approved'] == true ||
             json['approved'] == 1, // Adjust based on your backend response
    );
  }
}