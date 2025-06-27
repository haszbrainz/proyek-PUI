import 'package:flutter/material.dart';
import 'package:pui/themes/custom_colors.dart';
import 'package:pui/themes/custom_text_styles.dart';
import 'package:pui/views/laporkan/lihat_laporan.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pui/widgets/reccomendation/type.dart';
import 'package:pui/widgets/reccomendation/item.dart';
import 'package:pui/widgets/navigation/bar.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Impor SharedPreferences

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerPageController = PageController();
  String? _userName; // State untuk menyimpan nama pengguna
  bool _isLoading = true; // State untuk loading

  final List<String> bannerImagePaths = [
    'assets/images/banner1.png',
    'assets/images/banner1.png',
    'assets/images/banner1.png',
  ];

  final List<FishData> fishList = [
    FishData(
      imagePath: 'assets/images/ikan_sapu_sapu.png',
      name: 'Ikan Sapu Sapu',
      scientificName: 'Hypostomus plecostomus',
      description:
          'Ikan air tawar yang membersihkan lumut dengan mulut penghisap kuatnya.',
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
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Panggil fungsi untuk memuat data user
  }

  // --- FUNGSI BARU UNTUK MENGAMBIL NAMA PENGGUNA ---
  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // Ambil nama dari SharedPreferences, beri nilai default jika tidak ada
        _userName = prefs.getString('user_name') ?? 'Pengguna';
        _isLoading = false;
      });
    }
  }
  // --- AKHIR FUNGSI ---

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiary50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0), // Sesuaikan tinggi AppBar
        child: AppBar(
          backgroundColor: CustomColors.tertiary50,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row( // Menggunakan Row untuk tata letak yang lebih fleksibel
                children: [
                  // --- FOTO PROFIL ---
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: CustomColors.secondary100,
                    backgroundImage: const AssetImage('assets/images/user.png'), // Gambar dummy
                  ),
                  const SizedBox(width: 12),

                  // --- UCAPAN SELAMAT DATANG & NAMA PENGGUNA ---
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: CustomTextStyles.regularSm
                              .copyWith(color: CustomColors.secondary400),
                        ),
                        // Tampilkan nama pengguna dari state, atau "Memuat..." saat loading
                        _isLoading
                            ? const Text("Memuat...", style: TextStyle(fontSize: 14))
                            : Text(
                                _userName ?? 'Pengguna', // Tampilkan nama dari state
                                style: CustomTextStyles.boldLg
                                    .copyWith(color: CustomColors.primary900),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // --- ICON ---
                  IconButton(
                    icon: Icon(Icons.settings,
                        color: CustomColors.secondary400, size: 28),
                    onPressed: () {
                      print("Tombol Settings ditekan.");
                      // TODO: Implementasi navigasi atau aksi untuk pengaturan
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Banner Slider
            if (bannerImagePaths.isNotEmpty) ...[
              SizedBox(
                height: 110,
                child: PageView.builder(
                  controller: _bannerPageController,
                  itemCount: bannerImagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          bannerImagePaths[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: CustomColors.secondary100,
                              child: Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: CustomColors.secondary300,
                                    size: 50),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (bannerImagePaths.length > 1)
                Center(
                  child: SmoothPageIndicator(
                    controller: _bannerPageController,
                    count: bannerImagePaths.length,
                    effect: WormEffect(
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                      activeDotColor: CustomColors.primary500,
                      dotColor: CustomColors.secondary200,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kenali Ancaman Sungai',
                    style: CustomTextStyles.boldLg
                        .copyWith(color: CustomColors.primary900),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LihatLaporanScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat semua',
                      style: CustomTextStyles.mediumSm
                          .copyWith(color: CustomColors.primary500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fishList.length,
                itemBuilder: (context, index) {
                  return FishInfoCard(fishData: fishList[index]);
                },
              ),
            ),
            
            const SizedBox(height: 100), // Ruang untuk FloatingNavBar
          ],
        ),
      ),
      floatingActionButton: const FloatingNavigationBar(initialIndex: 0),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
