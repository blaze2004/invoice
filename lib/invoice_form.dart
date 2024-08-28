import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:intl/intl.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({
    super.key,
    required this.invoice,
    required this.formKey,
    required this.formRepaintKey,
  });

  final Invoice invoice;
  final GlobalKey<FormState> formKey;
  final GlobalKey formRepaintKey;

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final TextEditingController _invoiceDateController = TextEditingController();
  final DateFormat format = DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    super.initState();
    _invoiceDateController.text = widget.invoice.invoiceDate;
  }

  @override
  void dispose() {
    _invoiceDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Invoice invoice = widget.invoice;

    void addItem() {
      if (widget.formKey.currentState!.validate()) {
        setState(() {
          invoice.items.add(
            InvoiceItem(
              description: "",
              amount: 0.0,
            ),
          );
        });
      }
    }

    void setTotalAmount() {
      double totalAmount = 0;
      for (var item in invoice.items) {
        totalAmount += item.amount;
      }
      setState(() {
        invoice.totalAmount = totalAmount;
      });
    }

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null && picked != format.parse(invoice.invoiceDate)) {
        final formattedDate = "${picked.day}-${picked.month}-${picked.year}";
        setState(() {
          invoice.invoiceDate = formattedDate;
          _invoiceDateController.text = formattedDate;
        });
      }
    }

    return RepaintBoundary(
      key: widget.formRepaintKey,
      child: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              supabase.auth.currentSession == null
                  ? const Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Sign in to save your invoices.',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 0,
                    ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text(
                    'Invoice number:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    invoice.invoiceNumber.toString(),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Invoice name:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(text: invoice.filename),
                      onChanged: (value) {
                        invoice.filename = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an invoice name';
                        }
                        return null;
                      },
                      decoration:
                          const InputDecoration(hintText: 'Invoice Name'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Invoice Date:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  selectDate(context);
                },
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _invoiceDateController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an invoice date';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bill To:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          onChanged: (value) => {
                            invoice.billTo.name = value,
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(labelText: 'Name'),
                          controller:
                              TextEditingController(text: invoice.billTo.name),
                          keyboardType: TextInputType.name,
                        ),
                        TextFormField(
                          onChanged: (value) => {
                            invoice.billTo.city = value,
                          },
                          decoration: const InputDecoration(labelText: 'City'),
                          controller:
                              TextEditingController(text: invoice.billTo.city),
                        ),
                        TextFormField(
                          onChanged: (value) => {
                            if (int.tryParse(value) != null)
                              {
                                invoice.billTo.zipCode = int.parse(value),
                              }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a zip code';
                            } else if (value.length != 6) {
                              return 'Zip code must be 6 digits';
                            } else if (int.tryParse(value) == null) {
                              return 'Zip code must be a number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Zip Code'),
                          controller: TextEditingController(
                              text: invoice.billTo.zipCode == 0
                                  ? null
                                  : invoice.billTo.zipCode.toString()),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                          onChanged: (value) => {
                            invoice.billTo.phoneNumber = value,
                          },
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          controller: TextEditingController(
                              text: invoice.billTo.phoneNumber),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'From:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          onChanged: (value) => {
                            invoice.from.name = value,
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(labelText: 'Name'),
                          controller:
                              TextEditingController(text: invoice.from.name),
                          keyboardType: TextInputType.name,
                        ),
                        TextFormField(
                          onChanged: (value) => {
                            invoice.from.city = value,
                          },
                          decoration: const InputDecoration(labelText: 'City'),
                          controller:
                              TextEditingController(text: invoice.from.city),
                        ),
                        TextFormField(
                          onChanged: (value) => {
                            if (int.tryParse(value) != null)
                              {
                                invoice.from.zipCode = int.parse(value),
                              }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a zip code';
                            } else if (value.length != 6) {
                              return 'Zip code must be 6 digits';
                            } else if (int.tryParse(value) == null) {
                              return 'Zip code must be a number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Zip Code'),
                          controller: TextEditingController(
                              text: invoice.from.zipCode == 0
                                  ? null
                                  : invoice.from.zipCode.toString()),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                          onChanged: (value) => {
                            invoice.from.phoneNumber = value,
                          },
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          controller: TextEditingController(
                              text: invoice.from.phoneNumber),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64.0),
              const Text(
                'Invoice Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: invoice.items.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: invoice.items[index].description,
                          ),
                          onChanged: (value) {
                            invoice.items[index].description = value;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: invoice.items[index].amount == 0.0
                                ? null
                                : invoice.items[index].amount.toString(),
                          ),
                          onChanged: (value) {
                            if (double.tryParse(value) != null) {
                              invoice.items[index].amount = double.parse(value);
                              setTotalAmount();
                            }
                          },
                          decoration:
                              const InputDecoration(labelText: 'Amount'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              invoice.items.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.delete)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: addItem,
                child: const Text('Add Item'),
              ),
              const SizedBox(height: 32.0),
              Text(
                'Total Amount: ${invoice.totalAmount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
