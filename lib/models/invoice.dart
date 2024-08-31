class InvoiceItem {
  String description;
  double amount;

  InvoiceItem({required this.description, required this.amount});
}

class Person {
  String name;
  String city;
  int zipCode;
  String phoneNumber;

  Person({
    required this.name,
    required this.city,
    required this.zipCode,
    required this.phoneNumber,
  });
}

class Invoice {
  int invoiceNumber;
  String invoiceDate;
  Person billTo;
  Person from;
  List<InvoiceItem> items;
  double totalAmount;

  String filename;
  DateTime createdDate;
  DateTime updatedDate;
  String state;

  Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.billTo,
    required this.from,
    required this.items,
    required this.totalAmount,
    required this.createdDate,
    required this.updatedDate,
    this.filename = "my-invoice",
    this.state = "draft",
  });

  Map<String, dynamic> toJson() => {
        "invoiceNumber": invoiceNumber,
        "invoiceDate": invoiceDate,
        "billTo": {
          "name": billTo.name,
          "city": billTo.city,
          "zipCode": billTo.zipCode,
          "phoneNumber": billTo.phoneNumber,
        },
        "from": {
          "name": from.name,
          "city": from.city,
          "zipCode": from.zipCode,
          "phoneNumber": from.phoneNumber,
        },
        "items": [
          for (var item in items)
            {
              "description": item.description,
              "amount": item.amount,
            }
        ],
        "totalAmount": totalAmount,
        "filename": filename,
        "createdDate": createdDate.toIso8601String(),
        "updatedDate": updatedDate.toIso8601String(),
        "state": state,
      };

  factory Invoice.fromJson(Map<String, dynamic> json, {bool isDB = false}) =>
      Invoice(
        invoiceNumber: json[isDB ? "id" : "invoiceNumber"],
        invoiceDate: json["invoiceDate"],
        billTo: Person(
          name: json["billTo"]["name"],
          city: json["billTo"]["city"],
          zipCode: json["billTo"]["zipCode"],
          phoneNumber: json["billTo"]["phoneNumber"],
        ),
        from: Person(
          name: json["from"]["name"],
          city: json["from"]["city"],
          zipCode: json["from"]["zipCode"],
          phoneNumber: json["from"]["phoneNumber"],
        ),
        items: [
          for (var item in json["items"])
            InvoiceItem(
              description: item["description"],
              amount: item["amount"],
            )
        ],
        totalAmount: double.parse(json["totalAmount"].toString()),
        filename: json["filename"],
        createdDate: DateTime.parse(json[isDB ? "created_at" : "createdDate"]),
        updatedDate: DateTime.parse(json["updatedDate"]),
        state: json["state"] ?? "draft",
      );
}
