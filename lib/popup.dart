import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/print_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> mapObjectToJson(Map<String, Invoice> dataSet,
    {bool isDB = false}) {
  final Map<String, dynamic> data = <String, dynamic>{};

  for (var entry in dataSet.entries) {
    data[entry.key] = {
      "invoiceDate": entry.value.invoiceDate,
      "billTo": {
        "name": entry.value.billTo.name,
        "city": entry.value.billTo.city,
        "zipCode": entry.value.billTo.zipCode,
        "phoneNumber": entry.value.billTo.phoneNumber,
      },
      "from": {
        "name": entry.value.from.name,
        "city": entry.value.from.city,
        "zipCode": entry.value.from.zipCode,
        "phoneNumber": entry.value.from.phoneNumber,
      },
      "items": [
        for (var item in entry.value.items)
          {
            "description": item.description,
            "amount": item.amount,
          }
      ],
      "totalAmount": entry.value.totalAmount,
      "filename": entry.value.filename,
      "updatedDate": entry.value.updatedDate.toString(),
    };

    data[entry.key][isDB ? "created_at" : "createdDate"] =
        entry.value.createdDate.toString();
    data[entry.key][isDB ? "id" : "invoiceNumber"] = entry.value.invoiceNumber;
  }
  return data;
}

Future<void> updateLocalInvoiceDataset(
    Map<String, Invoice> localInvoiceDataSet) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String localInvoiceData =
      jsonEncode(mapObjectToJson(localInvoiceDataSet));
  await prefs.setString("localInvoiceData", localInvoiceData);
}

class OptionsPopup extends StatelessWidget {
  const OptionsPopup({
    super.key,
    required this.invoice,
    required this.formKey,
    required this.formRepaintKey,
    required this.localInvoiceDataSet,
  });

  final Invoice invoice;
  final GlobalKey<FormState> formKey;
  final GlobalKey formRepaintKey;
  final Map<String, Invoice> localInvoiceDataSet;

  Future<String> _saveInvoice(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final String invoiceDataKey = invoice.invoiceNumber.toString();
      localInvoiceDataSet.addEntries({
        invoiceDataKey: invoice,
      }.entries);

      if (supabase.auth.currentSession != null) {
        dynamic data = mapObjectToJson(
          localInvoiceDataSet,
          isDB: true,
        )[invoiceDataKey];
        data["email"] = supabase.auth.currentSession!.user.email;
        try {
          await supabase.from("invoice").upsert(data);
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error saving invoice to cloud."),
            ),
          );
        }
      }
      await updateLocalInvoiceDataset(localInvoiceDataSet);
      return "Invoice saved successfully.";
    }
    return "Fix form errors before saving.";
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
                } else if (!RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                    .hasMatch(value)) {
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
              onPressed: () {
                if (emailFormKey.currentState!.validate()) {
                  InvoicePdf(invoice: invoice)
                      .sendEmailWithPDF(emailController.text)
                      .then(
                    (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value),
                        ),
                      );
                    },
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: 200,
      child: ListView(
        children: [
          ListTile(
            title: const Text("Save"),
            leading: const Icon(Icons.save),
            onTap: () {
              _saveInvoice(context)
                  .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value),
                        ),
                      ));
              Navigator.of(context).pop();
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invoice printed successfully."),
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

class InvoiceManagerPopup extends StatefulWidget {
  const InvoiceManagerPopup(
      {super.key,
      required this.localInvoiceDataSet,
      required this.editInvoice});

  final Map<String, Invoice> localInvoiceDataSet;

  final void Function(String) editInvoice;

  @override
  State<InvoiceManagerPopup> createState() => _InvoiceManagerPopupState();
}

class _InvoiceManagerPopupState extends State<InvoiceManagerPopup> {
  @override
  Widget build(BuildContext context) {
    Future<void> deleteInvoiceFromDB(int invoiceNumber) async {
      try {
        await supabase.from("invoice").delete().eq("id", invoiceNumber);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error deleting invoice from cloud.")),
        );
      }
    }

    void showDeleteInvoiceWarning(BuildContext context, String invoiceId) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Delete Invoice"),
              content:
                  const Text("Are you sure you want to delete this invoice?"),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.localInvoiceDataSet.remove(invoiceId);
                      deleteInvoiceFromDB(int.parse(invoiceId));
                      updateLocalInvoiceDataset(widget.localInvoiceDataSet);
                    });

                    Navigator.of(context).pop();
                  },
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                ),
              ],
            );
          });
    }

    if (widget.localInvoiceDataSet.isEmpty) {
      return const SizedBox(
        height: 500,
        width: 500,
        child: Center(
          child: Text("No invoices found"),
        ),
      );
    }

    final DateFormat format = DateFormat("dd-MM-yyyy HH:mm");

    return Container(
      height: 500,
      width: 500,
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          for (var invoice in widget.localInvoiceDataSet.values)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: Text(
                            invoice.filename,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          format.format(invoice.createdDate),
                          style: const TextStyle(
                              fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            widget
                                .editInvoice(invoice.invoiceNumber.toString());
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            showDeleteInvoiceWarning(
                              context,
                              invoice.invoiceNumber.toString(),
                            );
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
