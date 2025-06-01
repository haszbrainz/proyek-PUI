import 'package:flutter/material.dart';
import 'package:pui/themes/custom_colors.dart'; // Sesuaikan path jika perlu
import 'package:pui/themes/custom_text_styles.dart'; // Sesuaikan path jika perlu
// Impor FishData dan FishInfoCard dari lokasi yang benar di proyek Anda
import 'package:pui/widgets/reccomendation/type.dart'; // Contoh path ke FishData
import 'package:pui/widgets/reccomendation/item.dart';  // Path ke FishInfoCard Anda
import 'package:pui/widgets/navigation/bar.dart'; // Impor untuk FloatingNavigationBar

class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  final List<FishData> fishList = [
    FishData(
      imagePath: 'assets/images/ikan_sapu_sapu.png',
      name: 'Ikan Sapu Sapu',
      scientificName: 'Hypostomus plecostomus',
      description: 'Ikan air tawar yang membersihkan lumut dengan mulut penghisap kuatnya.',
    ),
    FishData(
      imagePath: 'assets/images/ikan_red_devil.png',
      name: 'Ikan Red Devil',
      scientificName: 'Amphilophus labiatus',
      description: 'Ikan agresif berwarna merah mencolok dari Amerika Tengah.',
    ),
    FishData(
      imagePath: 'assets/images/ikan_aligator.png',
      name: 'Ikan Aligator',
      scientificName: 'Atractosteus spatula',
      description: 'Ikan predator besar dengan moncong mirip aligator.',
    ),
    FishData(
      imagePath: 'assets/images/ikan_sapu_sapu.png',
      name: 'Ikan Sapu Sapu (Lagi)',
      scientificName: 'Hypostomus plecostomus',
      description: 'Ditemukan lagi, ikan pembersih lumut yang rajin dan tangguh.',
    ),
     FishData(
      imagePath: 'assets/images/ikan_red_devil.png',
      name: 'Ikan Red Devil (Lagi)',
      scientificName: 'Amphilophus labiatus',
      description: 'Sangat teritorial dan berwarna cerah, perlu perhatian khusus!',
    ),
    FishData(
      imagePath: 'assets/images/ikan_aligator.png',
      name: 'Ikan Aligator (Lagi)',
      scientificName: 'Atractosteus spatula',
      description: 'Predator purba yang masih eksis di berbagai perairan tawar dunia.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiary100, // Warna latar belakang Scaffold
      appBar: AppBar(
        // --- PERUBAHAN APPBAR ---
        backgroundColor: CustomColors.tertiary100, // Sama dengan background Scaffold
        elevation: 0.0, // Tidak ada bayangan, agar menyatu dengan body
        automaticallyImplyLeading: false, // Menghilangkan tombol kembali (arrow) otomatis
        title: Text(
          'Kenali Ancaman untuk Sungai', // Judul AppBar baru
          style: CustomTextStyles.boldLg.copyWith(color: CustomColors.primary900), // Warna teks gelap agar kontras
        ),
        centerTitle: false, // Opsional: agar judul di tengah jika diinginkan
        // --- AKHIR PERUBAHAN APPBAR ---
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding disesuaikan
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teks 'Kenali Ancaman untuk Sungai' yang sebelumnya di sini sudah dihapus
              // const SizedBox(height: 20), // SizedBox ini juga tidak lagi diperlukan jika teks di atasnya hilang
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fishList.length,
                itemBuilder: (context, index) {
                  return FishInfoCard(fishData: fishList[index]);
                },
              ),
              const SizedBox(height: 80), // Spasi untuk FloatingNavigationBar
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingNavigationBar(initialIndex: 1), // Artikel
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}