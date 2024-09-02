import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/views/invoice/to_pdf.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InvoiceActionsMenu extends StatelessWidget {
  const InvoiceActionsMenu(
      {super.key, required this.invoice, required this.invoiceFormKey});

  final Invoice invoice;
  final GlobalKey<ShadFormState> invoiceFormKey;

  void _submitForApproval(BuildContext context) async {
    if (invoice.id == null) {
      const ShadToast(
        title: Text('Please save the invoice before submitting for approval.'),
      );
    }
    try {
      await supabase.from("invoices").update({
        'status': 'In Review',
      }).eq('id', invoice.id!);
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Invoice submitted for approval.'),
        ),
      );
    } catch (e) {
      log(e.toString());
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title:
              Text('Failed to submit invoice for approval. Please try again.'),
        ),
      );
    }
  }

  void _saveInvoice(BuildContext context) async {
    if (invoiceFormKey.currentState!.validate()) {
      invoiceFormKey.currentState!.save();
      try {
        Map<String, dynamic> data = invoice.toJson();
        data.remove('id');
        if (invoice.id == null) {
          await supabase.from("invoices").insert(data);
        } else {
          await supabase.from("invoices").update(data).eq('id', invoice.id!);
        }

        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Invoice saved successfully.'),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } catch (e) {
        log(e.toString());
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Failed to save invoice. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 170,
      child: ListView(
        children: [
          ListTile(
            title: const Text("Save"),
            leading: const Icon(Icons.save),
            onTap: () {
              _saveInvoice(context);
            },
          ),
          if (invoice.id != null)
            ListTile(
              title: const Text("Submit for Approval"),
              leading: const Icon(Icons.send),
              onTap: () {
                _submitForApproval(context);
              },
            ),
          ListTile(
            title: const Text("Print"),
            leading: const Icon(Icons.print),
            onTap: () {
              Navigator.of(context).pop();
              InvoicePdf(invoice: invoice).savePdf().then(
                (value) {
                  ShadToaster.of(context).show(
                    const ShadToast(
                      title: Text('Invoice printed successfully.'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
