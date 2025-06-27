import 'dart:convert'; // Untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Untuk HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pui/themes/custom_colors.dart'; // Sesuaikan path
import 'package:pui/themes/custom_text_styles.dart'; // Sesuaikan path
import 'package:pui/views/login/login_screen.dart'; // Sesuaikan path ke LoginScreen (diganti dari login/login_screen.dart)
import 'package:pui/widgets/navigation/bar.dart'; // Sesuaikan path ke FloatingNavigationBar

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fullName;
  String? _email;
  String? _address;
  // Variabel _username dan _phoneNumber dihapus karena tidak lagi ditampilkan

  final String _localProfileImagePath =
      'assets/images/user.png'; // PASTIKAN PATH INI BENAR

  bool _isLoading = true;
  String _errorMessage = '';

  static const int profileTabIndex = 3; // Sesuaikan indeks untuk tab Profil
  // _fabBottomPadding tetap digunakan jika Anda ingin FloatingNavigationBar dinaikkan
  final double _fabBottomPadding = 20.0;

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
      return;
    }

    // GANTI URL INI DENGAN URL BACKEND ANDA YANG SESUAI
    final String apiUrl =
        'https://broadly-neutral-osprey.ngrok-free.app/api/users/$userId';

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
            _email = userData['email'];
            _address = userData['alamatLengkap'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                responseData['error'] ?? "Gagal memuat data profil.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Gagal terhubung ke server (Status: ${response.statusCode}).";
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
    await prefs.clear();

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
    bool isMultiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CustomTextStyles.mediumBase
              .copyWith(color: CustomColors.secondary500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: CustomColors.tertiary100,
            border:
                Border.all(color: CustomColors.secondary100.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value == null || value.isEmpty ? 'Belum diatur' : value,
            style: CustomTextStyles.regularBase
                .copyWith(color: CustomColors.secondary900),
            maxLines:
                isMultiline ? 3 : 1, // Alamat bisa sampai 3 baris, lainnya 1
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Padding bawah untuk konten scrollable agar tidak tertutup FloatingNavigationBar
    // (Tinggi NavBar + Padding Bawah NavBar dari Scaffold + Padding Tambahan Anda)
    final double bottomContentPadding = (70.0) +
        (_fabBottomPadding) +
        (MediaQuery.of(context).padding.bottom) +
        (16.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya',
            style: CustomTextStyles.boldLg
                .copyWith(color: CustomColors.tertiary50)),
        backgroundColor: CustomColors.primary500, // Warna AppBar
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      backgroundColor: Colors.white, // Warna latar utama layar
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
                          style: CustomTextStyles.regularBase
                              .copyWith(color: CustomColors.secondary500),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          onPressed: _loadUserData,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.primary500,
                              foregroundColor: CustomColors.tertiary50),
                        )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    // --- PADDING UTAMA DIATUR MENJADI 16.0 SECARA HORIZONTAL ---
                    padding: EdgeInsets.fromLTRB(
                        16.0, // Padding kiri 16px
                        24.0, // Padding atas 24px
                        16.0, // Padding kanan 16px
                        bottomContentPadding // Padding bawah untuk ruang FloatingNavBar
                        ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: CustomColors.secondary100,
                              backgroundImage:
                                  AssetImage(_localProfileImagePath),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: CustomColors
                                      .primary500, // Warna ikon edit
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.5)),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      '/edit-profil'); // Ganti dengan rute yang sesuai
                                  // TODO: Implementasi ganti foto profil
                                  print('Edit foto profil ditekan');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Fitur ganti foto belum tersedia.')));
                                },
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(7.0),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- HANYA MENAMPILKAN NAMA, EMAIL, DAN ALAMAT ---
                        _buildInfoField(
                          label: "Nama lengkap",
                          value: _fullName,
                        ),
                        _buildInfoField(
                          label: "Email",
                          value: _email,
                        ),
                        _buildInfoField(
                          label:
                              "Alamat", // "(opsional)" bisa ditambahkan di sini jika field alamat di DB memang opsional
                          value: _address,
                          isMultiline: true,
                        ),
                        // Field Username dan Nomor Telepon sudah dihapus dari sini

                        const SizedBox(
                            height: 30), // Spasi sebelum tombol keluar
                        ElevatedButton.icon(
                          icon: Icon(Icons.power_settings_new,
                              color: CustomColors
                                  .tertiary50), // Ikon putih agar kontras dengan bg merah
                          label: Text(
                            'Keluar akun',
                            style: CustomTextStyles.boldSm.copyWith(
                                color: CustomColors.tertiary50), // Teks putih
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // Warna latar tombol merah
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
                                  title: Text('Konfirmasi Keluar',
                                      style: CustomTextStyles.boldLg.copyWith(
                                          color: CustomColors.primary900)),
                                  content: Text(
                                      'Apakah Anda yakin ingin keluar dari akun ini?',
                                      style: CustomTextStyles.regularBase
                                          .copyWith(
                                              color:
                                                  CustomColors.secondary500)),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Batal',
                                          style: CustomTextStyles.mediumSm
                                              .copyWith(
                                                  color: CustomColors
                                                      .secondary400)),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Keluar',
                                          style: CustomTextStyles.mediumSm
                                              .copyWith(color: Colors.red)),
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
      // --- FloatingNavigationBar tetap di slot floatingActionButton ---
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: _fabBottomPadding), // Untuk menaikkan posisi NavBar
        child: const FloatingNavigationBar(
          initialIndex:
              profileTabIndex, // Pastikan indeks ini benar untuk tab Profil
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
