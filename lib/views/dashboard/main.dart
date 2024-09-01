import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/views/dashboard/view_invoice.dart';
import 'package:invoice/views/drafts_screen.dart';
import 'package:invoice/views/inbox_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> {
  Session? session = supabase.auth.currentSession;
  List<Invoice> _inboxItems = [];
  List<Invoice> _draftItems = [];

  int currIndex = 0;

  String getName() {
    String name = (session?.user.userMetadata?['full_name'].toString() ?? "")
        .split(" ")[0];
    return name.length > 1
        ? name[0].toUpperCase() + name.substring(1)
        : name.toUpperCase();
  }

  Future<void> getInvoices() async {
    List<Map<String, dynamic>> invoices = [];
    if (session == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? localInvoiceData = prefs.getString("localInvoiceData");
      if (localInvoiceData != null) {
        jsonDecode(localInvoiceData).forEach((key, value) {
          invoices.add(value);
        });
      }
    } else {
      final data = await supabase.from("invoice").select('*');
      for (var element in data) {
        invoices.add(element);
      }
    }

    List<Invoice> inboxItems = [];
    List<Invoice> draftItems = [];

    for (var element in invoices) {
      if (element['state'] == 'draft') {
        draftItems.add(Invoice.fromJson(element, isDB: true));
      } else {
        inboxItems.add(Invoice.fromJson(element, isDB: true));
      }
    }
    setState(() {
      _inboxItems = inboxItems;
      _draftItems = draftItems;
    });
  }

  Future<void> _logOut() async {
    await supabase.auth.signOut();
    setState(() {
      session = supabase.auth.currentSession;
    });
    if (mounted) {
      Navigator.of(context).restorablePushReplacementNamed('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    if (session == null) {
      Navigator.of(context).restorablePushReplacementNamed('/login');
    } else {
      getInvoices();
    }
  }

  @override
  Widget build(context) {
    List<Invoice> items = (currIndex == 0) ? _inboxItems : _draftItems;
    log("Currintex: $currIndex");
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          getName(),
        ),
        actions: [
          IconButton(
            onPressed: _logOut,
            icon: const Icon(Icons.logout),
          )
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
          Navigator.of(context).pushNamed('/invoice');
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
      body: (currIndex==0)?InboxScreen(items: items):  DraftScreen(items: items,)
    );
  }
}
