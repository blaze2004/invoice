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
    if (!mounted) {
      return;
    }

    setState(() => isLoading = true);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: formKey.currentState!.value['email'],
          password: formKey.currentState!.value['password'],
        );

        if (res.user != null) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Welcome back!'),
            ),
          );
        } else {
          ShadToaster.of(context).show(
            const ShadToast.destructive(
              title: Text('Login failed'),
              description: Text('Please try again.'),
            ),
          );
        }
      } on AuthException catch (e) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text("Login failed"),
            description: Text(e.message),
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Sign In",
      child: ShadForm(
        key: formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              ShadInputFormField(
                id: 'email',
                prefix: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ShadImage.square(size: 16, LucideIcons.mail),
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
              ShadButton(
                onPressed: signIn,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                child: const Text('Sign In'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                  ShadButton.link(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: const Text('Sign Up'),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/signup');
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
