import 'package:flutter/material.dart';
import 'package:pui/themes/custom_icons.dart';
import 'item.dart';
import 'package:pui/themes/custom_colors.dart';

class FloatingNavigationBar extends StatefulWidget {
  final int initialIndex;

  const FloatingNavigationBar({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<FloatingNavigationBar> createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar> {
  late int _selectedIndex;

  // Daftar item navigasi Anda (pastikan rute konsisten dengan RouteNames)
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': Stylomateicon.home,
      'label': 'Beranda',
      'route': '/', // Atau RouteNames.home
    },
    {
      'icon': Stylomateicon.magic,
      'label': 'Artikel',
      'route': '/artikel', // Atau RouteNames.artikel
    },
    {
      'icon': Stylomateicon.camera,
      'label': 'Laporkan',
      'route': '/laporkan', // Atau RouteNames.laporkan (sesuaikan dengan RouteNames)
    },
    {
      'icon': Stylomateicon.account,
      'label': 'Profil',
      'route': '/profile', // Atau RouteNames.profil
    },
  ];

   @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final String? currentRoute = ModalRoute.of(context)?.settings.name;
        // Jika currentRoute null (mungkin halaman awal sebelum rute bernama terdefinisi penuh),
        // fallback ke rute item pertama jika initialIndex juga 0.
        // Atau, gunakan initialIndex untuk menentukan rute awal jika currentRoute null.
        final String routeToUse = currentRoute ?? ( (widget.initialIndex < _navigationItems.length) ? _navigationItems[widget.initialIndex]['route'] as String : '/' );
        updateSelectedIndexByRoute(routeToUse);
      }
    });
  }

  void updateSelectedIndexByRoute(String route) {
    for (int i = 0; i < _navigationItems.length; i++) {
      if (_navigationItems[i]['route'] == route) {
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i;
          });
        }
        break;
      }
    }
  }

  void _onItemTapped(int index) {
    final String tappedRoute = _navigationItems[index]['route'] as String;
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute != tappedRoute) {
      Navigator.pushReplacementNamed(context, tappedRoute);
    } else {
      if (_selectedIndex != index) {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- KEMBALIKAN KE BUILD METHOD ASLI ANDA YANG MENGGUNAKAN POSITIONED ---
    return Positioned(
      bottom: 4,
      left: 0,
      right: 0,
      child: Center(
        child: IntrinsicWidth(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: CustomColors.secondary500, // Gunakan CustomColors Anda
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max, // Sesuai kode asli Anda
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _navigationItems.length,
                  (index) => NavigationItem( // Pastikan NavigationItem terdefinisi dengan benar
                    icon: _navigationItems[index]['icon'] as IconData,
                    label: _navigationItems[index]['label'] as String,
                    isActive: index == _selectedIndex,
                    onTap: () => _onItemTapped(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // --- AKHIR BUILD METHOD ASLI ---
  }
}
