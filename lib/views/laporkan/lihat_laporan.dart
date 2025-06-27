// Berkas: lihat_laporan_screen.dart

import 'dart:convert'; // Untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Untuk HTTP requests

// Sesuaikan path impor ini jika berbeda di proyek Anda
import 'package:pui/themes/custom_colors.dart';
import 'package:pui/themes/custom_text_styles.dart';

// Model Data Sederhana untuk Laporan
// Anda bisa memindahkan ini ke file model terpisah jika proyek semakin besar,
// misalnya: models/laporan_data_model.dart
class LaporanData {
  final int id;
  final String alamat;
  final String? description; // Deskripsi bisa null
  final String imageUrl;
  final String status;
  final DateTime createdAt;
  final String pelaporName;
  final String pelaporEmail;

  LaporanData({
    required this.id,
    required this.alamat,
    this.description,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.pelaporName,
    required this.pelaporEmail,
  });

  // Factory constructor untuk membuat instance LaporanData dari JSON
  factory LaporanData.fromJson(Map<String, dynamic> json) {
    return LaporanData(
      id: json['id'] as int? ?? 0, // Beri nilai default jika null
      alamat: json['alamat'] as String? ?? 'Alamat tidak tersedia',
      description: json['description'] as String?,
      imageUrl:
          json['imageUrl'] as String? ?? '', // Beri string kosong jika null
      status: json['status'] as String? ?? 'STATUS_TIDAK_DIKETAHUI',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(), // Fallback ke waktu sekarang jika null
      // Mengambil data pelapor dari objek nested 'pelapor'
      pelaporName: json['pelapor']?['name'] as String? ?? 'Pelapor Anonim',
      pelaporEmail: json['pelapor']?['email'] as String? ?? '-',
    );
  }
}

class LihatLaporanScreen extends StatefulWidget {
  const LihatLaporanScreen({super.key});

  @override
  State<LihatLaporanScreen> createState() => _LihatLaporanScreenState();
}

class _LihatLaporanScreenState extends State<LihatLaporanScreen> {
  List<LaporanData> _laporanList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // GANTI URL API INI DENGAN URL BACKEND ANDA YANG SESUAI
    // const String apiUrl = 'http://10.0.2.2:3000/api/laporan'; // Untuk emulator Android
    const String apiUrl =
        'https://broadly-neutral-osprey.ngrok-free.app/api/laporan'; // Contoh menggunakan ngrok
    // const String apiUrl = 'http://localhost:3000/api/laporan'; // Jika Flutter web & backend di PC sama
    // const String apiUrl = 'http://ALAMAT_IP_PC_ANDA:3000/api/laporan'; // Untuk perangkat fisik

    print("Fetching daftar laporan dari: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (!mounted) return;

      print('Lihat Laporan Response status: ${response.statusCode}');
      // Hati-hati mencetak response.body jika sangat panjang, bisa memotong log di konsol
      // print('Lihat Laporan Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] is List) {
          List<dynamic> laporanJsonList = responseData['data'];
          setState(() {
            _laporanList = laporanJsonList
                .map((json) =>
                    LaporanData.fromJson(json as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        } else {
          // Jika success false atau data bukan List
          throw Exception(responseData['error'] ??
              'Format data laporan tidak sesuai dari server.');
        }
      } else {
        // Jika status code bukan 200
        throw Exception(
            'Gagal mengambil data laporan (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error saat mengambil daftar laporan: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = "Gagal memuat daftar laporan: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mendapatkan warna status (opsional, untuk visual)
  Color _getStatusColor(String status) {
    // Sesuaikan nama status dengan yang ada di ENUM Prisma atau string yang dikembalikan backend
    if (status.toUpperCase() == 'SELESAI') {
      return Colors.green; // Hijau
    } else if (status.toUpperCase() == 'DIPROSES') {
      return Colors.orange; // Oranye/Kuning
    } else if (status.toUpperCase() == 'DITOLAK') {
      return Colors.red; // Merah
    }
    return CustomColors.primary400; // Biru untuk 'BARU' atau 'BELUM_DIPROSES'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: CustomColors.tertiary50), // Membuat icon arrow putih
        titleSpacing: 15.0, // Menambah jarak antara icon arrow dan judul
        title: Text('Daftar Laporan',
            style: CustomTextStyles.boldLg
                .copyWith(color: CustomColors.tertiary50)),
        backgroundColor: CustomColors.primary500,
        elevation: 1.0,
        // Tombol kembali akan otomatis ditambahkan jika screen ini di-push menggunakan Navigator.push()
        // Jika Anda ingin tombol kembali kustom atau dari root navigasi:
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: CustomColors.tertiary50),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      backgroundColor: CustomColors.tertiary100, // Latar belakang halaman
      body: _buildBody(), // Memanggil method _buildBody untuk konten
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
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
                onPressed: _fetchLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.primary500,
                  foregroundColor: CustomColors.tertiary50,
                ),
              )
            ],
          ),
        ),
      );
    }

    if (_laporanList.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 60, color: CustomColors.secondary300),
          const SizedBox(height: 16),
          Text(
            'Belum ada laporan yang tersedia.',
            style: CustomTextStyles.mediumLg
                .copyWith(color: CustomColors.secondary400),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            // Tombol refresh jika daftar kosong
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            onPressed: _fetchLaporan,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.primary400,
              foregroundColor: CustomColors.tertiary50,
            ),
          )
        ],
      ));
    }

    // Jika ada data, tampilkan ListView
    return RefreshIndicator(
      onRefresh: _fetchLaporan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _laporanList.length,
        itemBuilder: (context, index) {
          final laporan = _laporanList[index];
          return Card(
            elevation: 3.0, // Sedikit lebih menonjol
            margin: const EdgeInsets.only(bottom: 16.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior:
                Clip.antiAlias, // Agar ClipRRect pada Image.network bekerja
            child: InkWell(
              // Tambahkan InkWell untuk interaksi di masa depan
              onTap: () {
                // TODO: Implementasi aksi saat item laporan ditekan (misal, buka detail laporan)
                print('Laporan ID ${laporan.id} ditekan.');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Anda menekan laporan: ${laporan.alamat}')));
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (laporan.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          laporan.imageUrl,
                          height: 180, // Tinggi gambar dibuat lebih seragam
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 180,
                            color: CustomColors.secondary100,
                            child: Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: CustomColors.secondary300,
                                    size: 40)),
                          ),
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              color: CustomColors.secondary100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: CustomColors.primary500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (laporan.imageUrl.isNotEmpty) const SizedBox(height: 12),

                    Text(
                      laporan.alamat,
                      style: CustomTextStyles.boldBase
                          .copyWith(color: CustomColors.primary700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ',
                          style: CustomTextStyles.regularSm
                              .copyWith(color: CustomColors.secondary400),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(laporan.status)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            laporan.status,
                            style: CustomTextStyles.boldXs.copyWith(
                                color: _getStatusColor(laporan.status)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (laporan.description != null &&
                        laporan.description!.isNotEmpty) ...[
                      Text(
                        'Deskripsi:',
                        style: CustomTextStyles.mediumSm
                            .copyWith(color: CustomColors.secondary400),
                      ),
                      Text(
                        laporan.description!,
                        style: CustomTextStyles.regularSm.copyWith(
                            color: CustomColors.secondary500, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],

                    Divider(color: CustomColors.secondary100, height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pelapor:',
                              style: CustomTextStyles.regularXs
                                  .copyWith(color: CustomColors.secondary300),
                            ),
                            Text(
                              laporan.pelaporName,
                              style: CustomTextStyles.mediumXs
                                  .copyWith(color: CustomColors.secondary400),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Dilaporkan pada:',
                              style: CustomTextStyles.regularXs
                                  .copyWith(color: CustomColors.secondary300),
                            ),
                            Text(
                              // Format tanggal menjadi lebih mudah dibaca
                              '${laporan.createdAt.day}/${laporan.createdAt.month}/${laporan.createdAt.year} ${laporan.createdAt.hour.toString().padLeft(2, '0')}:${laporan.createdAt.minute.toString().padLeft(2, '0')}',
                              style: CustomTextStyles.mediumXs
                                  .copyWith(color: CustomColors.secondary400),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Tambahkan icon arrow putih di pojok kanan bawah
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
