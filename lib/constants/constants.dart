import 'package:intl/intl.dart';
import 'package:invoice/models/template.dart';

const double defaultPadding = 16.0;

InvoiceSection invoiceInfoSection({String invoiceNumber = ""}) =>
    InvoiceSection(title: "Invoice Details", fields: [
      InvoiceSectionField(
          label: "Invoice Number",
          value: invoiceNumber,
          editable: false,
          type: InvoiceSectionFieldType.text),
      InvoiceSectionField(
          label: "Issue Date",
          value: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          editable: true,
          type: InvoiceSectionFieldType.date),
      InvoiceSectionField(
          label: "Due Date",
          value: DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(const Duration(days: 30))),
          editable: true,
          type: InvoiceSectionFieldType.date),
    ]);

InvoiceSection invoiceClientSection() =>
    InvoiceSection(title: "Client Details", fields: [
      InvoiceSectionField(
          label: "Name",
          value: "",
          editable: true,
          type: InvoiceSectionFieldType.text),
      InvoiceSectionField(
          label: "Email",
          value: "",
          editable: true,
          type: InvoiceSectionFieldType.email),
      InvoiceSectionField(
          label: "Address",
          value: "",
          editable: true,
          type: InvoiceSectionFieldType.text),
      InvoiceSectionField(
          label: "Phone",
          value: "",
          editable: true,
          type: InvoiceSectionFieldType.phone),
    ]);
