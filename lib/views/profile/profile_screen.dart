import 'dart:convert'; // Untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Untuk HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pui/themes/custom_colors.dart'; // Sesuaikan path
import 'package:pui/themes/custom_text_styles.dart'; // Sesuaikan path
import 'package:pui/views/login/login_screen.dart'; // Sesuaikan path ke LoginScreen
import 'package:pui/widgets/navigation/bar.dart'; // Sesuaikan path ke FloatingNavigationBar

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fullName;
  String? _username; // Akan diisi dengan nama atau email dari DB
  String? _email; // Untuk menyimpan email asli jika username berbeda
  String? _phoneNumber;
  String? _address;
  // Path ke gambar dummy lokal untuk profil
  final String _localProfileImagePath = 'assets/images/user.png'; // GANTI DENGAN PATH GAMBAR DUMMY ANDA

  bool _isLoading = true;
  String _errorMessage = '';

  static const int profileTabIndex = 3; // Sesuaikan indeks untuk tab Profil
  final double _fabBottomPadding = 20.0; // Untuk menaikkan FloatingNavigationBar

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Sesi pengguna tidak ditemukan. Silakan login ulang.";
        _isLoading = false;
      });
      // Pertimbangkan navigasi ke login screen jika user ID tidak ada
      // Future.delayed(Duration(seconds: 2), () {
      //   if(mounted) Navigator.of(context).pushReplacementNamed(RouteNames.login); // Asumsi Anda punya RouteNames.login
      // });
      return;
    }

    // GANTI URL INI DENGAN URL BACKEND ANDA YANG SESUAI
    final String apiUrl = 'https://broadly-neutral-osprey.ngrok-free.app/api/users/$userId'; // Untuk emulator Android
    // final String apiUrl = 'http://localhost:3000/api/users/$userId'; // Jika Flutter web & backend di PC sama
    // final String apiUrl = 'http://ALAMAT_IP_PC_ANDA:3000/api/users/$userId'; // Untuk perangkat fisik

    try {
      print("Fetching user data from: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));

      if (!mounted) return;

      print('Profile Response status: ${response.statusCode}');
      print('Profile Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          setState(() {
            _fullName = userData['name'];
            // Untuk Username, kita bisa gunakan nama atau email. Desain Anda menampilkan "Andi".
            // Jika ada field username khusus di backend, gunakan itu.
            // Jika tidak, kita bisa gunakan 'name' atau 'email'.
            _username = userData['name'] ?? userData['email']; // Prioritaskan nama, fallback ke email
            _email = userData['email']; // Simpan email asli
            _address = userData['alamatLengkap'];
            // Untuk nomor telepon, jika ada di data user dari backend:
            // _phoneNumber = userData['nomorTelepon'] ?? "+62 812 3456 7890 (Contoh)";
            // Jika tidak, gunakan placeholder atau data dari SharedPreferences jika disimpan terpisah
            _phoneNumber = prefs.getString('user_phone') ?? "+62 823910827 (Contoh)"; // Placeholder
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['error'] ?? "Gagal memuat data profil.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Gagal terhubung ke server (Status: ${response.statusCode}).";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error memuat data user: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = "Terjadi kesalahan: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_address');
    // Hapus juga user_profile_image_url jika Anda menyimpannya
    // await prefs.remove('user_profile_image_url');


    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildInfoField({
    required String label,
    required String? value,
    IconData? trailingIcon,
    Color? iconColor,
    bool isMultiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CustomTextStyles.mediumBase.copyWith(color: CustomColors.secondary500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: CustomColors.tertiary100, // Warna latar field sedikit lebih terang dari putih
            border: Border.all(color: CustomColors.secondary100.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(12), // Lebih rounded
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null || value.isEmpty ? 'Belum diatur' : value,
                  style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary900),
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: iconColor ?? Colors.green, size: 20),
              ]
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fabBottomPadding = _fabBottomPadding;
    final double navigationBarHeightEstimate = 70.0;
    final double bottomNavBarClearance = navigationBarHeightEstimate + fabBottomPadding + MediaQuery.of(context).padding.bottom + 16;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya', style: CustomTextStyles.boldLg.copyWith(color: CustomColors.tertiary50)),
        backgroundColor: CustomColors.primary500, // Warna ungu dari desain
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary500),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          onPressed: _loadUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primary500,
                            foregroundColor: CustomColors.tertiary50
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(24.0, 30.0, 24.0, bottomNavBarClearance), // Padding atas ditambah
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: CustomColors.secondary100,
                              // Menggunakan gambar dummy dari aset lokal
                              backgroundImage: AssetImage(_localProfileImagePath),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: CustomColors.primary500, // Warna ungu
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5)
                              ),
                              child: InkWell(
                                onTap: () {
                                  // TODO: Implementasi ganti foto profil
                                  print('Edit foto profil ditekan');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Fitur ganti foto belum tersedia.'))
                                  );
                                },
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(7.0), // Padding untuk ikon
                                  child: Icon(
                                    Icons.edit, // Ikon pensil
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30), // Spasi lebih besar
                        _buildInfoField(
                          label: "Nama lengkap",
                          value: _fullName,
                        ),
                        _buildInfoField(
                          label: "Username",
                          value: _username, // Menampilkan nama atau email
                          trailingIcon: Icons.check_circle_outline, // Ikon centang sesuai desain
                          iconColor: CustomColors.primary500, // Warna centang ungu
                        ),
                        _buildInfoField(
                          label: "Nomor telepon",
                          value: _phoneNumber,
                        ),
                        _buildInfoField(
                          label: "Alamat (opsional)",
                          value: _address,
                          isMultiline: true,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: Icon(Icons.power_settings_new, color: Colors.red),
                          label: Text(
                            'Keluar akun',
                            style: CustomTextStyles.boldSm.copyWith(color: Colors.red),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.8), // Warna lebih solid
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: Text('Konfirmasi Keluar', style: CustomTextStyles.boldLg.copyWith(color: CustomColors.primary900)),
                                  content: Text('Apakah Anda yakin ingin keluar dari akun ini?', style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary500)),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Batal', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.secondary400)),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Keluar', style: CustomTextStyles.mediumSm.copyWith(color: Colors.red)),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        _logoutUser();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabBottomPadding),
        child: const FloatingNavigationBar(
          initialIndex: profileTabIndex,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}