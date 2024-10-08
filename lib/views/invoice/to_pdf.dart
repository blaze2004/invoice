import 'dart:developer';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/models/template.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class InvoicePdf {
  final Invoice invoice;

  InvoicePdf({required this.invoice});

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader(),
              pw.SizedBox(height: 20),
              buildInvoiceDetails(),
              pw.SizedBox(height: 20),
              buildSections(),
              pw.SizedBox(height: 20),
              buildFooter(),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    return pdfBytes;
  }

  pw.Widget buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          invoice.header.title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        ...invoice.header.details.map((detail) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(detail.label,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(detail.value),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget buildInvoiceDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Invoice Details',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Invoice Number',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                invoice.invoiceNumber,
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Issue Date',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                DateFormat('yyyy-MM-dd').format(invoice.issueDate),
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Due Date',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                DateFormat('yyyy-MM-dd').format(invoice.dueDate),
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget buildSections() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: invoice.sections.map((section) {
        NumberFormat format =
            NumberFormat.simpleCurrency(name: section.currency);
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              section.title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            if (section.fields != null)
              ...section.fields!.map((field) {
                return pw.Text('${field.label}: ${field.value}');
              }),
            if (section.items != null)
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Description',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Quantity',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                  ...section.items!.map((item) {
                    final total = item.amount * item.quantity;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.description),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              '${format.currencySymbol}${item.amount.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              '${format.currencySymbol}${total.toStringAsFixed(2)}'),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            if (section.items != null) buildSectionTotal(section),
            pw.SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget buildSectionTotal(InvoiceSection section) {
    final sectionTotal = section.items!
        .map((item) => item.amount * item.quantity)
        .reduce((value, element) => value + element);
    NumberFormat format = NumberFormat.simpleCurrency(name: section.currency);
    return pw.Text(
      'Section Total: ${format.currencySymbol}${sectionTotal.toStringAsFixed(2)}',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  pw.Widget buildFooter() {
    return pw.Text(invoice.footer);
  }

  Future<void> savePdf() async {
    final pdfBytes = await generatePdf();

    final path = await FileSaver.instance
        .saveFile(name: '${invoice.name}.pdf', bytes: pdfBytes);

    if (!kIsWeb) {
      OpenFile.open(path);
    }
  }
}
