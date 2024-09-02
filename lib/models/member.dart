class OrgMember {
  final String id;
  final String name;
  final String role;
  final int orgId;

  OrgMember({
    required this.id,
    required this.name,
    required this.role,
    required this.orgId,
  });

  factory OrgMember.fromJson(Map<String, dynamic> json) {
    return OrgMember(
      id: json['user_id'],
      name: json['profiles']['full_name'],
      role: json['role'],
      orgId: json['organization_id'],
    );
  }
}

class InvitedMember {
  final String email;
  final String role;
  final int orgId;

  InvitedMember({
    required this.email,
    required this.role,
    required this.orgId,
  });

  factory InvitedMember.fromJson(Map<String, dynamic> json) {
    return InvitedMember(
      email: json['email'],
      role: json['role'],
      orgId: json['organization_id'],
    );
  }
}
