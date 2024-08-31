import 'package:flutter/material.dart';
import 'package:invoice/invoice_page.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/screens/each_invoice.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() {
    return _Dashboard();
  }
}

DateTime now = DateTime.now();
int currIndex = 0;
Person person = Person(
    name: "Rob", city: "New York", zipCode: 12805, phoneNumber: "123456789");
List<Invoice> inoboxitems = [
  Invoice(
      invoiceNumber: 12,
      invoiceDate: "01/01/2000",
      billTo: person,
      from: person,
      items: [],
      totalAmount: 69,
      createdDate: now,
      updatedDate: now)
];

class _Dashboard extends State<Dashboard> {
  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "Name",
        ), //Add person's  Name logic
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.logout)) //Add logout button
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: const Icon(
          LucideIcons.plus,
          size: 30,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const InvoicePage();
          }));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.inbox), label: "Invoice"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileUp), label: "Drafts"),
        ],
        currentIndex: currIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            currIndex = index;
          });
        },
      ),
      body: (inoboxitems.isEmpty)
          ? const Center(
              child: Text(
                "No Invoice Found!",
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              // physics: const BouncingScrollPhysics(),
              itemCount: inoboxitems.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const EachInvoice();
                    }));
                  }, //Tap to see Each invoice details
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: titlePart("Jammie", "Inv1"),
                        trailing: trailingPart(200, true),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: titlePart("Tony", "Inv2"),
                        trailing: trailingPart(150, false),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: titlePart("Brock", "Inv3"),
                        trailing: trailingPart(300, false),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: titlePart("John", "Inv4"),
                        trailing: trailingPart(699, true),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: titlePart("Cole", "Inv5"),
                        trailing: trailingPart(799, true),
                      ),
                    ],
                  ),
                );
              }),
    );
  }

  Widget titlePart(String name, String invoiceId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Icon(
            LucideIcons.file,
            size: 30,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              invoiceId,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }

  Widget trailingPart(double amount, bool status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "\$$amount",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          (status) ? "Approved" : "Not Approved",
          style: TextStyle(
            color: (status) ? const Color.fromARGB(255, 0, 255, 8) : Colors.red,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
