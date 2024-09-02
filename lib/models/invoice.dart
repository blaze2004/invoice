import 'package:intl/intl.dart';
import 'package:invoice/models/template.dart';

enum InvoiceStatus { draft, sent, paid, cancelled, inReview }

Map<String, InvoiceStatus> invoiceStateMap = {
  'Draft': InvoiceStatus.draft,
  'In Review': InvoiceStatus.inReview,
  'Sent': InvoiceStatus.sent,
  'Paid': InvoiceStatus.paid,
  'Overdue': InvoiceStatus.cancelled,
};

class Invoice {
  final int? id;
  final String name;
  final String description;
  final InvoiceHeader header;
  final List<InvoiceSection> sections;
  String footer;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final int templateId;
  final InvoiceStatus status;
  final String createdBy;
  final int? organizationId;

  Invoice({
    this.id,
    required this.name,
    required this.description,
    required this.header,
    required this.sections,
    required this.footer,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.templateId,
    required this.status,
    required this.createdBy,
    this.organizationId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      header: InvoiceHeader.fromJson(json['header'] as Map<String, dynamic>),
      sections: (json['sections'] as List<dynamic>)
          .map((section) =>
              InvoiceSection.fromJson(section as Map<String, dynamic>))
          .toList(),
      footer: json['footer'] as String,
      invoiceNumber: json['invoice_number'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      templateId: json['template_id'] as int,
      status: invoiceStateMap[json['status'] as String]!,
      createdBy: json['created_by'] as String,
      organizationId: json['organization_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'header': header.toJson(),
      'sections': sections.map((section) => section.toJson()).toList(),
      'footer': footer,
      'invoice_number': invoiceNumber,
      'issue_date': DateFormat('yyyy-MM-dd').format(issueDate),
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      'template_id': templateId,
      'status': invoiceStateMap.keys.firstWhere(
        (k) => invoiceStateMap[k] == status,
        orElse: () => 'Draft',
      ),
      'created_by': createdBy,
      'organization_id': organizationId,
    };
  }
}
