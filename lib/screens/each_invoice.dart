import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EachInvoice extends StatefulWidget {
  const EachInvoice({super.key});

  @override
  State<EachInvoice> createState() {
    return _EachInvoice();
  }
}

class _EachInvoice extends State<EachInvoice> {
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
