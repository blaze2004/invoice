import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:invoice/proivder/organization.dart';
import 'package:invoice/splash_page.dart';
import 'package:invoice/views/auth/onboarding.dart';
import 'package:invoice/views/auth/signin.dart';
import 'package:invoice/views/auth/signup.dart';
import 'package:invoice/views/dashboard/main.dart';
import 'package:invoice/views/invoice/new.dart';
import 'package:invoice/views/templates/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<void> main() async {
  usePathUrlStrategy();
  late String supabaseUrl;
  late String supabaseAnonKey;
  if (const bool.hasEnvironment("SUPABASE_URL") &&
      const bool.hasEnvironment("SUPABASE_ANON_KEY")) {
    supabaseUrl = const String.fromEnvironment("SUPABASE_URL");
    supabaseAnonKey = const String.fromEnvironment("SUPABASE_ANON_KEY");
  } else {
    await dotenv.load(fileName: ".env");
    supabaseUrl = dotenv.env["SUPABASE_URL"]!;
    supabaseAnonKey = dotenv.env["SUPABASE_ANON_KEY"]!;
  }
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => OrganizationProvider(),
      child: const InvoiceApp(),
    ),
  );
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
        // '/invoice': (_) => const InvoicePage(),
        '/login': (_) => const SignInPage(),
        '/signup': (_) => const SignUpPage(),
        '/onboarding': (_) => const UserOnbaordingPage(),
        '/dashboard': (_) => const Dashboard(),
        '/templates': (_) => const InvoiceTemplatesListPage(),
        '/new-invoice': (_) => const NewInvoicePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
