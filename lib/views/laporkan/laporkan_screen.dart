import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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

  final LatLng _initialCenter = const LatLng(-7.7956, 110.3695);
  double _initialZoom = 13.0;

  static const int laporkanTabIndex = 2;
  final double _fabBottomPadding = 20.0;

  final ImagePicker _picker = ImagePicker();
  // Controller untuk TextField Deskripsi di BottomSheet
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _setDefaultLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose(); // Jangan lupa dispose controller
    _mapController.dispose(); // Dispose map controller jika perlu
    super.dispose();
  }

  // ... (method _setDefaultLocation, _getCurrentLocationAndPin, _getAddressFromLatLng, _onMapTap tetap sama seperti sebelumnya, pastikan ada 'if (mounted)' ) ...
  Future<void> _setDefaultLocation() async {
    if (!mounted) return;
    // Try to get current location first
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _currentPosition = _initialCenter;
        _currentCoordinates = "Layanan Lokasi Nonaktif. (${_initialCenter.latitude.toStringAsFixed(3)}, ${_initialCenter.longitude.toStringAsFixed(3)})";
        _currentAddress = "Aktifkan layanan lokasi untuk akurasi.";
      });
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) _mapController.move(_initialCenter, _initialZoom);
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          if (!mounted) return;
          setState(() {
            _currentPosition = _initialCenter;
            _currentCoordinates = "Izin Lokasi Ditolak. (${_initialCenter.latitude.toStringAsFixed(3)}, ${_initialCenter.longitude.toStringAsFixed(3)})";
            _currentAddress = "Berikan izin lokasi untuk fungsionalitas penuh.";
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) _mapController.move(_initialCenter, _initialZoom);
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
      _getAddressFromLatLng(newPosition);
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted) _mapController.move(newPosition, 15.0);
      });
    } catch (e) {
      print('Error mendapatkan lokasi awal: $e');
      if (!mounted) return;
      setState(() {
         _currentPosition = _initialCenter;
        _currentCoordinates = "Gagal dapat lokasi. (${_initialCenter.latitude.toStringAsFixed(3)}, ${_initialCenter.longitude.toStringAsFixed(3)})";
        _currentAddress = "Silakan coba lagi atau pilih manual.";
      });
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) _mapController.move(_initialCenter, _initialZoom);
      });
    }
  }

  Future<void> _getCurrentLocationAndPin() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan lokasi tidak aktif. Mohon aktifkan.'), backgroundColor: Colors.orange));
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.'), backgroundColor: Colors.orange));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak permanen. Mohon aktifkan dari pengaturan aplikasi.'), backgroundColor: Colors.red));
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
          _currentAddress = formattedAddress.isEmpty ? "Detail alamat tidak tersedia." : formattedAddress;
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
    if (!mounted) return;
    setState(() {
      _currentPosition = latLng;
      _currentCoordinates =
          "${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}";
    });
    _getAddressFromLatLng(latLng);
  }


  // Fungsi untuk menampilkan BottomSheet laporan
  void _showReportBottomSheet(BuildContext mainScreenContext, LatLng position, String address) {
    XFile? _selectedImageInBottomSheet; // State untuk gambar di bottom sheet
    _descriptionController.clear(); // Bersihkan deskripsi setiap kali sheet dibuka

    showModalBottomSheet(
      context: mainScreenContext,
      isScrollControlled: true, // Agar bisa lebih tinggi dari setengah layar
      shape: const RoundedRectangleBorder( // Memberi border radius di atas
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext builderContext) {
        return StatefulBuilder( // Untuk update UI di dalam bottom sheet
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Untuk keyboard
                top: 20, left: 20, right: 20
              ),
              child: SingleChildScrollView( // Agar konten bisa di-scroll jika panjang
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center( // Judul "Laporkan"
                      child: Text(
                        'Laporkan',
                        style: CustomTextStyles.boldXl.copyWith(color: CustomColors.primary900),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Alamat Laporan', style: CustomTextStyles.mediumBase.copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: CustomColors.secondary200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(address, style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary500)),
                    ),
                    const SizedBox(height: 16),

                    Text('Koordinat', style: CustomTextStyles.mediumBase.copyWith(color: CustomColors.secondary400)),
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
                        style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary500),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Deskripsi', style: CustomTextStyles.mediumBase.copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Masukan detail laporan',
                        hintStyle: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary300),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomColors.secondary200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomColors.primary500, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: CustomTextStyles.regularBase.copyWith(color: CustomColors.secondary500),
                    ),
                    const SizedBox(height: 16),

                    Text('Bukti Laporan', style: CustomTextStyles.mediumBase.copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 8),
                    Center( // Agar image preview dan tombol upload di tengah
                      child: Column(
                        children: [
                          Container(
                            height: 150,
                            width: 200, // Atau double.infinity jika ingin lebar penuh
                            decoration: BoxDecoration(
                              color: CustomColors.tertiary100,
                              border: Border.all(color: CustomColors.secondary200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _selectedImageInBottomSheet == null
                                ? Center(
                                    child: Icon(Icons.image_not_supported_outlined, size: 50, color: CustomColors.secondary300)
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(7.0),
                                    child: Image.file(File(_selectedImageInBottomSheet!.path), fit: BoxFit.cover),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: Icon(Icons.camera_alt_outlined, color: CustomColors.tertiary50, size: 20),
                            label: Text('Upload Gambar', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.tertiary50)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.primary500, // Warna tombol upload
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                            ),
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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

                    Row( // Tombol Batal dan Kirim Laporan
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: CustomColors.secondary300),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                            ),
                            child: Text('Batal', style: CustomTextStyles.boldSm.copyWith(color: CustomColors.secondary400)),
                            onPressed: () => Navigator.of(builderContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.primary500,
                              foregroundColor: CustomColors.tertiary50,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                            ),
                            child: Text('Kirim Laporan', style: CustomTextStyles.boldSm.copyWith(color: CustomColors.primary50)),
                            onPressed: () {
                              if (_selectedImageInBottomSheet == null) {
                                ScaffoldMessenger.of(mainScreenContext).showSnackBar(
                                  SnackBar(content: Text('Mohon pilih gambar bukti terlebih dahulu!'), backgroundColor: Colors.orange),
                                );
                                return;
                              }
                              final String deskripsiLaporan = _descriptionController.text;
                              print('Laporan Dikirim:');
                              print('Alamat: $address');
                              print('Koordinat: ${position.latitude}, ${position.longitude}');
                              print('Deskripsi: $deskripsiLaporan');
                              print('Path Gambar: ${_selectedImageInBottomSheet?.path}');

                              // TODO: Implementasikan logika pengiriman laporan ke server di sini

                              Navigator.of(builderContext).pop(); // Tutup bottom sheet
                              ScaffoldMessenger.of(mainScreenContext).showSnackBar(
                                SnackBar(content: Text('Laporan untuk "$address" berhasil dikirim (simulasi)!'), backgroundColor: Colors.green),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Sedikit padding di bawah tombol
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
                userAgentPackageName: 'com.example.pui', // GANTI DENGAN PACKAGE NAME ANDA
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
                        color: CustomColors.primary400 ,
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
                        Icon(Icons.gps_fixed, color: CustomColors.primary500, size: 16),
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
                        Icon(Icons.location_on_outlined, color: CustomColors.secondary500, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: CustomTextStyles.regularXs
                                .copyWith(color: CustomColors.secondary500, height: 1.4),
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
                      borderRadius: BorderRadius.circular(30)),
                  textStyle: CustomTextStyles.boldLg,
                ),
                onPressed: () {
                  if (_currentPosition != null && _currentAddress.isNotEmpty && _currentAddress != "Memuat alamat..." && !_currentAddress.toLowerCase().contains("gagal") && !_currentAddress.toLowerCase().contains("ditolak")) {
                    _showReportBottomSheet(context, _currentPosition!, _currentAddress);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih lokasi yang valid atau tunggu alamat dimuat!'), backgroundColor: Colors.orange,));
                  }
                },
                child: const Center(
                  child: Text('Laporkan'),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: totalBottomSpaceForNavBar + reportButtonWithVerticalSpacing + 10,
            right: 20,
            child: FloatingActionButton(
              heroTag: "fabLokasiSaya",
              mini: true,
              backgroundColor: CustomColors.tertiary50,
              elevation: 3,
              onPressed: _getCurrentLocationAndPin,
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