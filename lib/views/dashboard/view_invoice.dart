import 'package:flutter/material.dart';
import 'package:invoice/models/invoice.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AdminInvoiceActionsPage extends StatefulWidget {
  const AdminInvoiceActionsPage({super.key, required this.invoice});

  final Invoice invoice;

  @override
  State<AdminInvoiceActionsPage> createState() {
    return _AdminInvoiceActionsPage();
  }
}

class _AdminInvoiceActionsPage extends State<AdminInvoiceActionsPage> {
  bool approve = false;
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Jammie",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          ShadSwitch(
            onChanged: (status) {
              setState(() {
                approve = status;
              });
            },
            value: approve,
            label: const Text(
              "Approve",
            ),
          )
        ],
        centerTitle: true,
      ),
    );
  }
}
