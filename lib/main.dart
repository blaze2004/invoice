import 'package:flutter/material.dart';
import 'package:invoice/invoice_page.dart';
import 'package:invoice/splash_page.dart';
import 'package:invoice/views/auth/signin.dart';
import 'package:invoice/views/auth/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<void> main() async {
  usePathUrlStrategy();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const InvoiceApp());
}

final supabase = Supabase.instance.client;

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      title: 'e-Invoice',
      darkTheme: ShadThemeData(
          colorScheme: const ShadBlueColorScheme.dark(),
          brightness: Brightness.dark),
      theme: ShadThemeData(
        colorScheme: const ShadBlueColorScheme.light(),
        brightness: Brightness.light,
      ),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/invoice': (_) => const InvoicePage(),
        '/login': (_) => const SignInPage(),
        '/signup': (_) => const SignUpPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
