import 'package:flutter/material.dart';
import 'package:pui/views/artikel/artikel_screen.dart';
import 'package:pui/views/home/home_screen.dart';
import 'package:pui/views/login/login_screen.dart';
import 'package:pui/views/login/registration_screen.dart';
import 'package:pui/views/laporkan/laporkan_screen.dart';
import './name_routes.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.login: (context) => const LoginScreen(),
    RouteNames.regis: (context) => const RegistrationScreen(), // Jika ada
    RouteNames.home: (context) => const HomeScreen(),
    RouteNames.artikel: (context) => const ArtikelScreen(),
    RouteNames.laporkan: (context) => const LaporkanScreen(), // Pastikan LaporkanScreen ada
    // RouteNames.profil: (context) => const ProfilScreen(),     // Pastikan ProfilScreen ada
    // Tambahkan pemetaan rute lain di sini
  };
}
