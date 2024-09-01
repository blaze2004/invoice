import 'package:flutter/material.dart';
import 'package:invoice/models/invoice.dart';

class DraftScreen extends StatefulWidget {
   DraftScreen({super.key ,required this.items});
  List<Invoice> items;

  @override
  State<DraftScreen> createState() {
    return _InboxScreen();
  }
}

class _InboxScreen extends State<DraftScreen> {
  @override
  Widget build(context) {
  final allitems = widget.items;
    return const Scaffold(
      body: const Center(
              child: Text(
                "No Drafts Found!",
                style: TextStyle(fontSize: 30),
              ),
            )
    );
  }
}
