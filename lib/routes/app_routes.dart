import 'package:flutter/material.dart';
import 'package:pui/views/artikel/artikel_screen.dart';
import 'package:pui/views/home/home_screen.dart';
import 'package:pui/views/login/login_screen.dart';
import 'package:pui/views/login/registration_screen.dart';
import 'package:pui/views/laporkan/laporkan_screen.dart';
import 'package:pui/views/profile/profile_screen.dart';
import 'package:pui/views/profile/edit_profile_screen.dart';
import './name_routes.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.login: (context) => const LoginScreen(),
    RouteNames.regis: (context) => const RegistrationScreen(), // Jika ada
    RouteNames.home: (context) => const HomeScreen(),
    RouteNames.artikel: (context) => const ArtikelScreen(),
    RouteNames.laporkan: (context) => const LaporkanScreen(),
    RouteNames.profil: (context) => const ProfileScreen(),// Pastikan LaporkanScreen ada
    RouteNames.editprofil: (context) => const EditProfileScreen(), // Untuk halaman 'Edit Profil'
    // RouteNames.profil: (context) => const ProfilScreen(),     // Pastikan ProfilScreen ada
    // Tambahkan pemetaan rute lain di sini
  };
}
