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
  });
}
