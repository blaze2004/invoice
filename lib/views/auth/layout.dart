import 'package:flutter/material.dart';
import 'package:invoice/constants/constants.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
    this.title = "Auth",
  });

  final Widget child;
  final String title;

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
                child
              ],
            ),
          ),
        ),
      ),
    );
  }
}
