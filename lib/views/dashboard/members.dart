import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:invoice/constants/constants.dart';
import 'package:invoice/main.dart';
import 'package:invoice/models/member.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OrgMembersPage extends StatefulWidget {
  const OrgMembersPage(
      {super.key, required this.organizationId, required this.userRole});

  final int organizationId;
  final String userRole;

  @override
  State<OrgMembersPage> createState() => _OrgMembersPageState();
}

class _OrgMembersPageState extends State<OrgMembersPage> {
  final List<OrgMember> _members = [];
  final List<InvitedMember> _invitedMembers = [];

  void getMembers() async {
    List<OrgMember> members = [];
    final data = await supabase
        .from("organization_members")
        .select("*, profiles(full_name)")
        .eq("organization_id", widget.organizationId);

    for (var element in data) {
      members.add(OrgMember.fromJson(element));
    }

    setState(() {
      _members.clear();
      _members.addAll(members);
    });

    if (widget.userRole == "Admin") {
      List<InvitedMember> invitedMembers = [];
      final invitedData = await supabase
          .from("organization_invitations")
          .select("*")
          .eq("organization_id", widget.organizationId);

      for (var element in invitedData) {
        invitedMembers.add(InvitedMember.fromJson(element));

        setState(() {
          _invitedMembers.clear();
          _invitedMembers.addAll(invitedMembers);
        });
      }
    }
  }

  void _inviteUserPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Enter Email'),
          content: Form(
            key: emailFormKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                } else if (!EmailValidator.validate(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailFormKey.currentState!.validate()) {
                  try {
                    await supabase.from("organization_invitations").insert({
                      'email': emailController.text,
                      'organization_id': widget.organizationId,
                    });
                    ShadToaster.of(context).show(
                      const ShadToast(
                        title: Text('Invitation sent.'),
                      ),
                    );

                    getMembers();
                  } catch (e) {
                    ShadToaster.of(context).show(
                      const ShadToast.destructive(
                        title: Text('Failed to invite user. Please try again.'),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.userRole == "Admin") ...[
              Text(
                'Invited Members',
                style: ShadTheme.of(context).textTheme.h3,
              ),
              const SizedBox(height: 10),
              if (_invitedMembers.isNotEmpty)
                for (var member in _invitedMembers)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.person,
                        color:
                            member.role == "Admin" ? Colors.red : Colors.teal),
                      title: Text(
                        member.email,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(member.role),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
              if (_invitedMembers.isEmpty) const Text('No invited members'),
              ShadButton(
                onPressed: () {
                  _inviteUserPopup(context);
                },
                child: const Text('Invite Members'),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Members',
              style: ShadTheme.of(context).textTheme.h3,
            ),
            const SizedBox(height: 10),
            if (_members.isNotEmpty)
              for (var member in _members)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.person,
                        color:
                            member.role == "Admin" ? Colors.red : Colors.teal),
                    title: Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(member.role),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
            if (_members.isEmpty) const Text('No members'),
          ],
        ),
      ),
    );
  }
}
