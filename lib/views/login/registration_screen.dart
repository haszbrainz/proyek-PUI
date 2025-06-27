import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Impor paket http

// Pastikan file-file ini ada di path yang benar dan berisi definisi
// untuk CustomColors dan CustomTextStyles.
import 'package:pui/themes/custom_colors.dart'; // Sesuaikan path jika perlu
import 'package:pui/themes/custom_text_styles.dart'; // Sesuaikan path jika perlu

// Impor LoginScreen jika berada di file terpisah
// Sesuaikan path 'login_screen.dart' jika nama file atau lokasinya berbeda
import 'login_screen.dart';
// import 'package:pui/models/account_manager.dart'; // Ini tidak kita gunakan lagi untuk registrasi ke backend

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // State untuk loading indicator

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // GlobalKey untuk Form (opsional, tapi bagus untuk validasi)
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK REGISTRASI KE BACKEND ---
  Future<void> _registerUser() async {
    // Validasi sederhana (Anda bisa menambahkan validasi lebih detail)
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Konfirmasi kata sandi tidak cocok!'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _fullNameController.text.isEmpty || // Asumsi nama lengkap wajib
        _addressController.text.isEmpty) {
      // Asumsi alamat wajib
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mohon isi semua field yang wajib!'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Tampilkan loading indicator
    });

    // URL endpoint backend Anda (sesuaikan jika berbeda)
    // Jika menjalankan backend di PC yang sama dengan emulator Android, gunakan 10.0.2.2
    // Jika menjalankan di PC yang sama dengan web atau physical device di jaringan sama, gunakan IP lokal PC Anda (misal, 192.168.1.X)
    const String apiUrl =
        'https://broadly-neutral-osprey.ngrok-free.app/api/users/register'; // Untuk emulator Android
    // const String apiUrl = 'http://localhost:3000/api/users/register'; // Jika Flutter web & backend di mesin sama

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          'email': _emailController.text,
          'password': _passwordController.text,
          'name': _fullNameController.text,
          'alamatLengkap': _addressController.text,
          'role': 'USER', // Atau biarkan backend yang menentukan default role
        }),
      );

      if (!mounted) return; // Cek jika widget masih ada di tree

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        // Registrasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ?? 'Akun berhasil dibuat!'),
              backgroundColor: Colors.green),
        );
        // Delay sejenak agar Snackbar terlihat sebelum navigasi kembali
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context); // Navigasi kembali ke LoginScreen
          }
        });
      } else {
        // Registrasi gagal dari backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['error'] ??
                  'Registrasi gagal. Silakan coba lagi.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Error jaringan atau lainnya
      print('Error saat registrasi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Terjadi kesalahan: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Sembunyikan loading indicator
        });
      }
    }
  }
  // --- AKHIR FUNGSI REGISTRASI ---

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool isAddressField = false,
    String? Function(String?)? validator, // Tambah validator
  }) {
    // ... (kode _buildStyledTextField tetap sama, tambahkan validator jika menggunakan Form)
    const double textFieldTextHeight = 16.0;
    const double targetHeight = 48.0;
    const double verticalPadding = (targetHeight - textFieldTextHeight) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CustomColors.secondary900,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width:
              380, // Pertimbangkan untuk menggunakan MediaQuery untuk lebar responsif
          child: TextFormField(
            // Ganti TextField menjadi TextFormField untuk validasi
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: isAddressField ? null : 1,
            minLines: isAddressField ? 3 : 1,
            style: CustomTextStyles.regularSm
                .copyWith(color: CustomColors.secondary900),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: CustomTextStyles.regularSm
                  .copyWith(color: CustomColors.secondary200),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                    color: CustomColors.secondary200.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                    color: CustomColors.secondary200.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(
                    color: CustomColors.primary500, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: isAddressField ? 14.0 : verticalPadding,
                horizontal: 12.0,
              ),
              isDense: true,
              suffixIcon: suffixIcon,
            ),
            validator: validator, // Gunakan validator
          ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 20.0), // Padding disesuaikan
            child: Form(
              // Bungkus dengan Form widget
              key: _formKey, // Gunakan GlobalKey untuk Form
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      // Bisa juga CustomTextStyles
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.secondary900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Silahkan isi data diri Anda untuk mendaftar.',
                    style: TextStyle(
                      // Bisa juga CustomTextStyles
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStyledTextField(
                    controller: _fullNameController,
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap Anda',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Masukkan format email yang valid';
                      }
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    controller: _passwordController,
                    labelText: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi Anda',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: CustomColors.secondary200,
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
                      if (value.length < 6) {
                        // Contoh validasi panjang password
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Konfirmasi Kata Sandi',
                    hintText: 'Masukkan kembali kata sandi Anda',
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: CustomColors.secondary200,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi kata sandi tidak boleh kosong';
                      }
                      if (value != _passwordController.text) {
                        return 'Konfirmasi kata sandi tidak cocok';
                      }
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    controller: _addressController,
                    labelText: 'Alamat Lengkap',
                    hintText: 'Masukkan alamat lengkap Anda',
                    keyboardType: TextInputType.multiline,
                    isAddressField: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    // SizedBox untuk spasi sebelum tombol
                    height: 24,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              // Disable tombol saat loading
                              if (_formKey.currentState!.validate()) {
                                // Panggil validasi form
                                _registerUser();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primary500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        fixedSize: const Size(380,
                            48), // Lebar disesuaikan dengan _buildStyledTextField atau gunakan MediaQuery
                        padding: const EdgeInsets.symmetric(vertical: 0),
                      ).copyWith(
                        // textStyle diset dengan benar
                        textStyle: MaterialStateProperty.all(
                          CustomTextStyles.mediumSm.copyWith(
                            fontWeight: FontWeight.bold,
                            // color: Colors.white, // Warna sudah diatur oleh foregroundColor
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.white))
                          : const Text('Daftar'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.center,
                            ),
                            child: Text(
                              'Masuk di sini',
                              style: TextStyle(
                                color: CustomColors.primary500,
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
        ),
      ),
    );
  }
}
