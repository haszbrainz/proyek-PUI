import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart'; // Impor image_picker
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

  // Untuk image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setDefaultLocation();
  }

  // ... (Semua method Future Anda: _setDefaultLocation, _getCurrentLocationAndPin, _getAddressFromLatLng, _onMapTap tetap sama) ...
  // Pastikan ada pengecekan 'if (mounted)' sebelum setState di dalamnya.
  Future<void> _setDefaultLocation() async {
    if (!mounted) return;
    setState(() {
      _currentPosition = _initialCenter;
      _currentCoordinates =
          "${_initialCenter.latitude.toStringAsFixed(5)}, ${_initialCenter.longitude.toStringAsFixed(5)}";
    });
    _getAddressFromLatLng(_initialCenter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(_initialCenter, _initialZoom);
      }
    });
  }

  Future<void> _getCurrentLocationAndPin() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _currentAddress = 'Layanan lokasi tidak aktif.';
      });
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _currentAddress = 'Izin lokasi ditolak.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _currentAddress =
            'Izin lokasi ditolak permanen, buka pengaturan aplikasi.';
      });
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
        setState(() {
          _currentAddress =
              "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}"
                  .replaceAll(RegExp(r', , '), ', ') 
                  .replaceAll(RegExp(r'^, |,$'), ''); 
           if (_currentAddress.startsWith(',')) _currentAddress = _currentAddress.substring(1).trim();
           if (_currentAddress.trim() == "" || _currentAddress.trim() == ",") _currentAddress = "Detail alamat tidak tersedia.";

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


  // Fungsi untuk menampilkan dialog laporan
  Future<void> _showReportDialog(BuildContext dialogContext, LatLng position, String address) async {
    XFile? selectedImage; // Variabel untuk menyimpan gambar yang dipilih di dalam dialog

    return showDialog<void>(
      context: dialogContext, // Gunakan context dari build method atau yang valid
      barrierDismissible: false, // User harus menekan tombol untuk menutup
      builder: (BuildContext context) { // Context untuk dialog
        return StatefulBuilder( // Untuk memperbarui UI di dalam dialog (gambar preview)
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text('Konfirmasi Laporan', style: CustomTextStyles.boldLg.copyWith(color: CustomColors.primary900)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Alamat:', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.secondary400)),
                    Text(address, style: CustomTextStyles.regularSm.copyWith(color: CustomColors.secondary500)),
                    const SizedBox(height: 8),
                    Text('Koordinat:', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.secondary400)),
                    Text('${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}', style: CustomTextStyles.regularSm.copyWith(color: CustomColors.secondary500)),
                    const SizedBox(height: 16),
                    Text('Bukti Gambar:', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: CustomColors.secondary200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImage == null
                          ? Center(child: Text('Belum ada gambar dipilih', style: CustomTextStyles.regularXs.copyWith(color: CustomColors.secondary300)))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.file(File(selectedImage!.path), fit: BoxFit.cover)
                            ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.image, color: CustomColors.tertiary50),
                      label: Text('Pilih Gambar', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.tertiary50)),
                      style: ElevatedButton.styleFrom(backgroundColor: CustomColors.secondary300),
                      onPressed: () async {
                        // Ambil gambar dari galeri
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        // Anda bisa juga menawarkan ImageSource.camera
                        // final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setStateDialog(() { // Gunakan setStateDialog untuk update UI dialog
                            selectedImage = image;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.secondary400)),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: CustomColors.primary500),
                  child: Text('Kirim Laporan', style: CustomTextStyles.mediumSm.copyWith(color: CustomColors.tertiary50)),
                  onPressed: () {
                    if (selectedImage == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Mohon pilih gambar bukti terlebih dahulu!'), backgroundColor: Colors.orange),
                      );
                      return; // Jangan lanjutkan jika tidak ada gambar
                    }
                    // TODO: Implementasikan logika pengiriman laporan ke server di sini
                    // Anda memiliki: address, position (LatLng), dan selectedImage (XFile)
                    print('Laporan Dikirim:');
                    print('Alamat: $address');
                    print('Koordinat: ${position.latitude}, ${position.longitude}');
                    print('Path Gambar: ${selectedImage?.path}');

                    Navigator.of(context).pop(); // Tutup dialog
                    ScaffoldMessenger.of(dialogContext).showSnackBar( // Gunakan dialogContext untuk SnackBar
                      SnackBar(content: Text('Laporan untuk "$address" berhasil dikirim (simulasi)!'), backgroundColor: Colors.green),
                    );
                  },
                ),
              ],
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
                      child: const Icon(
                        Icons.location_pin,
                        color: Color.fromARGB(255, 54, 244, 244),
                        size: 40.0,
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
            child: Card( /* ... Card Info Alamat ... */ 
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentCoordinates,
                      style: CustomTextStyles.boldSm
                          .copyWith(color: CustomColors.primary500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentAddress,
                      style: CustomTextStyles.regularXs
                          .copyWith(color: CustomColors.secondary500),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: CustomTextStyles.boldLg,
                ),
                onPressed: () {
                  if (_currentPosition != null) {
                    // Panggil dialog di sini
                    _showReportDialog(context, _currentPosition!, _currentAddress);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih lokasi terlebih dahulu!')));
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
              mini: true,
              backgroundColor: CustomColors.tertiary50,
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
        child: const FloatingNavigationBar(
          initialIndex: laporkanTabIndex,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}