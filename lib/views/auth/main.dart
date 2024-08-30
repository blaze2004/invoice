import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.children,
    this.title = "Auth",
  });

  final List<Widget> children;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  title,
                  style: ShadTheme.of(context).textTheme.h2,
                ),
              ),
              ...children
            ],
          ),
        ),
      ),
    );
  }
}
