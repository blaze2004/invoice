import 'package:flutter/material.dart';
import 'package:invoice/constants/constants.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/views/templates/preview.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AdminInvoiceActionsPage extends StatefulWidget {
  const AdminInvoiceActionsPage(
      {super.key, required this.invoice, required this.userRole});

  final Invoice invoice;
  final String userRole;

  @override
  State<AdminInvoiceActionsPage> createState() {
    return _AdminInvoiceActionsPage();
  }
}

class _AdminInvoiceActionsPage extends State<AdminInvoiceActionsPage> {
  String isLoading = '';

  void updateStatus(int invoiceId, String status) async {
    setState(() {
      isLoading = status;
    });
    try {
      await supabase
          .from("invoices")
          .update({"status": status}).eq("id", invoiceId);

      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Invoice status updated successfully.'),
        ),
      );
    } catch (e) {
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Failed to update invoice status. Please try again.'),
        ),
      );
    }

    setState(() {
      isLoading = '';
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.userRole != "Admin") {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoice.name,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InvoicePreview(
                invoice: widget.invoice,
              ),
              const SizedBox(height: defaultPadding),
              if (widget.invoice.status == InvoiceStatus.inReview)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ShadButton(
                      icon: isLoading == "Sent"
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onPressed: () {
                        updateStatus(widget.invoice.id!, "Sent");
                      },
                      child: const Text('Approve'),
                    ),
                    ShadButton.destructive(
                      icon: isLoading == "Draft"
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onPressed: () {
                        updateStatus(widget.invoice.id!, "Draft");
                      },
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              if (widget.invoice.status == InvoiceStatus.sent)
                ShadButton(
                  icon: isLoading == "Paid"
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onPressed: () {
                    updateStatus(widget.invoice.id!, "Paid");
                  },
                  child: const Text('Mark as Paid'),
                ),
              if (widget.invoice.status == InvoiceStatus.paid)
                Text(
                  'Invoice has been paid.',
                  style: ShadTheme.of(context).textTheme.p,
                ),
              if (widget.invoice.status == InvoiceStatus.overDue)
                Text(
                  'Invoice is overdue.',
                  style: ShadTheme.of(context).textTheme.p,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
