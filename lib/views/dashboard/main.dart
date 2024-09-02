import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/invoice.dart';
import 'package:invoice/models/organization.dart';
import 'package:invoice/proivder/organization.dart';
import 'package:invoice/views/dashboard/members.dart';
import 'package:invoice/views/dashboard/view_invoice.dart';
import 'package:invoice/views/invoice/invoice_form.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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

  Future<void> getInvoices() async {
    List<Map<String, dynamic>> invoices = [];
    Organization organization =
        Provider.of<OrganizationProvider>(context, listen: false)
            .selectedOrganization!;
    final data = await supabase
        .from("invoices")
        .select('*')
        .eq('organization_id', organization.id);

    for (var element in data) {
      invoices.add(element);
    }

    List<Invoice> inboxItems = [];
    List<Invoice> draftItems = [];

    for (var element in invoices) {
      if (element['status'] == 'Draft') {
        if (element['created_by'] == session!.user.id) {
          draftItems.add(Invoice.fromJson(element));
        }
      } else {
        inboxItems.add(Invoice.fromJson(element));
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

  void initializeOrg() async {
    await Provider.of<OrganizationProvider>(context, listen: false)
        .getOrganizations();
    await getInvoices();
  }

  @override
  void initState() {
    if (session == null) {
      Navigator.of(context).restorablePushReplacementNamed('/login');
    } else {
      initializeOrg();
    }
    super.initState();
  }

  @override
  Widget build(context) {
    List<Invoice> items = (currIndex == 0) ? _inboxItems : _draftItems;

    Organization? organization =
        Provider.of<OrganizationProvider>(context).selectedOrganization;

    if (organization == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      appBar: AppBar(
        title: organizationSelector(organization.id),
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
          Navigator.of(context).pushNamed('/templates');
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.inbox), label: "Inbox"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileUp), label: "Drafts"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.users), label: "Members"),
        ],
        currentIndex: currIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            if (currIndex == index) return;
            currIndex = index;
            getInvoices();
          });
        },
      ),
      body: (currIndex == 2)
          ? OrgMembersPage(
              userRole: organization.userRole,
              organizationId: organization.id,
            )
          : (items.isEmpty)
              ? const Center(
                  child: Text(
                    "No Invoice Found!",
                    style: TextStyle(fontSize: 30),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    getInvoices();
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (ctx, index) {
                      return InkWell(
                        onTap: () {
                          if (currIndex == 0) {
                            if (organization.userRole == 'Admin') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return AdminInvoiceActionsPage(
                                    invoice: items[index],
                                    userRole: organization.userRole,
                                  );
                                }),
                              );
                            }
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return InvoiceForm(invoice: items[index]);
                            }));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              titlePart(items[index].name,
                                  items[index].invoiceNumber.toString()),
                              trailingPart(items[index].status),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget organizationSelector(int organizationId) {
    List<Organization> organizations =
        Provider.of<OrganizationProvider>(context).organizations;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: ShadSelect<int>(
        placeholder: const Text('Select Organization'),
        initialValue: organizationId,
        onChanged: (value) {
          Provider.of<OrganizationProvider>(context, listen: false)
              .selectOrganization(organizations.firstWhere((e) => e.id == value));
          getInvoices();
        },
        options: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
            child: Text(
              'Organizations',
              style: ShadTheme.of(context).textTheme.muted.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.popoverForeground,
                  ),
              textAlign: TextAlign.start,
            ),
          ),
          ...organizations
              .map((e) => ShadOption(value: e.id, child: Text(e.name))),
        ],
        selectedOptionBuilder: (context, value) => Text(
            organizations.firstWhere((element) => element.id == value).name),
      ),
    );
  }

  Widget titlePart(String name, String invoiceNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                name,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              invoiceNumber,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }

  Widget trailingPart(InvoiceStatus status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          invoiceStateMap.keys.firstWhere(
            (k) => invoiceStateMap[k] == status,
            orElse: () => 'Draft',
          ),
          style: TextStyle(
            color: status == InvoiceStatus.paid
                ? Colors.green
                : status == InvoiceStatus.draft
                    ? Colors.grey
                    : status == InvoiceStatus.inReview
                        ? Colors.orange
                        : status == InvoiceStatus.sent
                            ? Colors.blue
                            : Colors.red,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
