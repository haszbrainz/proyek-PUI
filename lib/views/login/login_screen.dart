import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Impor paket http
import 'package:shared_preferences/shared_preferences.dart'; // Impor shared_preferences

import 'package:pui/themes/custom_colors.dart';
import 'package:pui/themes/custom_text_styles.dart';
import 'registration_screen.dart';
import 'package:pui/views/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false; // State untuk loading
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // GlobalKey untuk Form

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK LOGIN KE BACKEND ---
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) { // Validasi form
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Sesuaikan URL API Anda
    const String apiUrl = 'https://broadly-neutral-osprey.ngrok-free.app/api/users/login'; // Untuk emulator Android
    // const String apiUrl = 'http://localhost:3000/api/users/login'; // Jika Flutter web & backend di mesin sama

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Login berhasil
        final String token = responseData['data']['token'];
        final Map<String, dynamic> userData = responseData['data']['user'];

        // Simpan token dan data user (misalnya user ID dan nama) ke SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setInt('user_id', userData['id']); // Simpan ID user
        await prefs.setString('user_name', userData['name'] ?? 'Pengguna'); // Simpan nama user
        await prefs.setString('user_email', userData['email']);
        // Anda bisa menyimpan data user lain jika perlu

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Login berhasil!'), backgroundColor: Colors.green),
        );

        // Navigasi ke HomeScreen dan hapus semua route sebelumnya (agar tidak bisa kembali ke login)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false, // Hapus semua route sebelumnya
        );
      } else {
        // Login gagal dari backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? 'Login gagal. Email atau password salah.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Error jaringan atau lainnya
      print('Error saat login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // --- AKHIR FUNGSI LOGIN ---

  // Helper widget untuk membuat TextFormField dengan gaya yang konsisten
  Widget _buildStyledTextFormField({ // Diubah menjadi TextFormField
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator, // Tambah validator
  }) {
    const double textFieldTextHeight = 16.0; // Sesuaikan jika perlu
    const double targetHeight = 48.0; // Sesuaikan jika perlu
    const double verticalPadding = (targetHeight - textFieldTextHeight) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle( // Menggunakan TextStyle langsung karena tidak ada di CustomTextStyles Anda
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800], // Sesuai kode asli Anda
          ),
        ),
        const SizedBox(height: 8), // Mengurangi dari 12 ke 8 agar lebih rapat
        TextFormField( // Menggunakan TextFormField
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: CustomTextStyles.regularSm
              .copyWith(color: CustomColors.secondary900), // Warna teks input
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: CustomTextStyles.regularSm
                .copyWith(color: CustomColors.secondary200),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1.5), // Border lebih tebal saat fokus
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0, horizontal: 12.0), // Padding internal field
            isDense: true, // Membuat field lebih kompak
            suffixIcon: suffixIcon,
          ),
          validator: validator, // Hubungkan validator
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Tambahkan SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding keseluruhan
            child: Form( // Bungkus Column dengan Form
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten jika sedikit
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Spasi dari atas
                  const Text(
                    'Selamat Datang Kembali',
                    style: TextStyle( // Bisa juga dari CustomTextStyles
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // atau CustomColors.secondary900
                    ),
                  ),
                  const SizedBox(height: 8), // Mengurangi dari 12
                  Text(
                    'Silahkan masuk untuk melanjutkan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700], // atau CustomColors.secondary400
                    ),
                  ),
                  const SizedBox(height: 32), // Spasi lebih besar sebelum field
                  _buildStyledTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return 'Masukkan format email yang valid';
                      }
                      return null;
                    },
                  ),
                  _buildStyledTextFormField(
                    controller: _passwordController,
                    labelText: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi Anda',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600], // atau CustomColors.secondary300
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  Align( // Lupa Kata Sandi ke kiri
                    alignment: Alignment.centerLeft, // Sudah default untuk Column, tapi eksplisit
                    child: TextButton(
                      onPressed: () {
                        print('Lupa Kata Sandi? ditekan');
                        // TODO: Implementasi Lupa Kata Sandi
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // Hapus padding default
                        minimumSize: const Size(50, 30), // Ukuran minimal agar mudah ditekan
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Area tap pas dengan konten
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text('Lupa Kata Sandi?',
                          style: CustomTextStyles.demiBoldSm
                              .copyWith(color: CustomColors.primary500)),
                    ),
                  ),
                  const SizedBox(height: 12), // Spasi sebelum tombol Masuk
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginUser, // Panggil _loginUser
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primary500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Border radius disamakan
                        ),
                        fixedSize: const Size(double.infinity, 50), // Tinggi tombol
                        textStyle: CustomTextStyles.mediumSm.copyWith(fontWeight: FontWeight.bold),
                      ),
                      child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Masuk'),
                    ),
                  ),
                  const SizedBox(height: 16), // Spasi sebelum "Belum punya akun?"
                  Align( // Pusatkan baris "Belum punya akun?"
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center,
                          ),
                          child: Text(
                            'Buat akun',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor, // Gunakan primaryColor dari tema
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                   SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Spasi dari bawah
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}