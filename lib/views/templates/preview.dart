import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice/constants/constants.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/models/template.dart';

class InvoicePreview extends StatelessWidget {
  InvoicePreview({super.key, this.template, this.invoice});

  final InvoiceTemplate? template;
  final Invoice? invoice;

  final InvoiceSection _invoiceInfoSection = invoiceInfoSection();
  final InvoiceSection _clientSection = invoiceClientSection();

  @override
  Widget build(BuildContext context) {
    List<InvoiceSection> sections = [];
    if (invoice != null) {
      _invoiceInfoSection.fields![0].value = invoice!.invoiceNumber;
      _invoiceInfoSection.fields![1].value =
          DateFormat('yyyy-MM-dd').format(invoice!.issueDate);
      _invoiceInfoSection.fields![2].value =
          DateFormat('yyyy-MM-dd').format(invoice!.dueDate);
      _clientSection.fields![0].value = invoice!.client.name;
      _clientSection.fields![1].value = invoice!.client.email;
      _clientSection.fields![2].value = invoice!.client.address;
      _clientSection.fields![3].value = invoice!.client.phone;
      sections = [_invoiceInfoSection, _clientSection, ...invoice!.sections];
    }

    if (template != null) {
      _invoiceInfoSection.fields![0].value =
          "${template!.invoiceNumberPrefix}-001";
      sections = [_invoiceInfoSection, ...template!.sections];
    }

    return InkWell(
      onTap: () {
        if (template != null) {
          Navigator.of(context).pushNamed('/new-invoice', arguments: template);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                    template != null ? template!.header : invoice!.header),
                const SizedBox(height: 10.0),
                _buildSections(sections),
                const SizedBox(height: 10.0),
                _buildFooter(
                    template != null ? template!.footer : invoice!.footer),
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
        const Icon(Icons.edit_document),
        Text(
          header.title,
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
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
              Text(
                detail.value,
                style: const TextStyle(fontSize: 14.0),
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
            Text(
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
                  child: Text(item.description),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(item.amount.toString()),
                ),
                if (showQuantity)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(item.quantity.toString()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(String footer) {
    return Text(
      footer,
      style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
    );
  }
}
