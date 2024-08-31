import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invoice/constants/constants.dart';
import 'package:invoice/main.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLayout extends StatefulWidget {
  const AuthLayout({
    super.key,
    required this.child,
    this.title = "Auth",
  });

  final Widget child;
  final String title;

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _redirecting = false;

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        if (mounted) {
          Navigator.of(context).pushNamed('/dashboard');
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
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
                // Center(
                //   child: Text(
                //     title,
                //     style: ShadTheme.of(context).textTheme.h2,
                //   ),
                // ),
                const SizedBox(height: defaultPadding),
                widget.child
              ],
            ),
          ),
        ),
      ),
    );
  }
}
