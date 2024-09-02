class Organization {
  final int id;
  final String name;
  final String userRole;

  Organization({
    required this.id,
    required this.name,
    this.userRole = "Staff",
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['organizations']['id'],
      name: json['organizations']['name'],
      userRole: json['role'],
    );
  }
}
