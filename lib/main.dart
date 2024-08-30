import 'package:flutter/material.dart';
import 'package:invoice/invoice_page.dart';
import 'package:invoice/login_page.dart';
import 'package:invoice/screens/first_login_signup.dart';
import 'package:invoice/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

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
    return MaterialApp(
      title: 'e-Invoice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const FirstLoginSignup(),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/invoice': (_) => const InvoicePage(),
        '/login': (_) => const FirstLoginSignup(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
