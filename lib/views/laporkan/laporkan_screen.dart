import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http; // Impor paket http
import 'package:shared_preferences/shared_preferences.dart'; // Impor SharedPreferences
import 'package:pui/themes/custom_colors.dart'; // Sesuaikan path
import 'package:pui/themes/custom_text_styles.dart'; // Sesuaikan path
import 'package:pui/widgets/navigation/bar.dart'; // Sesuaikan path

class LaporkanScreen extends StatefulWidget {
  const LaporkanScreen({super.key});

  @override
  State<LaporkanScreen> createState() => _LaporkanScreenState();
}

class _LaporkanScreenState extends State<LaporkanScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  String _currentAddress = "Memuat alamat...";
  String _currentCoordinates = "Ketuk ikon lokasi";

  final LatLng _initialCenter = const LatLng(-2.548926, 118.0148634);
  double _initialZoom = 5.0;

  static const int laporkanTabIndex = 2;
  final double _fabBottomPadding = 20.0;

  final ImagePicker _picker = ImagePicker();
  late TextEditingController _descriptionController;
  bool _isSendingReport = false; // State untuk loading di dalam bottom sheet

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _setDefaultLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    // _mapController.dispose(); // MapController tidak selalu perlu di-dispose manual kecuali ada listener
    super.dispose();
  }

  Future<void> _setDefaultLocation() async {
    if (!mounted) return;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _currentPosition = _initialCenter;
        _currentCoordinates =
            "Layanan Lokasi Nonaktif. (${_initialCenter.latitude.toStringAsFixed(3)}, ${_initialCenter.longitude.toStringAsFixed(3)})";
        _currentAddress = "Aktifkan layanan lokasi untuk akurasi.";
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(_initialCenter, _initialZoom);
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _currentPosition = _initialCenter;
          _currentCoordinates =
              "Izin Lokasi Ditolak. (${_initialCenter.latitude.toStringAsFixed(3)}, ${_initialCenter.longitude.toStringAsFixed(3)})";
          _currentAddress = "Berikan izin lokasi untuk fungsionalitas penuh.";
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(_initialCenter, _initialZoom);
        });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _currentPosition = newPosition;
        _currentCoordinates =
            "${newPosition.latitude.toStringAsFixed(5)}, ${newPosition.longitude.toStringAsFixed(5)}";
      });
      _getAddressFromLatLng(
          newPosition); // Dapatkan alamat setelah posisi didapat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Pindahkan peta setelah state diupdate
        if (mounted) _mapController.move(newPosition, 15.0);
      });
    } catch (e) {
      print('Error mendapatkan lokasi awal: $e');
      if (!mounted) return;
      setState(() {
        _currentPosition = _initialCenter;
        _currentCoordinates =
            "Gagal dapat lokasi. (${_initialCenter.latitude.toStringAsFixed(3)}, ${_initialCenter.longitude.toStringAsFixed(3)})";
        _currentAddress = "Silakan coba lagi atau pilih manual.";
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(_initialCenter, _initialZoom);
      });
    }
  }

  Future<void> _getCurrentLocationAndPin() async {
    // ... (logika _getCurrentLocationAndPin Anda yang sudah disempurnakan)
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Layanan lokasi tidak aktif. Mohon aktifkan.'),
          backgroundColor: Colors.orange));
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Izin lokasi ditolak.'),
            backgroundColor: Colors.orange));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Izin lokasi ditolak permanen. Mohon aktifkan dari pengaturan aplikasi.'),
          backgroundColor: Colors.red));
      await Geolocator.openAppSettings();
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentAddress = "Mencari lokasi...";
      _currentCoordinates = "Mencari...";
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _currentPosition = newPosition;
        _currentCoordinates =
            "${newPosition.latitude.toStringAsFixed(5)}, ${newPosition.longitude.toStringAsFixed(5)}";
        _mapController.move(newPosition, 15.0);
      });
      _getAddressFromLatLng(newPosition);
    } catch (e) {
      print('Error mendapatkan lokasi: $e');
      if (!mounted) return;
      setState(() {
        _currentAddress = 'Gagal mendapatkan lokasi.';
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    // ... (logika _getAddressFromLatLng Anda yang sudah disempurnakan)
    if (!mounted) return;
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String street = place.street ?? '';
        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? '';
        String subAdministrativeArea = place.subAdministrativeArea ?? '';
        String administrativeArea = place.administrativeArea ?? '';
        String postalCode = place.postalCode ?? '';
        String country = place.country ?? '';

        List<String> addressParts = [
          street,
          subLocality,
          locality,
          subAdministrativeArea,
          administrativeArea,
          postalCode,
          country
        ];
        addressParts.removeWhere((part) => part.isEmpty);
        String formattedAddress = addressParts.join(', ');

        setState(() {
          _currentAddress = formattedAddress.isEmpty
              ? "Detail alamat tidak tersedia."
              : formattedAddress;
        });
      } else {
        setState(() {
          _currentAddress = "Alamat tidak ditemukan.";
        });
      }
    } catch (e) {
      print('Error geocoding: $e');
      if (!mounted) return;
      setState(() {
        _currentAddress = "Gagal mendapatkan alamat.";
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    // ... (logika _onMapTap Anda yang sudah disempurnakan)
    if (!mounted) return;
    setState(() {
      _currentPosition = latLng;
      _currentCoordinates =
          "${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}";
    });
    _getAddressFromLatLng(latLng);
  }

  void _showReportBottomSheet(
      BuildContext mainScreenContext, LatLng position, String address) {
    XFile? _selectedImageInBottomSheet;
    _descriptionController.clear();

    showModalBottomSheet(
      context: mainScreenContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext builderContext) {
        // Ini adalah context untuk BottomSheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ... (Konten BottomSheet: Judul, Alamat, Koordinat, Deskripsi, Preview Gambar, Tombol Upload) ...
                    // (Ini sama seperti kode Anda sebelumnya)
                    Center(
                      child: Text(
                        'Laporkan',
                        style: CustomTextStyles.boldXl
                            .copyWith(color: CustomColors.primary900),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Alamat Laporan',
                        style: CustomTextStyles.mediumBase
                            .copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: CustomColors.secondary200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(address,
                          style: CustomTextStyles.regularBase
                              .copyWith(color: CustomColors.secondary500)),
                    ),
                    const SizedBox(height: 16),

                    Text('Koordinat',
                        style: CustomTextStyles.mediumBase
                            .copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: CustomColors.secondary200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                        style: CustomTextStyles.regularBase
                            .copyWith(color: CustomColors.secondary500),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Deskripsi',
                        style: CustomTextStyles.mediumBase
                            .copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Masukan detail laporan',
                        hintStyle: CustomTextStyles.regularBase
                            .copyWith(color: CustomColors.secondary300),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: CustomColors.secondary200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: CustomColors.primary500, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: CustomTextStyles.regularBase
                          .copyWith(color: CustomColors.secondary500),
                    ),
                    const SizedBox(height: 16),

                    Text('Bukti Laporan',
                        style: CustomTextStyles.mediumBase
                            .copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 150,
                            width: 200,
                            decoration: BoxDecoration(
                              color: CustomColors.tertiary100,
                              border:
                                  Border.all(color: CustomColors.secondary200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _selectedImageInBottomSheet == null
                                ? Center(
                                    child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 50,
                                        color: CustomColors.secondary300))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(7.0),
                                    child: Image.file(
                                        File(_selectedImageInBottomSheet!.path),
                                        fit: BoxFit.cover),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: Icon(Icons.camera_alt_outlined,
                                color: CustomColors.tertiary50, size: 20),
                            label: Text('Upload Gambar',
                                style: CustomTextStyles.mediumSm
                                    .copyWith(color: CustomColors.tertiary50)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.primary500,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 70);
                              if (image != null) {
                                setStateBottomSheet(() {
                                  _selectedImageInBottomSheet = image;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: CustomColors.secondary300),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: Text('Batal',
                                style: CustomTextStyles.boldSm.copyWith(
                                    color: CustomColors.secondary400)),
                            onPressed: () => Navigator.of(builderContext)
                                .pop(), // Gunakan builderContext
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.primary500,
                              foregroundColor: CustomColors.tertiary50,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              textStyle: CustomTextStyles
                                  .boldSm, // Untuk ukuran & ketebalan teks
                            ),
                            // Di dalam _showReportBottomSheet, pada onPressed tombol 'Kirim Laporan':

                            onPressed: _isSendingReport
                                ? null
                                : () async {
                                    if (_selectedImageInBottomSheet == null) {
                                      ScaffoldMessenger.of(mainScreenContext)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Mohon pilih gambar bukti terlebih dahulu!'),
                                            backgroundColor:
                                          
                                                    Colors.orange),
                                      );
                                      return;
                                    }

                                    setStateBottomSheet(() {
                                      _isSendingReport = true;
                                    });

                                    String imageUrlForBackend =
                                        "https://via.placeholder.com/300/09f/fff.png?text=BuktiLaporanDefault";
                                    if (_selectedImageInBottomSheet != null) {
                                      print(
                                          'Path gambar lokal yang akan diupload (simulasi): ${_selectedImageInBottomSheet!.path}');
                                      // imageUrlForBackend = await _uploadImageFunction(File(_selectedImageInBottomSheet!.path)); // Jika sudah ada fungsi upload
                                    }

                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    final int? pelaporId =
                                        prefs.getInt('user_id');

                                    if (pelaporId == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(mainScreenContext)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Gagal mendapatkan ID pengguna. Mohon login ulang.'),
                                            backgroundColor: Colors.red),
                                      );
                                      setStateBottomSheet(() {
                                        _isSendingReport = false;
                                      });
                                      return;
                                    }

                                    Map<String, dynamic> reportData = {
                                      "alamat":
                                          address, // address dari parameter _showReportBottomSheet
                                      "koordinatLatitude": position
                                          .latitude, // position dari parameter _showReportBottomSheet
                                      "koordinatLongitude": position.longitude,
                                      "description":
                                          _descriptionController.text,
                                      "imageUrl": imageUrlForBackend,
                                      "pelaporId": pelaporId,
                                      // "status": "BARU" // Biarkan backend yang set default jika sudah diatur di Prisma
                                    };

                                    // --- TAMBAHKAN LOG DI SINI ---
                                    print(
                                        "--- DATA LAPORAN YANG AKAN DIKIRIM ---");
                                    print(jsonEncode(
                                        reportData)); // Cetak data yang akan dikirim sebagai JSON
                                    // --- AKHIR LOG ---

                                    const String apiUrl =
                                        'https://broadly-neutral-osprey.ngrok-free.app/api/laporan'; // Untuk emulator Android
                                    // const String apiUrl = 'http://localhost:3000/api/laporan'; // Untuk web/device di jaringan sama
                                    print("Mengirim request ke: $apiUrl");

                                    try {
                                      final response = await http.post(
                                        Uri.parse(apiUrl),
                                        headers: {
                                          'Content-Type':
                                              'application/json; charset=UTF-8'
                                        },
                                        body: jsonEncode(reportData),
                                      );

                                      // --- TAMBAHKAN LOG DI SINI ---
                                      print("--- RESPON SERVER ---");
                                      print(
                                          'Status Code: ${response.statusCode}');
                                      print('Response Body: ${response.body}');
                                      // --- AKHIR LOG ---

                                      if (!mainScreenContext.mounted) return;
                                      final Map<String, dynamic> responseData =
                                          jsonDecode(response.body);

                                      if (response.statusCode == 201 &&
                                          responseData['success'] == true) {
                                        Navigator.of(builderContext).pop();
                                        ScaffoldMessenger.of(mainScreenContext)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(responseData[
                                                      'message'] ??
                                                  'Laporan berhasil dikirim!'),
                                              backgroundColor:
                                            
                                                      Colors.green),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(mainScreenContext)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(responseData[
                                                      'error'] ??
                                                  'Gagal mengirim laporan. Status: ${response.statusCode}'),
                                              backgroundColor:
                                         
                                                      Colors.red),
                                        );
                                      }
                                    } catch (e) {
                                      print('--- ERROR PADA HTTP REQUEST ---');
                                      print(
                                          'Error mengirim laporan: ${e.toString()}');
                                      if (!mainScreenContext.mounted) return;
                                      ScaffoldMessenger.of(mainScreenContext)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Terjadi kesalahan jaringan: ${e.toString()}'),
                                            backgroundColor: Colors.red),
                                      );
                                    } finally {
                                      setStateBottomSheet(() {
                                        _isSendingReport = false;
                                      });
                                    }
                                  },
                            child: _isSendingReport
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text('Kirim Laporan',
                                    style: CustomTextStyles.boldSm),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double navigationBarHeightEstimate = 70.0;
    final double totalBottomSpaceForNavBar =
        navigationBarHeightEstimate + _fabBottomPadding + 16;

    const double reportButtonWidth = 280.0;
    const double reportButtonHeight = 55.0;
    final double reportButtonHorizontalMargin =
        (MediaQuery.of(context).size.width - reportButtonWidth) / 2;

    const double reportButtonWithVerticalSpacing = reportButtonHeight + 10.0;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.pui', // GANTI DENGAN PACKAGE NAME ANDA
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: Icon(
                        Icons.fmd_good,
                        color: CustomColors.primary400, // Sesuaikan warna pin
                        size: 45.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gps_fixed,
                            color: CustomColors.primary500, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentCoordinates,
                            style: CustomTextStyles.boldSm
                                .copyWith(color: CustomColors.primary500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: CustomColors.secondary500, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: CustomTextStyles.regularXs.copyWith(
                                color: CustomColors.secondary500, height: 1.4),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: totalBottomSpaceForNavBar + 10,
            left: reportButtonHorizontalMargin,
            right: reportButtonHorizontalMargin,
            child: SizedBox(
              width: reportButtonWidth,
              height: reportButtonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.primary500,
                  foregroundColor: CustomColors.tertiary50,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          30)), // Radius 30 seperti di gambar sheet
                  textStyle: CustomTextStyles.boldLg,
                ),
                onPressed: (_isSendingReport ||
                        _currentPosition == null ||
                        _currentAddress.isEmpty ||
                        _currentAddress == "Memuat alamat..." ||
                        _currentAddress.toLowerCase().contains("gagal") ||
                        _currentAddress.toLowerCase().contains("ditolak") ||
                        _currentAddress.toLowerCase().contains("nonaktif") ||
                        _currentAddress
                            .toLowerCase()
                            .contains("tidak tersedia"))
                    ? null // Disable tombol jika sedang mengirim atau lokasi/alamat tidak valid
                    : () {
                        _showReportBottomSheet(
                            context, _currentPosition!, _currentAddress);
                      },
                child: _isSendingReport
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
                    : const Text('Laporkan'),
              ),
            ),
          ),
          Positioned(
            bottom: totalBottomSpaceForNavBar +
                reportButtonWithVerticalSpacing +
                10,
            right: 20,
            child: FloatingActionButton(
              heroTag: "fabLokasiSaya",
              mini: true,
              backgroundColor: CustomColors.tertiary50,
              elevation: 3,
              onPressed: _isSendingReport
                  ? null
                  : _getCurrentLocationAndPin, // Disable juga saat mengirim
              child: Icon(
                Icons.my_location,
                color: CustomColors.primary500,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _fabBottomPadding),
        child: FloatingNavigationBar(
          key: UniqueKey(),
          initialIndex: laporkanTabIndex,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
