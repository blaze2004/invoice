import 'package:flutter/material.dart';
import 'package:invoice/models/organization.dart';

class OrganizationProvider with ChangeNotifier {
  Organization? _selectedOrganization;

  Organization? get selectedOrganization => _selectedOrganization;

  void selectOrganization(Organization organization) {
    _selectedOrganization = organization;
    notifyListeners();
  }
}
