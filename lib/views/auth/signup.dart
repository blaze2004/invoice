import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoice/constants/constants.dart';
import 'package:invoice/main.dart';
import 'package:invoice/views/auth/layout.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<ShadFormState>();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void signUp() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if ((formKey.currentState!.value['organization_name'] != null &&
              formKey.currentState!.value['organization_name'] != "") ||
          (formKey.currentState!.value['organization_code'] != null &&
              formKey.currentState!.value['organization_code'] != "")) {
        try {
          String? organizationId;
          if (formKey.currentState!.value['organization_code'] != null &&
              formKey.currentState!.value['organization_code'] != "") {
            organizationId = await isOrganizationIdPresent(
                formKey.currentState!.value['organization_code']);

            if (organizationId == null) {
              if (mounted) {
                ShadToaster.of(context).show(
                  const ShadToast.destructive(
                    title: Text('Invalid organization code'),
                    description: Text('Wrong code'),
                  ),
                );
                setState(() {
                  isLoading = false;
                });
              }
              return;
            }
          }

          final AuthResponse res = await supabase.auth.signUp(
            email: formKey.currentState!.value['email'],
            password: formKey.currentState!.value['password'],
            emailRedirectTo:
                kIsWeb ? null : 'io.supabase.invoice://login-callback/',
            data: {
              'full_name': formKey.currentState!.value['full_name'],
              'organization_name':
                  formKey.currentState!.value['organization_name'],
              'organization_id': organizationId ?? '',
            },
          );

          if (res.user != null) {
            if (mounted) {
              ShadToaster.of(context).show(
                const ShadToast(
                  title: Text('Please verify your email.'),
                  description:
                      Text('Check your email for a verification link.'),
                ),
              );
            }
          } else {
            if (mounted) {
              ShadToaster.of(context).show(
                const ShadToast.destructive(
                  title: Text('Sign up failed'),
                  description: Text('Please try again.'),
                ),
              );
            }
          }
        } on AuthException catch (e) {
          if (mounted) {
            ShadToaster.of(context).show(
              ShadToast.destructive(
                title: const Text("Sign up failed"),
                description: Text(e.message),
              ),
            );
          }
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Organization name or code is required'),
            description: Text('Please enter organization name or code.'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String?> isOrganizationIdPresent(String organizationId) async {
    try {
      final response = await supabase
          .from('organizations')
          .select('slug, organization_id')
          .eq('slug', organizationId)
          .maybeSingle();

      return response?['organization_id'];
    } catch (e) {
      log('Error checking organization code: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Sign Up",
      child: ShadForm(
        key: formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              ShadInputFormField(
                id: 'full_name',
                placeholder: const Text('Name'),
                validator: (v) {
                  if (v.length < 2) {
                    return 'Name must be at least 2 characters.';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              ShadInputFormField(
                id: 'email',
                prefix: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ShadImage.square(size: 16, LucideIcons.mail),
                ),
                placeholder: const Text('Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              ShadInputFormField(
                id: 'password',
                placeholder: const Text('Password'),
                obscureText: obscurePassword,
                validator: (v) {
                  if (v.length < 8) {
                    return 'Password must be at least 8 characters.';
                  }
                  if (!RegExp(r'\d').hasMatch(v)) {
                    return 'Password must contain at least one digit.';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(v)) {
                    return 'Password must contain at least one uppercase letter.';
                  }
                  if (!RegExp(r'[a-z]').hasMatch(v)) {
                    return 'Password must contain at least one lowercase letter.';
                  }
                  return null;
                },
                prefix: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ShadImage.square(size: 16, LucideIcons.lock),
                ),
                suffix: ShadButton(
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.zero,
                  decoration: const ShadDecoration(
                    secondaryBorder: ShadBorder.none,
                    secondaryFocusedBorder: ShadBorder.none,
                  ),
                  icon: ShadImage.square(
                    size: 16,
                    obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                ),
              ),
              ShadInputFormField(
                id: 'confirmPassword',
                placeholder: const Text('Confirm Password'),
                validator: (p0) {
                  final p1 = formKey.currentState!.value['password'];
                  if (p0 != p1) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
                obscureText: obscureConfirmPassword,
                prefix: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ShadImage.square(size: 16, LucideIcons.lock),
                ),
                suffix: ShadButton(
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.zero,
                  decoration: const ShadDecoration(
                    secondaryBorder: ShadBorder.none,
                    secondaryFocusedBorder: ShadBorder.none,
                  ),
                  icon: ShadImage.square(
                    size: 16,
                    obscureConfirmPassword
                        ? LucideIcons.eyeOff
                        : LucideIcons.eye,
                  ),
                  onPressed: () {
                    setState(
                        () => obscureConfirmPassword = !obscureConfirmPassword);
                  },
                ),
              ),
              ShadInputFormField(
                id: 'organization_name',
                prefix: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ShadImage.square(size: 16, LucideIcons.building),
                ),
                placeholder: const Text('Organization Name'),
                keyboardType: TextInputType.text,
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
              ShadInputFormField(
                id: 'organization_code',
                prefix: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ShadImage.square(size: 16, LucideIcons.building),
                ),
                placeholder: const Text('Organization Code'),
                keyboardType: TextInputType.text,
              ),
              ShadButton(
                onPressed: signUp,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                child: const Text('Sign Up'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                  ShadButton.link(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: const Text('Sign In'),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
