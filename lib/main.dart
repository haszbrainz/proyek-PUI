import 'package:flutter/material.dart';
import 'package:pui/routes/app_routes.dart';
import 'themes/main_theme.dart';
import 'routes/app_routes.dart';
import 'routes/name_routes.dart';


void main() {
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.themeData,
      initialRoute: RouteNames.login,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
