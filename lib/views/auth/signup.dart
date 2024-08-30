import 'package:flutter/material.dart';
import 'package:invoice/views/auth/main.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Sign Up",
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: const ShadInput(
            placeholder: Text('Email'),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        ShadInput(
          placeholder: const Text('Password'),
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
          child: const Text('Sign Up'),
          onPressed: () {},
        ),
      ],
    );
  }
}
