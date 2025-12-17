import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_packers_application/lib/constant/app_color.dart';
import '../models/search_result.dart'; // Ensure correct import path relative to widgets dir or package

class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(SearchResult) onLocationSelected;
  final String hintText;

  const LocationAutocompleteField({
    Key? key,
    required this.controller,
    required this.onLocationSelected,
    this.label = 'Society / Area',
    this.hintText = 'Search Society / Area',
  }) : super(key: key);

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  bool _isSearching = false;
  List<SearchResult> _searchSuggestions = [];
  bool _showSuggestions = false;

  // Debounce logic can be added here or relied on parent/manual delay
  // For simplicity and matching existing logic, using logic similar to previous implementation

  Future<void> _searchLocationSuggestions(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchSuggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isSearching = true;
          _showSuggestions = true; // Show helper/loading
        });
      }

      List<Location> locations = await locationFromAddress(query);
      List<SearchResult> allSuggestions = [];

      Set<String> thisSearchUniqueLocations = {};

      for (Location loc in locations) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
            localeIdentifier: "en_IN",
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];

            List<String> titleParts = [];
            if (place.name != null && place.name!.isNotEmpty)
              titleParts.add(place.name!);
            if (place.street != null && place.street!.isNotEmpty)
              titleParts.add(place.street!);
            if (place.subThoroughfare != null &&
                place.subThoroughfare!.isNotEmpty)
              titleParts.add(place.subThoroughfare!);
            if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty)
              titleParts.add(place.thoroughfare!);
            if (place.subLocality != null && place.subLocality!.isNotEmpty)
              titleParts.add(place.subLocality!);
            if (place.locality != null && place.locality!.isNotEmpty)
              titleParts.add(place.locality!);
            if (place.subAdministrativeArea != null &&
                place.subAdministrativeArea!.isNotEmpty)
              titleParts.add(place.subAdministrativeArea!);
            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty)
              titleParts.add(place.administrativeArea!);
            if (place.postalCode != null && place.postalCode!.isNotEmpty)
              titleParts.add(place.postalCode!);
            String country = "";
            if (place.country != null && place.country!.isNotEmpty) {
              country = place.country!;
              titleParts.add(place.country!);
            }
            if (place.isoCountryCode != null &&
                place.isoCountryCode!.isNotEmpty)
              titleParts.add(place.isoCountryCode!);

            String title = titleParts.toSet().join(", ");

            List<String> subtitleParts = [];
            if (place.subLocality != null &&
                place.subLocality!.isNotEmpty &&
                place.subLocality != title) {
              subtitleParts.add(place.subLocality!);
            }
            if (place.locality != null &&
                place.locality!.isNotEmpty &&
                place.locality != title) {
              subtitleParts.add(place.locality!);
            }
            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty &&
                place.administrativeArea != title) {
              subtitleParts.add(place.administrativeArea!);
            }
            if (country.isNotEmpty) {
              subtitleParts.add(country);
            }

            String subtitle = subtitleParts.join(", ");
            // Use coordinate + name as key to deduplicate
            String uniqueKey =
                "${loc.latitude.toStringAsFixed(4)},${loc.longitude.toStringAsFixed(4)}-${title.toLowerCase()}";

            if (!thisSearchUniqueLocations.contains(uniqueKey) &&
                title.isNotEmpty) {
              thisSearchUniqueLocations.add(uniqueKey);
              allSuggestions.add(SearchResult(
                title: title,
                subtitle: subtitle.isNotEmpty ? subtitle : "Location",
                location: LatLng(loc.latitude, loc.longitude),
              ));
            }
          }
        } catch (e) {
          debugPrint("Error getting placemark for location: $e");
        }
      }

      if (mounted) {
        setState(() {
          _searchSuggestions = allSuggestions;
          _showSuggestions = allSuggestions.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint("Error searching location: $e");
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchSuggestions = [];
        });
      }
    }
  }

  void _selectSearchResult(SearchResult result) {
    widget.controller.text = result.title;
    widget.onLocationSelected(result);
    setState(() {
      _showSuggestions = false;
      _searchSuggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Assuming constants like whiteColor, mediumBlue, darkBlue are available or passed.
    // Using hardcoded standard ones or importing from existing constants if possible.
    // I need to import app_color.dart. Assuming path based on other files.

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: (value) {
            if (mounted) {
              // Simple debounce
              Future.delayed(const Duration(milliseconds: 500), () {
                if (widget.controller.text == value) {
                  _searchLocationSuggestions(value);
                }
              });
            }
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: const Color(0xFFf7f7f7), // whiteColor
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF37b3e7)), // mediumBlue
                borderRadius: BorderRadius.circular(10)),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search,
                    color: Color(0xFF37b3e7)), // mediumBlue
          ),
        ),
        if (_showSuggestions)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFf7f7f7), // whiteColor
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ]),
            child: _searchSuggestions.isEmpty && !_isSearching
                ? const SizedBox() // Should not happen if _showSuggestions is false when empty
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchSuggestions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final suggestion = _searchSuggestions[index];
                      return ListTile(
                        title: Text(suggestion.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(suggestion.subtitle),
                        onTap: () => _selectSearchResult(suggestion),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
