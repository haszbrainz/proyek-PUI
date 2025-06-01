import 'package:flutter/material.dart';

// Pastikan file-file ini ada di path yang benar dan berisi definisi
// untuk CustomColors dan CustomTextStyles.
import 'package:pui/themes/custom_colors.dart'; // Sesuaikan path jika perlu
import 'package:pui/themes/custom_text_styles.dart'; // Sesuaikan path jika perlu

// Impor LoginScreen jika berada di file terpisah
// Sesuaikan path 'login_screen.dart' jika nama file atau lokasinya berbeda
import 'login_screen.dart'; // <--- TAMBAHKAN IMPORT INI (JIKA LOGIN SCREEN DI FILE BERBEDA)
import 'package:pui/models/account_manager.dart'; // <-- tambahkan import ini

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Controllers (logika tidak diubah, hanya ditambahkan controller untuk field baru)
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Helper widget untuk membuat TextField dengan gaya yang konsisten
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool isAddressField = false,
  }) {
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
          width: 380,
          child: TextField(
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
            padding: const EdgeInsets.symmetric(horizontal:16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.secondary900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silahkan isi data diri Anda untuk mendaftar.',
                  style: TextStyle(
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
                ),
                _buildStyledTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  keyboardType: TextInputType.emailAddress,
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
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                _buildStyledTextField(
                  controller: _addressController,
                  labelText: 'Alamat Lengkap',
                  hintText: 'Masukkan alamat lengkap Anda',
                  keyboardType: TextInputType.multiline,
                  isAddressField: true,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika dummy registrasi
                      AccountManager.register(
                          _emailController.text, _passwordController.text);
                      print('Registrasi berhasil, akun dibuat');
                      // Tampilkan pop up bahwa akun sudah terbuat
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Akun sudah terbuat')));
                      // Delay sejenak agar Snackbar terlihat sebelum navigasi kembali
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(
                            context); // Navigasi kembali ke LoginScreen
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.primary500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      fixedSize: const Size(380, 48),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ).copyWith(
                      textStyle: MaterialStateProperty.all(
                        CustomTextStyles.mediumSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: const Text('Daftar'),
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
                            print(
                                'Masuk di sini ditekan dari RegistrationScreen');
                            // NAVIGASI KEMBALI KE LOGIN SCREEN
                            // Jika RegistrationScreen dibuka dengan Navigator.push(),
                            // maka Navigator.pop() akan kembali ke LoginScreen.
                            Navigator.pop(context);

                            // Alternatif jika Anda ingin memastikan navigasi ke LoginScreen
                            // dan mengganti tumpukan saat ini (jika RegistrationScreen
                            // bisa diakses dari banyak tempat dan Anda ingin kembali ke Login dengan bersih):
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => const LoginScreen()),
                            // );
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
    );
  }
}
