import 'package:flutter/material.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/views/dashboard/view_invoice.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InboxScreen extends StatefulWidget {
  InboxScreen({super.key, required this.items});
  List<Invoice> items;

  @override
  State<InboxScreen> createState() {
    return _InboxScreen();
  }
}

class _InboxScreen extends State<InboxScreen> {
  @override
  Widget build(context) {
    List<Invoice> allitems = widget.items;
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
  body: (allitems.isEmpty)
          ? const Center(
              child: Text(
                "No Invoice Found!",
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              // physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: allitems.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const InvoiceActionsView();
                    }));
                  }, //Tap to see Each invoice details
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        titlePart(allitems[index].filename,
                            allitems[index].invoiceNumber.toString()),
                        trailingPart(
                            allitems[index].totalAmount, allitems[index].state),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
  Widget titlePart(String name, String invoiceId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Icon(
            LucideIcons.file,
            size: 30,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              invoiceId,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }

  Widget trailingPart(double amount, String status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "\$$amount",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(
            color: (status == "approved")
                ? const Color.fromARGB(255, 0, 255, 8)
                : status == "rejected"
                    ? Colors.red
                    : Colors.yellowAccent,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
