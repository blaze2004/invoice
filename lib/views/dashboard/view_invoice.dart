import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InvoiceActionsView extends StatefulWidget {
  const InvoiceActionsView({super.key});

  @override
  State<InvoiceActionsView> createState() {
    return _InvoiceActionsView();
  }
}

class _InvoiceActionsView extends State<InvoiceActionsView> {
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
