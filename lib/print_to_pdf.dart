import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:invoice/models/invoice.dart';

class InvoicePdf {
  final Invoice invoice;

  InvoicePdf({required this.invoice});

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    String formatCurrency(double amount) {
      return amount.toStringAsFixed(2);
    }
      
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice', style: const pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice Number: ${invoice.invoiceNumber}'),
                  pw.Text('Invoice Date: ${invoice.invoiceDate}'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:'),
                      pw.SizedBox(height: 5),
                      pw.Text('Name: ${invoice.billTo.name}'),
                      pw.Text(
                          'City: ${invoice.billTo.city}\nZipCode:${invoice.billTo.zipCode}'),
                      pw.Text('Phone: ${invoice.billTo.phoneNumber}'),
                      pw.SizedBox(height: 10),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('From:'),
                      pw.SizedBox(height: 5),
                      pw.Text('Name: ${invoice.from.name}'),
                      pw.Text(
                          'City: ${invoice.from.city}\nZipCode: ${invoice.from.zipCode}'),
                      pw.Text('Phone: ${invoice.from.phoneNumber}'),
                      pw.SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
              pw.Text('Items:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                data: <List<String>>[
                  ['Description', 'Amount'],
                  for (var item in invoice.items)
                    [item.description, formatCurrency(item.amount)],
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Amount:'),
                  pw.Text(formatCurrency(invoice.totalAmount),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    return pdfBytes;
  }

  Future<String> savePdf() async {
    final pdfBytes = await generatePdf();
    final directory = await getApplicationDocumentsDirectory();
    final pdfFile = File('${directory.path}/${invoice.filename}.pdf');
    await pdfFile.writeAsBytes(pdfBytes.buffer.asUint8List());
    return pdfFile.path;
  }

  Future<String> sendEmailWithPDF(String recipientEmail) async {
    final String pdfPath = await savePdf();

    final MailOptions email = MailOptions(
      body: 'Invoice attached.',
      subject: 'Invoice',
      recipients: [
        recipientEmail,
      ],
      attachments: [pdfPath],
      isHTML: false,
    );

    try {
      await FlutterMailer.send(email);
      return "Email sent successfully.";
    } catch (error) {
      return error.toString();
    }
  }
}
