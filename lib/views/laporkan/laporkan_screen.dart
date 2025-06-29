// Berkas: laporkan_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Diperlukan untuk MediaType

// Sesuaikan path impor Anda
import 'package:pui/themes/custom_colors.dart';
import 'package:pui/themes/custom_text_styles.dart';
import 'package:pui/widgets/navigation/bar.dart';
import 'package:pui/views/laporkan/lihat_laporan.dart';

class LaporkanScreen extends StatefulWidget {
  const LaporkanScreen({super.key});

  @override
  State<LaporkanScreen> createState() => _LaporkanScreenState();
}

class _LaporkanScreenState extends State<LaporkanScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  String _currentAddress = "Memuat alamat...";
  String _currentCoordinates = "Ketuk ikon lokasi atau peta";

  final LatLng _initialCenter = const LatLng(-2.548926, 118.0148634);
  double _initialZoom = 4.5;

  static const int laporkanTabIndex = 2;
  final double _fabBottomPadding = 20.0;

  final ImagePicker _picker = ImagePicker();
  late TextEditingController _descriptionController;
  bool _isSendingReport = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _setDefaultLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // --- LOGIKA LOKASI & ALAMAT (TIDAK ADA PERUBAHAN) ---
  Future<void> _setDefaultLocation() async {
    if (!mounted) return;
    setState(() {
      _isFetchingLocation = true;
      _currentAddress = "Mencari lokasi awal...";
      _currentCoordinates = "Mencari...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw Exception('Izin lokasi ditolak.');
      }
      if (permission == LocationPermission.deniedForever)
        throw Exception('Izin lokasi ditolak permanen.');

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _currentPosition = newPosition;
        _currentCoordinates =
            "${newPosition.latitude.toStringAsFixed(5)}, ${newPosition.longitude.toStringAsFixed(5)}";
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(newPosition, 15.0);
      });
      await _getAddressFromLatLng(newPosition);
    } catch (e) {
      print('Gagal dapat lokasi awal: $e');
      if (!mounted) return;
      setState(() {
        _currentPosition = _initialCenter;
        _currentCoordinates = "Lokasi Tidak Ditemukan";
        _currentAddress = e.toString().contains("Exception: ")
            ? e.toString().split("Exception: ")[1]
            : "Gagal memuat lokasi.";
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(_initialCenter, _initialZoom);
      });
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _getCurrentLocationAndPin() async {
    if (_isSendingReport || _isFetchingLocation) return;
    await _setDefaultLocation();
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (!mounted) return;
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].whereType<String>().where((part) => part.isNotEmpty).toList();

        String formattedAddress = addressParts.join(', ');

        setState(() => _currentAddress = formattedAddress.isEmpty
            ? "Detail alamat tidak tersedia."
            : formattedAddress);
      } else {
        setState(() => _currentAddress = "Alamat tidak ditemukan.");
      }
    } catch (e) {
      print('Error geocoding: $e');
      if (!mounted) return;
      setState(() => _currentAddress = "Gagal mendapatkan alamat.");
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    if (!mounted || _isFetchingLocation) return;
    setState(() {
      _isFetchingLocation = true;
      _currentPosition = latLng;
      _currentCoordinates =
          "${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}";
      _currentAddress = "Memuat alamat...";
    });
    _getAddressFromLatLng(latLng).whenComplete(() {
      if (mounted) setState(() => _isFetchingLocation = false);
    });
  }

  // --- FUNGSI BOTTOM SHEET ---
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
                    Center(
                        child: Text('Laporkan',
                            style: CustomTextStyles.boldXl
                                .copyWith(color: CustomColors.primary900))),
                    const SizedBox(height: 20),
                    // ... (UI Form lainnya tidak ada perubahan)
                    Text('Alamat Laporan',
                        style: CustomTextStyles.mediumBase
                            .copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 4),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: CustomColors.secondary200),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(address,
                            style: CustomTextStyles.regularBase
                                .copyWith(color: CustomColors.secondary500))),
                    const SizedBox(height: 16),
                    Text('Koordinat',
                        style: CustomTextStyles.mediumBase
                            .copyWith(color: CustomColors.secondary400)),
                    const SizedBox(height: 4),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: CustomColors.secondary200),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                            style: CustomTextStyles.regularBase
                                .copyWith(color: CustomColors.secondary500))),
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
                                borderSide: BorderSide(
                                    color: CustomColors.secondary200)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: CustomColors.primary500,
                                    width: 1.5)),
                            contentPadding: const EdgeInsets.all(12)),
                        style: CustomTextStyles.regularBase
                            .copyWith(color: CustomColors.secondary500)),
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
                                  border: Border.all(
                                      color: CustomColors.secondary200),
                                  borderRadius: BorderRadius.circular(8)),
                              child: _selectedImageInBottomSheet == null
                                  ? Center(
                                      child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 50,
                                          color: CustomColors.secondary300))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(7.0),
                                      child: Image.file(
                                          File(_selectedImageInBottomSheet!
                                              .path),
                                          fit: BoxFit.cover))),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                              icon: Icon(Icons.camera_alt_outlined,
                                  color: CustomColors.tertiary50, size: 20),
                              label: Text('Upload Gambar',
                                  style: CustomTextStyles.mediumSm.copyWith(
                                      color: CustomColors.tertiary50)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.primary500,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20))),
                              onPressed: () async {
                                final XFile? image = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 70);
                                if (image != null) {
                                  setStateBottomSheet(() =>
                                      _selectedImageInBottomSheet = image);
                                }
                              }),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                child: Text('Batal',
                                    style: CustomTextStyles.boldSm.copyWith(
                                        color: CustomColors.secondary400)),
                                onPressed: () =>
                                    Navigator.of(builderContext).pop())),
                        const SizedBox(width: 16),
                        Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.primary500,
                                    foregroundColor: CustomColors.tertiary50,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    textStyle: CustomTextStyles.boldSm),
                                onPressed: _isSendingReport
                                    ? null
                                    : () async {
                                        // Validasi gambar
                                        if (_selectedImageInBottomSheet == null) {
                                          if (!mainScreenContext.mounted) return;
                                          ScaffoldMessenger.of(mainScreenContext)
                                              .showSnackBar(SnackBar(
                                                  content: const Text(
                                                      'Mohon pilih gambar bukti terlebih dahulu!'),
                                                  backgroundColor: Colors.orange));
                                          return;
                                        }

                                        setStateBottomSheet(() => _isSendingReport = true);
                                        if (mounted) setState(() => _isSendingReport = true);

                                        // Cek user session
                                        final SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        final int? pelaporId = prefs.getInt('user_id');

                                        if (pelaporId == null) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(mainScreenContext)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Sesi pengguna tidak valid. Mohon login ulang.'),
                                                  backgroundColor: Colors.red));
                                          setStateBottomSheet(() => _isSendingReport = false);
                                          if (mounted) setState(() => _isSendingReport = false);
                                          return;
                                        }

                                        // ======================================================
                                        // ===== AWAL PERUBAHAN: LOGIKA UPLOAD MULTIPART/FORM-DATA =====
                                        // ======================================================

                                        const String apiUrl = 'https://broadly-neutral-osprey.ngrok-free.app/api/laporan'; // GANTI DENGAN URL API ANDA

                                        // Di dalam onPressed tombol "Kirim Laporan"

try {
  const String apiUrl = 'https://broadly-neutral-osprey.ngrok-free.app/api/laporan';
  var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

  // Data teks tetap sama
  request.fields['alamat'] = address;
  request.fields['koordinatLatitude'] = position.latitude.toString();
  request.fields['koordinatLongitude'] = position.longitude.toString();
  request.fields['description'] = _descriptionController.text;
  request.fields['pelaporId'] = pelaporId.toString();

  // ===== AWAL PERUBAHAN =====

  // 1. Dapatkan path file
  final String filePath = _selectedImageInBottomSheet!.path;

  // 2. Dapatkan Tipe MIME dari path file menggunakan paket 'mime'
  // Jika tidak terdeteksi, gunakan 'application/octet-stream' sebagai cadangan
  final String? mimeType = lookupMimeType(filePath);
  final mediaType = MediaType.parse(mimeType ?? 'application/octet-stream');

  // 3. Tambahkan file beserta Tipe MIME yang sudah benar
  request.files.add(
    await http.MultipartFile.fromPath(
      'imageUrl',
      filePath,
      contentType: mediaType, // <-- TAMBAHKAN contentType SECARA EKSPLISIT
    )
  );

  // ===== AKHIR PERUBAHAN =====

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (!mainScreenContext.mounted) return;

  final Map<String, dynamic> responseData = jsonDecode(response.body);

  if (response.statusCode == 201 && responseData['success'] == true) {
    Navigator.of(builderContext).pop();
    ScaffoldMessenger.of(mainScreenContext).showSnackBar(SnackBar(
      content: Text(responseData['message'] ?? 'Laporan berhasil dikirim!'),
      backgroundColor: Colors.green
    ));
  } else {
    ScaffoldMessenger.of(mainScreenContext).showSnackBar(SnackBar(
      content: Text(responseData['error'] ?? 'Gagal mengirim laporan. Status: ${response.statusCode}'),
      backgroundColor: Colors.red
    ));
  }
} catch (e) {
  if (!mainScreenContext.mounted) return;
  ScaffoldMessenger.of(mainScreenContext).showSnackBar(SnackBar(
    content: Text('Terjadi kesalahan jaringan: ${e.toString()}'),
    backgroundColor: Colors.red
  ));
} finally {
  setStateBottomSheet(() => _isSendingReport = false);
  if (mounted) setState(() => _isSendingReport = false);
}
                                        // ====================================================
                                        // ===== AKHIR PERUBAHAN: LOGIKA UPLOAD =====
                                        // ====================================================
                                      },
                                child: _isSendingReport
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('Kirim Laporan'))),
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
    // --- UI Build Method (TIDAK ADA PERUBAHAN) ---
    const double navigationBarHeight = 70.0;
    final double navBarClearance = navigationBarHeight + _fabBottomPadding;
    const double reportButtonHeight = 50.0;
    const double reportButtonWidth = 280.0;
    final double reportButtonHorizontalMargin =
        (MediaQuery.of(context).size.width - reportButtonWidth) / 2;
    final double reportButtonBottomOffset = navBarClearance + 30.0;
    final double rightFabsBottomOffset =
        reportButtonBottomOffset + reportButtonHeight + 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporkan Masalah',
            style: CustomTextStyles.boldLg
                .copyWith(color: CustomColors.tertiary50)),
        backgroundColor: CustomColors.primary500,
        elevation: 1.0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: _initialZoom,
                onTap: _onMapTap),
            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pui'),
              if (_currentPosition != null)
                MarkerLayer(markers: [
                  Marker(
                      point: _currentPosition!,
                      width: 80,
                      height: 80,
                      child:
                          Icon(Icons.fmd_good, color: Colors.red, size: 45.0))
                ]),
            ],
          ),
          Positioned(
            top: 10,
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
                    Row(children: [
                      Icon(Icons.gps_fixed,
                          color: CustomColors.primary500, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _isFetchingLocation
                              ? Text('Mencari...',
                                  style: CustomTextStyles.boldSm.copyWith(
                                      color: CustomColors.secondary300))
                              : Text(_currentCoordinates,
                                  style: CustomTextStyles.boldSm.copyWith(
                                      color: CustomColors.primary500)))
                    ]),
                    const SizedBox(height: 6),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: CustomColors.secondary500, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _isFetchingLocation
                                  ? Text('Memuat alamat...',
                                      style: CustomTextStyles.regularXs
                                          .copyWith(
                                              color:
                                                  CustomColors.secondary300))
                                  : Text(_currentAddress,
                                      style: CustomTextStyles.regularXs
                                          .copyWith(
                                              color: CustomColors.secondary500,
                                              height: 1.4),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis))
                        ]),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: reportButtonBottomOffset,
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
                    textStyle: CustomTextStyles.boldLg),
                onPressed: (_isSendingReport ||
                        _isFetchingLocation ||
                        _currentPosition == null)
                    ? null
                    : () {
                        _showReportBottomSheet(
                            context, _currentPosition!, _currentAddress);
                      },
                child: (_isSendingReport || _isFetchingLocation)
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
            bottom: rightFabsBottomOffset,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                    heroTag: "fabLihatLaporan",
                    mini: true,
                    backgroundColor: CustomColors.tertiary50,
                    elevation: 3,
                    onPressed: (_isSendingReport || _isFetchingLocation)
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LihatLaporanScreen())),
                    child: Icon(Icons.list_alt_outlined,
                        color: CustomColors.primary500)),
                const SizedBox(height: 16),
                FloatingActionButton(
                    heroTag: "fabLokasiSaya",
                    mini: true,
                    backgroundColor: CustomColors.tertiary50,
                    elevation: 3,
                    onPressed: (_isSendingReport || _isFetchingLocation)
                        ? null
                        : _getCurrentLocationAndPin,
                    child: Icon(Icons.my_location,
                        color: CustomColors.primary500)),
              ],
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