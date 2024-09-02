import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/views/invoice/to_pdf.dart';
import 'package:open_file_plus/open_file_plus.dart';
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
        if (data['id'] == null) {
          data.remove('id');
        }
        await supabase.from("invoices").upsert(data);

        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Invoice saved successfully.'),
          ),
        );
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

  void _askRecipientEmailPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Enter Email'),
          content: Form(
            key: emailFormKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                } else if (!EmailValidator.validate(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailFormKey.currentState!.validate()) {
                  InvoicePdf(invoice: invoice)
                      .sendEmailWithPDF(emailController.text)
                      .then(
                    (value) {
                      ShadToaster.of(context).show(
                        ShadToast(
                          title: Text(value),
                        ),
                      );
                    },
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 220,
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
            title: const Text("Email"),
            leading: const Icon(Icons.email),
            onTap: () {
              _askRecipientEmailPopup(context);
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

                  OpenFile.open(value);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
