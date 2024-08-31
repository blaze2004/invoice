import 'package:flutter/material.dart';
import 'package:invoice/main.dart';
import 'package:invoice/views/auth/layout.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:email_validator/email_validator.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formKey = GlobalKey<ShadFormState>();

  bool obscurePassword = true;
  bool isLoading = false;

  void signIn() async {
    setState(() => isLoading = true);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: formKey.currentState!.value['email'],
          password: formKey.currentState!.value['password'],
        );

        if (res.user != null) {
          if (mounted) {
            ShadToaster.of(context).show(
              const ShadToast(
                title: Text('Welcome back!'),
              ),
            );
          }
        } else {
          if (mounted) {
            ShadToaster.of(context).show(
              const ShadToast.destructive(
                title: Text('Login failed'),
                description: Text('Please try again.'),
              ),
            );
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text("Login failed"),
              description: Text(e.message),
            ),
          );
        }
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Sign In",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ShadForm(
          key: formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                ShadInputFormField(
                  id: 'email',
                  prefix: const Padding(
                    padding: EdgeInsets.all(9),
                    child: ShadImage.square(size: 20, LucideIcons.mail),
                  ),
                  placeholder: const Text('Email'),
                  validator: (v) {
                    if (!EmailValidator.validate(v)) {
                      return 'Invalid Email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                ShadInputFormField(
                  id: 'password',
                  placeholder: const Text('Password'),
                  validator: (v) {
                    if (v.length < 8) {
                      return 'Invalid Password';
                    }
                    return null;
                  },
                  obscureText: obscurePassword,
                  prefix: const Padding(
                    padding: EdgeInsets.all(5),
                    child: ShadImage.square(size: 20, LucideIcons.lock),
                  ),
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed: signIn,
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                    ShadButton.link(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const Text('Sign Up'),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
