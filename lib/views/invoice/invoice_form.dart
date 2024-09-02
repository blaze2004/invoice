import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice/constants/constants.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/models/template.dart';
import 'package:invoice/views/invoice/invoice_actions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key, required this.invoice});

  final Invoice invoice;

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final formKey = GlobalKey<ShadFormState>();

  final InvoiceSection _invoiceInfoSection = invoiceInfoSection();
  final InvoiceSection _clientSection = invoiceClientSection();

  late final Invoice _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    _invoiceInfoSection.fields![0].value = _invoice.invoiceNumber;
    _invoiceInfoSection.fields![1].value =
        DateFormat('yyyy-MM-dd').format(_invoice.issueDate);
    _invoiceInfoSection.fields![2].value =
        DateFormat('yyyy-MM-dd').format(_invoice.dueDate);
    _clientSection.fields![0].value = _invoice.client.name;
    _clientSection.fields![1].value = _invoice.client.email;
    _clientSection.fields![2].value = _invoice.client.address;
    _clientSection.fields![3].value = _invoice.client.phone;
  }

  void showMoreOptionsPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: InvoiceActionsMenu(
              invoiceFormKey: formKey,
              invoice: Invoice(
                id: _invoice.id,
                name: _invoice.header.title,
                description: _invoice.description,
                header: _invoice.header,
                sections: _invoice.sections,
                footer: _invoice.footer,
                client: InvoiceClient(
                    address: _clientSection.fields![2].value,
                    email: _clientSection.fields![1].value,
                    name: _clientSection.fields![0].value,
                    phone: _clientSection.fields![3].value),
                invoiceNumber: _invoiceInfoSection.fields![0].value,
                issueDate: _invoiceInfoSection.fields![1].value.isEmpty
                    ? DateTime.now()
                    : DateTime.parse(_invoiceInfoSection.fields![1].value),
                dueDate: _invoiceInfoSection.fields![2].value.isEmpty
                    ? DateTime.now().add(const Duration(days: 30))
                    : DateTime.parse(_invoiceInfoSection.fields![2].value),
                templateId: _invoice.templateId,
                status: _invoice.status,
                createdBy: supabase.auth.currentUser!.id,
                organizationId: _invoice.organizationId,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _invoice.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showMoreOptionsPopup(context);
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding / 2),
          child: ShadForm(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(_invoice.header),
                const SizedBox(height: 10.0),
                _buildSections([
                  _invoiceInfoSection,
                  _clientSection,
                  ..._invoice.sections
                ]),
                const SizedBox(height: 10.0),
                _buildFooter(_invoice.footer),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(InvoiceHeader header) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        ShadInputFormField(
          id: 'header_title',
          initialValue: header.title,
          placeholder: const Text('Title'),
          validator: (v) {
            if (v.isEmpty) {
              return 'This field is required.';
            }
            return null;
          },
          onChanged: (v) {
            setState(() {
              header.title = v;
            });
          },
        ),
        ...header.details.map<Widget>((detail) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: const TextStyle(
                    fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              ShadInputFormField(
                id: 'header_${detail.label}',
                initialValue: detail.value,
                placeholder: Text(detail.label),
                validator: (v) {
                  if (v.isEmpty) {
                    return 'This field is required.';
                  }
                  return null;
                },
                onChanged: (v) {
                  setState(() {
                    detail.value = v;
                  });
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSections(List<InvoiceSection> sections) {
    if (sections.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map<Widget>((section) {
        bool showTotal = section.items != null;
        double totalAmount = 0.0;
        if (section.items != null) {
          for (InvoiceSectionItem item in section.items!) {
            totalAmount += item.amount * item.quantity;
          }
        }

        NumberFormat format =
            NumberFormat.simpleCurrency(name: section.currency);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5.0),
              if (section.fields != null) ..._buildFields(section.fields!),
              if (section.items != null)
                _buildItemsTable(section.items!, section.showQuantity),
              if (showTotal)
                Text(
                  'Total: ${format.currencySymbol}${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildFields(List<InvoiceSectionField> fields) {
    return fields.map<Widget>((field) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              field.label,
              style: const TextStyle(fontSize: 16.0),
            ),
            field.editable
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: field.type == InvoiceSectionFieldType.date
                        ? InkWell(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              ).then((value) {
                                log('Date selected: $value');
                                if (value != null) {
                                  setState(() {
                                    field.value =
                                        DateFormat('yyyy-MM-dd').format(value);
                                  });
                                }
                              });
                            },
                            child: IgnorePointer(
                              child: ShadInputFormField(
                                id: 'field_${field.label}',
                                initialValue: field.value,
                                placeholder: Text(field.label),
                                validator: (v) {
                                  if (v.isEmpty) {
                                    return 'This field is required.';
                                  }
                                  return null;
                                },
                                onChanged: (v) {
                                  setState(() {
                                    field.value = v.toString();
                                  });
                                },
                              ),
                            ),
                          )
                        : ShadInputFormField(
                            id: 'field_${field.label}',
                            initialValue: field.value,
                            placeholder: Text(field.label),
                            keyboardType:
                                field.type == InvoiceSectionFieldType.number
                                    ? TextInputType.number
                                    : TextInputType.text,
                            validator: (v) {
                              if (v.isEmpty) {
                                return 'This field is required.';
                              }

                              if (field.type == InvoiceSectionFieldType.email) {
                                if (!EmailValidator.validate(v)) {
                                  return 'Invalid email address.';
                                }
                              }

                              if (field.type == InvoiceSectionFieldType.phone) {
                                if (v.length < 10) {
                                  return 'Invalid phone number.';
                                }
                              }
                              return null;
                            },
                            onChanged: (v) {
                              setState(() {
                                field.value = v.toString();
                              });
                            },
                          ),
                  )
                : Text(
                    field.value,
                    style: const TextStyle(fontSize: 16.0),
                  ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildItemsTable(List<InvoiceSectionItem> items, bool showQuantity) {
    if (items.isEmpty) return Container();

    Map<int, TableColumnWidth> columnWidths = {
      0: const FlexColumnWidth(2),
      1: const FlexColumnWidth(1),
    };

    if (showQuantity) {
      columnWidths[2] = const FlexColumnWidth(1);
    }

    return Table(
      columnWidths: columnWidths,
      children: [
        TableRow(
          children: [
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Amount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (showQuantity)
              const Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        ...items.map<TableRow>(
          (item) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ShadInputFormField(
                    initialValue: item.description,
                    placeholder: const Text('Description'),
                    validator: (v) {
                      if (v.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                    onChanged: (v) {
                      setState(() {
                        item.description = v;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ShadInputFormField(
                    initialValue: item.amount.toString(),
                    placeholder: const Text('Amount'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                    onChanged: (v) {
                      if (v.isEmpty) return;
                      setState(() {
                        try {
                          item.amount = double.parse(v);
                        } catch (e) {
                          item.amount = int.parse(v).toDouble();
                        }
                      });
                    },
                  ),
                ),
                if (showQuantity)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ShadInputFormField(
                      initialValue: item.quantity.toString(),
                      placeholder: const Text('Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
                      onChanged: (v) {
                        setState(() {
                          item.quantity = int.parse(v);
                        });
                      },
                    ),
                  ),
              ],
            );
          },
        ),

        // Add new item button
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    items.add(InvoiceSectionItem(
                      description: '',
                      amount: 0.0,
                      quantity: 1,
                    ));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add new item'),
              ),
            ),
            Container(),
            if (showQuantity) Container(),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(String footer) {
    return ShadInputFormField(
      id: 'footer',
      initialValue: footer,
      placeholder: const Text('Footer'),
      maxLines: 3,
      onChanged: (v) {
        setState(() {
          _invoice.footer = v;
        });
      },
    );
  }
}
