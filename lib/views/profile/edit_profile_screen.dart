import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Untuk HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pui/themes/custom_colors.dart'; // Sesuaikan path
import 'package:pui/themes/custom_text_styles.dart'; // Sesuaikan path

class EditProfileScreen extends StatefulWidget {
  // Anda bisa menerima data user awal dari ProfileScreen untuk menghindari fetch ulang
  // final String initialName;
  // final String initialAddress;
  // final int userId; // Jika user ID juga dioper

  // const EditProfileScreen({
  //   super.key,
  //   required this.initialName,
  //   required this.initialAddress,
  //   required this.userId,
  // });
  const EditProfileScreen({super.key});


  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Untuk loading saat fetch data awal
  bool _isSaving = false;  // Untuk loading saat simpan perubahan
  String _errorMessage = '';
  int? _userId; // Untuk menyimpan User ID

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _loadCurrentUserData(); // Panggil fungsi untuk memuat data user saat ini
  }

  Future<void> _loadCurrentUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');

    if (_userId == null) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Sesi pengguna tidak ditemukan. Silakan login ulang.";
        _isLoading = false;
      });
      return;
    }

    // Jika Anda mengoper data dari ProfileScreen, Anda bisa gunakan itu:
    // _nameController.text = widget.initialName;
    // _addressController.text = widget.initialAddress;
    // setState(() { _isLoading = false; });
    // return;

    // Jika tidak, fetch dari API
    final String apiUrl = 'https://broadly-neutral-osprey.ngrok-free.app/api/users/$_userId'; // GANTI URL
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _addressController.text = userData['alamatLengkap'] ?? '';
            _isLoading = false;
          });
        } else {
          throw Exception(responseData['error'] ?? 'Gagal mengambil data pengguna.');
        }
      } else {
        throw Exception('Gagal terhubung ke server (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Gagal memuat data profil: ${e.toString()}";
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_userId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID tidak ditemukan. Mohon login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String newName = _nameController.text;
    String newAddress = _addressController.text;

    // GANTI URL INI DENGAN URL BACKEND ANDA YANG SESUAI
    final String apiUrl = 'https://broadly-neutral-osprey.ngrok-free.app/api/users/$_userId';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Jika backend Anda memerlukan token JWT untuk update, tambahkan di sini:
          // 'Authorization': 'Bearer YOUR_JWT_TOKEN', // Ambil token dari SharedPreferences
        },
        body: jsonEncode(<String, String>{
          'name': newName,
          'alamatLengkap': newAddress,
          // Jangan kirim field lain seperti email atau password jika tidak diubah
          // atau jika endpoint update Anda tidak menanganinya dengan aman.
        }),
      );

      if (!mounted) return;

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        // Setelah sukses, kembali ke halaman sebelumnya (ProfileScreen)
        // dan kirim flag bahwa data mungkin telah berubah (jika ProfileScreen perlu refresh)
        Navigator.pop(context, true); // Mengirim 'true' sebagai hasil pop
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? 'Gagal memperbarui profil.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Error saat menyimpan profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenBackgroundColor = Colors.white;
    final onPrimaryColor = CustomColors.tertiary50;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: CustomTextStyles.boldLg.copyWith(color: onPrimaryColor),
        ),
        backgroundColor: CustomColors.primary500,
        foregroundColor: onPrimaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: _isLoading
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
                          Text(_errorMessage, textAlign: TextAlign.center, style: CustomTextStyles.regularBase),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Muat Ulang'),
                            onPressed: _loadCurrentUserData,
                            style: ElevatedButton.styleFrom(backgroundColor: CustomColors.primary500, foregroundColor: CustomColors.tertiary50),
                          )
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Nama Lengkap',
                              style: CustomTextStyles.mediumBase.copyWith(color: CustomColors.secondary500),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary900),
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama lengkap Anda',
                                hintStyle: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary500.withOpacity(0.7)),
                                filled: true,
                                fillColor: CustomColors.tertiary100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: CustomColors.secondary100.withOpacity(0.8)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: CustomColors.secondary100.withOpacity(0.8)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: CustomColors.primary500, width: 2.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Alamat',
                              style: CustomTextStyles.mediumBase.copyWith(color: CustomColors.secondary500),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressController,
                              style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary900),
                              decoration: InputDecoration(
                                hintText: 'Masukkan alamat lengkap Anda',
                                hintStyle: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary500.withOpacity(0.7)),
                                filled: true,
                                fillColor: CustomColors.tertiary100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: CustomColors.secondary100.withOpacity(0.8)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: CustomColors.secondary100.withOpacity(0.8)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: CustomColors.primary500, width: 2.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Alamat tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.primary500,
                                foregroundColor: CustomColors.tertiary50, // Untuk warna teks
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 2.0,
                                textStyle: CustomTextStyles.boldSm, // Untuk gaya font dasar tombol
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text('Simpan Perubahan'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}