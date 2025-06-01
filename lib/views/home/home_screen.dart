import 'package:flutter/material.dart';
import 'package:pui/themes/custom_colors.dart';
import 'package:pui/themes/custom_text_styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pui/widgets/reccomendation/type.dart';
import 'package:pui/widgets/reccomendation/item.dart'; // Komentar dari kode Anda
import 'package:pui/widgets/navigation/bar.dart'; // Asumsi FloatingNavigationBar ada di sini
import 'package:pui/views/artikel/artikel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerPageController = PageController();
  // ... (sisa state variabel tetap sama) ...
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
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiary50, // Menggunakan CustomColors
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(96.0),
        child: AppBar(
          backgroundColor: CustomColors.tertiary50, // Menggunakan CustomColors
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: const AssetImage('assets/images/user.png'),
                      onBackgroundImageError: (exception, stackTrace) {
                         print('Error loading user image: $exception');
                      },
                      // Fallback jika gambar gagal atau tidak ada
                      // child: const Icon(Icons.person, size: 24, color: CustomColors.secondary200), // Menggunakan CustomColors
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Selamat Datang',
                          // Anda bisa juga menggunakan CustomTextStyles di sini jika sudah ada definisi yang sesuai
                          style: TextStyle(
                            color: CustomColors.primary900, // Menggunakan CustomColors
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Samuel', // Sebaiknya nama pengguna dinamis
                          // Anda bisa juga menggunakan CustomTextStyles di sini
                          style: TextStyle(
                            color: CustomColors.secondary500, // Menggunakan CustomColors
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: CustomColors.primary500, size: 28), // Menggunakan CustomColors
                      onPressed: () {
                        print("Tombol Settings ditekan.");
                        // Implementasi navigasi atau aksi untuk pengaturan
                      },
                    ),
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
                  scrollDirection: Axis.horizontal,
                  controller: _bannerPageController,
                  itemCount: bannerImagePaths.length,
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() {
                        // _currentBannerPage = index; // _currentBannerPage tidak digunakan, bisa dihapus jika tidak ada rencana penggunaan
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          bannerImagePaths[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                'Error loading banner asset: ${bannerImagePaths[index]}, Error: $error');
                            return Container(
                              color: CustomColors.secondary100, // Tetap menggunakan secondary100 untuk error box
                              child: Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: CustomColors.secondary300, size: 50), // Tetap menggunakan secondary300
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
                    axisDirection: Axis.horizontal,
                    effect: WormEffect(
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                      activeDotColor: CustomColors.primary500, // Sudah menggunakan CustomColors
                      dotColor: CustomColors.secondary200,  // Sudah menggunakan CustomColors
                    ),
                    onDotClicked: (index) {
                      _bannerPageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
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
                        .copyWith(color: CustomColors.primary900), // Sudah menggunakan CustomColors
                  ),
                   TextButton(
                    onPressed: () {
                      // --- PERUBAHAN NAVIGASI ---
                      print('Tombol "Lihat semua" ikan ditekan. Navigasi ke ArtikelScreen...');
                      Navigator.pushNamed(context, '/artikel'); // Gunakan rute bernama
                      // --- AKHIR PERUBAHAN NAVIGASI ---
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
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: const FloatingNavigationBar(initialIndex: 0), // Beranda
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}