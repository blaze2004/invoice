import 'package:flutter/material.dart';
import 'package:invoice/constants/constants.dart';
import 'package:invoice/main.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserOnbaordingPage extends StatefulWidget {
  const UserOnbaordingPage({super.key});

  @override
  State<UserOnbaordingPage> createState() => _UserOnbaordingPageState();
}

class _UserOnbaordingPageState extends State<UserOnbaordingPage> {
  final formKey = GlobalKey<ShadFormState>();

  bool isLoading = false;
  Map<int, String> orgInvites = {};

  int joinLoading = -1;

  Future<void> getOrgInvites() async {
    final data = await supabase
        .from('organization_invitations')
        .select("organization_id, organizations(name)");
    Map<int, String> invites = {};
    for (var element in data) {
      invites[element['organization_id']] = element['organizations']['name'];
    }
    setState(() {
      orgInvites.clear();
      orgInvites.addAll(invites);
    });
  }

  void joinOrg(int id) async {
    setState(() {
      joinLoading = id;
    });
    try {
      await supabase.from('organization_members').insert({
        'organization_id': id,
        'user_id': supabase.auth.currentUser!.id,
      });
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Success'),
            description: Text('Organization joined successfully'),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on PostgrestException {
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Error'),
            description: Text('An error occurred'),
          ),
        );
      }
    }
    setState(() {
      joinLoading = -1;
    });
  }

  void createOrganization() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (formKey.currentState!.value['organization_name'] != null &&
          formKey.currentState!.value['organization_name'] != "") {
        try {
          await supabase.from('organizations').insert({
            'name': formKey.currentState!.value['organization_name'],
            'bio': formKey.currentState!.value['bio'],
            'website': formKey.currentState!.value['website']
          });

          if (mounted) {
            ShadToaster.of(context).show(
              const ShadToast(
                title: Text('Success'),
                description: Text('Organization created successfully'),
              ),
            );
            Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        } on PostgrestException {
          if (mounted) {
            ShadToaster.of(context).show(
              const ShadToast.destructive(
                title: Text('Error'),
                description: Text('An error occurred'),
              ),
            );
          }
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    Session? session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).restorablePushReplacementNamed('/login');
    }
    getOrgInvites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Organization"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                  color: ShadTheme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: defaultPadding),
              ShadForm(
                key: formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    children: [
                      Text(
                        "Welcome to e-Invoice!",
                        style: ShadTheme.of(context).textTheme.h2,
                      ),
                      const SizedBox(height: defaultPadding),
                      if (orgInvites.isNotEmpty) ...[
                        ...orgInvites.entries.map(
                          (e) {
                            return Card(
                              margin: const EdgeInsets.all(2),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 2.0,
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  LucideIcons.globe,
                                ),
                                title: Text(
                                  e.value,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                trailing: ShadButton(
                                  icon: joinLoading == e.key
                                      ? const SizedBox.square(
                                          dimension: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : null,
                                  onPressed: () => joinOrg(e.key),
                                  child: const Text('Join'),
                                ),
                              ),
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding / 2),
                              child: Text(
                                "Or",
                                style: ShadTheme.of(context).textTheme.muted,
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                      Text(
                        "Create an organization to get started",
                        style: ShadTheme.of(context).textTheme.p,
                      ),
                      const SizedBox(height: defaultPadding),
                      ShadInputFormField(
                        id: 'organization_name',
                        prefix: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child:
                              ShadImage.square(size: 16, LucideIcons.building),
                        ),
                        placeholder: const Text('Organization name'),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Organization name is required";
                          }
                          return null;
                        },
                      ),
                      ShadInputFormField(
                        id: 'bio',
                        prefix: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: ShadImage.square(size: 16, LucideIcons.text),
                        ),
                        placeholder: const Text('About organization'),
                        keyboardType: TextInputType.text,
                      ),
                      ShadInputFormField(
                        id: 'website',
                        prefix: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: ShadImage.square(size: 16, LucideIcons.globe),
                        ),
                        placeholder: const Text('Organization website'),
                        keyboardType: TextInputType.text,
                        validator: (v) {
                          if (v.isNotEmpty) {
                            if (!Uri.parse(v).isAbsolute) {
                              return "Invalid URL";
                            }
                          }
                          return null;
                        },
                      ),
                      ShadButton(
                        onPressed: createOrganization,
                        icon: isLoading
                            ? const SizedBox.square(
                                dimension: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
