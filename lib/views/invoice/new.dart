import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/models/template.dart';
import 'package:invoice/views/invoice/invoice_form.dart';

class NewInvoicePage extends StatelessWidget {
  const NewInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    InvoiceTemplate template =
        (ModalRoute.of(context)?.settings.arguments) as InvoiceTemplate;

    late final int organizationId;

    void getOrganizationId() async {
      final data = await supabase
          .from('user_organizations')
          .select('organization_id')
          .limit(1)
          .single();
      organizationId = data['organization_id'] as int;
    }

    getOrganizationId();

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
      organizationId: organizationId,
    ));
  }
}
