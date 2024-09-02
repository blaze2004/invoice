import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/organization.dart';

class OrganizationProvider with ChangeNotifier {
  Organization? _selectedOrganization;
  final List<Organization> _organizations = [];

  Organization? get selectedOrganization => _selectedOrganization;

  List<Organization> get organizations => _organizations;

  void selectOrganization(Organization organization) {
    _selectedOrganization = organization;
    notifyListeners();
  }

  Future<void> getOrganizations() async {
    final data = await supabase
        .from("user_organizations")
        .select("role, organizations(id, name)");
    if (data.isNotEmpty) {
      List<Organization> organizations = [];
      for (var element in data) {
        organizations.add(Organization.fromJson(element));
      }

      _organizations.clear();
      _organizations.addAll(organizations);

      _selectedOrganization ??= _organizations.first;
    }
  }
}
