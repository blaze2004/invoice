import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/models/organization.dart';
import 'package:invoice/models/template.dart';
import 'package:invoice/proivder/organization.dart';
import 'package:invoice/views/invoice/invoice_form.dart';
import 'package:provider/provider.dart';

class NewInvoicePage extends StatelessWidget {
  const NewInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    InvoiceTemplate template =
        (ModalRoute.of(context)?.settings.arguments) as InvoiceTemplate;

    Organization? organization =
        Provider.of<OrganizationProvider>(context).selectedOrganization;

    if (organization == null) {
      Navigator.of(context).pushReplacementNamed("/dashboard");
    }

    return InvoiceForm(
        invoice: Invoice(
      name: template.header.title,
      description: template.description,
      header: template.header,
      sections: template.sections,
      footer: template.footer,
      client: InvoiceClient(address: "", email: "", name: "", phone: ""),
      invoiceNumber: template.invoiceNumberPrefix,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      templateId: template.id,
      status: InvoiceStatus.draft,
      createdBy: supabase.auth.currentUser!.id,
      organizationId: organization!.id,
    ));
  }
}
