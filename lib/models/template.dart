class InvoiceHeader {
  String title;
  late final String logo;
  final List<InvoiceHeaderDetail> details;

  InvoiceHeader({
    required this.title,
    required this.details,
    String templateLogo = "",
  }) {
    if (templateLogo.isEmpty) {
      logo =
          "https://api.dicebear.com/9.x/thumbs/svg?seed=${title.split(" ")[0]}";
    } else {
      logo = templateLogo;
    }
  }

  factory InvoiceHeader.fromJson(Map<String, dynamic> json) {
    return InvoiceHeader(
      title: json['title'] as String,
      templateLogo: json['logo'] as String? ?? "",
      details: (json['details'] as List<dynamic>)
          .map((item) =>
              InvoiceHeaderDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'logo': logo,
      'details': details.map((item) => item.toJson()).toList(),
    };
  }
}

class InvoiceHeaderDetail {
  final String label;
  String value;

  InvoiceHeaderDetail({required this.label, required this.value});

  factory InvoiceHeaderDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceHeaderDetail(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class InvoiceSection {
  final String title;
  final String currency;
  final bool showQuantity;
  final List<InvoiceSectionField>? fields;
  final List<InvoiceSectionItem>?
      items; // List of items, each with a description and amount and optional features

  InvoiceSection({
    required this.title,
    this.fields,
    this.items,
    this.currency = "USD",
    this.showQuantity = false,
  });

  factory InvoiceSection.fromJson(Map<String, dynamic> json) {
    return InvoiceSection(
      title: json['title'] as String,
      fields: json['fields'] != null
          ? (json['fields'] as List<dynamic>)
              .map((field) =>
                  InvoiceSectionField.fromJson(field as Map<String, dynamic>))
              .toList()
          : null,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) =>
                  InvoiceSectionItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      currency: json['currency'] as String? ?? "USD",
      showQuantity: json['showQuantity'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'fields': fields?.map((field) => field.toJson()).toList(),
      'items': items?.map((item) => item.toJson()).toList(),
      'currency': currency,
      'showQuantity': showQuantity,
    };
  }
}

enum InvoiceSectionFieldType { text, number, date, currency }

class InvoiceSectionField {
  final String label;
  String value;
  final bool editable;
  final InvoiceSectionFieldType type;

  InvoiceSectionField({
    required this.label,
    required this.value,
    required this.editable,
    this.type = InvoiceSectionFieldType.text,
  });

  factory InvoiceSectionField.fromJson(Map<String, dynamic> json) {
    return InvoiceSectionField(
      label: json['label'] as String,
      value: json['value'] as String,
      editable: json['editable'] as bool? ?? true,
      type: InvoiceSectionFieldType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => InvoiceSectionFieldType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'editable': editable,
      'type': type.toString().split('.').last,
    };
  }
}

class InvoiceSectionItem {
  String description;
  double amount;
  int quantity;

  InvoiceSectionItem({
    required this.description,
    required this.amount,
    this.quantity = 1,
  });

  factory InvoiceSectionItem.fromJson(Map<String, dynamic> json) {
    return InvoiceSectionItem(
      description: json['description'] as String,
      amount: double.parse(json['amount'].toString()),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'quantity': quantity,
    };
  }
}

class InvoiceTemplate {
  final int id;
  final String name;
  final String description;
  final InvoiceHeader header;
  final List<InvoiceSection> sections;
  String footer;

  InvoiceTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.header,
    required this.sections,
    this.footer = "",
  });

  factory InvoiceTemplate.fromJson(Map<String, dynamic> json) {
    return InvoiceTemplate(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      header: InvoiceHeader.fromJson(json['header'] as Map<String, dynamic>),
      sections: (json['sections'] as List<dynamic>)
          .map((section) =>
              InvoiceSection.fromJson(section as Map<String, dynamic>))
          .toList(),
      footer: json['footer'] as String? ?? "",
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
    };
  }
}
