import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchResult {
  final String title;
  final String subtitle;
  final LatLng location;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.location,
  });
}
