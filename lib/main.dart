import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'package:poty_ia_app/data/services/prefs.dart';
import 'package:poty_ia_app/routes/app_pages.dart';
import 'package:poty_ia_app/routes/app_routes.dart';
import 'package:poty_ia_app/ui/core/themes/app_themes.dart';

Future<String> getInitialRoute() async {
  final token = await Prefs.getString('accessToken');

  return token != null && token.isNotEmpty
      ? AppRoutes.home
      : AppRoutes.login;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initialRoute = await getInitialRoute();

  runApp(
    MyApp(initialRoute: initialRoute),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poty IA',

      initialRoute: initialRoute,
      getPages: AppPages.pages,

      theme: AppTheme.main,

      locale: const Locale('pt', 'BR'),
      fallbackLocale: const Locale('pt', 'BR'),

      localizationsDelegates:
      GlobalMaterialLocalizations.delegates,

      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}