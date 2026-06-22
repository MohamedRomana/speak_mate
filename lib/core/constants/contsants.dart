import 'package:url_launcher/url_launcher.dart';

String? token;
String? userId;
const String baseUrl =
    "https://drive.google.com/file/d/1WNilV-Ve87c87OSdAf4F9NdIrxJidkZF/view?usp=drivesdk";
void openGoogleMap(double lat, double lng) async {
  Uri googleMapUrl = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
  );

  if (!await launchUrl(googleMapUrl)) {
    throw Exception('Could not launch $googleMapUrl');
  } else {
    throw 'Could not open the map.';
  }
}

Future<void> openCall(String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}

Future<void> openWhatsApp(String phoneNumber) async {
  final Uri launchUri = Uri.parse("https://wa.me/$phoneNumber");
  await launchUrl(launchUri);
}
