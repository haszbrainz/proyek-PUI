import 'package:flutter/material.dart';
import 'package:pui/themes/custom_colors.dart';
import 'package:pui/themes/custom_text_styles.dart';
import 'registration_screen.dart';
import 'package:pui/models/account_manager.dart';
import 'package:pui/views/home/home_screen.dart'; // tambahkan import HomeScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Selamat Datang Kembali',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Silahkan masuk untuk melanjutkan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 18),

              // Label Email
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              // TextField Email
              TextField(
                controller: _emailController, // <-- menggunakan controller
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email Anda',
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
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(height: 16),

              // Label Kata Sandi
              Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              // TextField Kata Sandi
              TextField(
                controller: _passwordController, // <-- menggunakan controller
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi Anda',
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
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 12.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lupa Kata Sandi
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // Aksi untuk lupa kata sandi
                    print('Lupa Kata Sandi? ditekan');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text('Lupa Kata Sandi?',
                      style: CustomTextStyles.demiBoldSm
                          .copyWith(color: CustomColors.primary500)),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logika dummy login
                    if (AccountManager.login(
                        _emailController.text, _passwordController.text)) {
                      print('Login berhasil');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    } else {
                      print(
                          'Login gagal: akun tidak ditemukan atau kredensial salah');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Email atau kata sandi salah')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primary500,
                    textStyle: CustomTextStyles.mediumSm.copyWith(
                      color: CustomColors
                          .secondary900, // Warna ini akan ditimpa oleh foregroundColor
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    fixedSize: const Size(380, 48),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0), // Menambahkan padding standar
                  ),
                  child: const Text('Masuk'),
                ),
              ),
              const Spacer(), // Mendorong konten berikutnya ke bawah

              // Tautan Buat Akun
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 20.0), // Memberi sedikit jarak dari bawah
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
                          // NAVIGASI KE REGISTRATION SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationScreen()),
                          );
                          print('Buat akun ditekan');
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
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
