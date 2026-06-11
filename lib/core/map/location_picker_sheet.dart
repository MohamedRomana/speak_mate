// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:collection';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/colors.dart';
import '../helper/extentions.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../../gen/fonts.gen.dart';
import '../../generated/locale_keys.g.dart';
import 'location_helper.dart';

/// منتقي موقع عام: المستخدم يختار نقطة على الخريطة، وعند التأكيد
/// بيرجّع (lat, lng, address) عبر [onConfirm]. قابل لإعادة الاستخدام في أي شاشة.
class LocationPickerSheet extends StatefulWidget {
  final void Function(double lat, double lng, String address) onConfirm;
  const LocationPickerSheet({super.key, required this.onConfirm});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  Position? position;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final myMarkers = HashSet<Marker>();
  double? _lat;
  double? _lng;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    position = await LocationHelper.determinePosition();
    if (mounted) setState(() {});
  }

  Future<void> _pickPoint(LatLng point) async {
    myMarkers.clear();
    String address = '';
    try {
      final placeMarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placeMarks.isNotEmpty) {
        final p = placeMarks.first;
        address = [
          p.street,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((e) => e != null && e.trim().isNotEmpty).join('، ');
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
      _address = address;
      myMarkers.add(
        Marker(
          markerId: const MarkerId('picked'),
          position: point,
          infoWindow: InfoWindow(title: address),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: position == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(position!.latitude, position!.longitude),
                  zoom: 15,
                ),
                onTap: _pickPoint,
                onMapCreated: (controller) async {
                  _controller.complete(controller);
                  await _pickPoint(
                    LatLng(position!.latitude, position!.longitude),
                  );
                },
                markers: myMarkers,
              ),
              PositionedDirectional(
                top: 16.h,
                end: 16.w,
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  mini: true,
                  onPressed: () => context.pop(),
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 50.h,
                right: 16.w,
                left: 16.w,
                child: AppButton(
                  width: 311.w,
                  color: AppColors.secondray,
                  onPressed: () {
                    if (_lat == null || _lng == null) {
                      context.pop();
                      return;
                    }
                    widget.onConfirm(_lat!, _lng!, _address);
                    context.pop();
                  },
                  child: AppText(
                    text: LocaleKeys.confirmLocation.tr(),
                    size: 21.sp,
                    color: Colors.white,
                    family: FontFamily.tajawalBold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
