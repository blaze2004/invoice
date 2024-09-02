import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/models/template.dart';
import 'package:invoice/views/invoice/invoice_form.dart';

class NewInvoicePage extends StatefulWidget {
  const NewInvoicePage({super.key});

  @override
  State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  int? organizationId;

  void getOrganizationId() async {
    final data = await supabase
        .from('user_organizations')
        .select('organization_id')
        .limit(1)
        .single();
    setState(() {
      organizationId = data['organization_id'] as int;
    });
  }

  @override
  void initState() {
    super.initState();
    getOrganizationId();
  }

  @override
  Widget build(BuildContext context) {
    InvoiceTemplate template =
        (ModalRoute.of(context)?.settings.arguments) as InvoiceTemplate;

    if (organizationId == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
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
      organizationId: organizationId!,
    ));
  }
}
