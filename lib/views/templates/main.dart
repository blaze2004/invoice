import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/template.dart';
import 'package:invoice/views/templates/preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvoiceTemplatesListPage extends StatefulWidget {
  const InvoiceTemplatesListPage({super.key});

  @override
  State<InvoiceTemplatesListPage> createState() =>
      _InvoiceTemplatesListPageState();
}

class _InvoiceTemplatesListPageState extends State<InvoiceTemplatesListPage> {
  final List<InvoiceTemplate> _templates = [];

  Future<void> getTemplates() async {
    final response = await supabase.from('invoice_templates').select('*');
    List<InvoiceTemplate> templates = [];
    for (var element in response) {
      templates.add(InvoiceTemplate.fromJson(element));
    }

    setState(() {
      _templates.clear();
      _templates.addAll(templates);
    });
  }

  @override
  void initState() {
    super.initState();
    Session? session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).restorablePushReplacementNamed('/login');
    } else {
      getTemplates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Templates"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: (_templates.isEmpty)
            ? const Center(
                child: Text(
                  "No Invoice Templates Found!",
                  style: TextStyle(fontSize: 30),
                ),
              )
            : PageView.builder(
                itemCount: _templates.length,
                controller: PageController(viewportFraction: 0.8),
                itemBuilder: (context, index) {
                  return InvoiceTemplatePreview(template: _templates[index]);
                },
              ),
      ),
    );
  }
}
