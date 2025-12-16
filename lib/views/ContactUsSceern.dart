import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

// Import the rich ContactUsModel from your app_policy_model.dart
import 'package:new_packers_application/lib/models/app_policy_model.dart';
import 'package:new_packers_application/lib/constant/app_color.dart'; // Assuming AppColor is defined here

// --- Utility function to launch URLs (Unchanged) ---
Future<void> _launchUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // Fail silently or log error, avoiding alerts/snackbars here
    debugPrint('Could not launch $url');
  }
}

class ContactUsScreen extends StatelessWidget {
  // Accept the fully populated ContactUsModel object via the constructor
  final ContactUsModel contactData;

  const ContactUsScreen({super.key, required this.contactData});

  // Define a consistent color scheme
  static const Color primaryColor =
      Color(0xFF1976D2); // Example for AppColor.darkBlue

  // Helper for opening maps (using the address)
  void _openInMaps(String address) {
    if (address.isEmpty) return;
    final encodedAddress = Uri.encodeComponent(address);
    final mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    _launchUrl(mapUrl);
  }

  // Helper for making calls
  void _makeCall(String phoneNumber) {
    if (phoneNumber.isEmpty) return;
    final uri = Uri.parse('tel:$phoneNumber');
    launchUrl(uri);
  }

  // Helper for WhatsApp chat
  void _openWhatsApp(String phoneNumber) {
    if (phoneNumber.isEmpty) return;
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[+\s]'), '');
    final whatsappUrl = 'whatsapp://send?phone=$cleanNumber';
    _launchUrl(whatsappUrl);
  }

  // Helper for sending email
  void _sendEmail(String email) {
    if (email.isEmpty) return;
    final uri = Uri.parse('mailto:$email');
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    // The main scaffold with AppBar matching the original
    return Scaffold(
      appBar: AppBar(
        title: Text(
          contactData.title.isNotEmpty ? contactData.title : 'Contact Us',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColor.darkBlue, // Use your defined AppColor
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Logo and Header ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/applogo.jpeg', // Use a consistent logo asset
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "MUMBAI METRO\nPACKERS AND MOVERS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'GET IN TOUCH',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),
            const SizedBox(height: 20),

            // --- Office Address Section ---
            _buildAddressSection(context, contactData, AppColor.darkBlue),

            const SizedBox(height: 30),

            // --- Sales and Support Cards ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sales Card (using contact1/email)
                Expanded(
                  child: _buildContactCard(
                    context,
                    title: 'Sales',
                    phone: contactData.contact1,
                    // Using contact1 for Sales phone
                    email: contactData.email,
                    // Using email for Sales email
                    primaryColor: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(width: 15),
                // Support Card (using contact2/email2)
                Expanded(
                  child: _buildContactCard(
                    context,
                    title: 'Support',
                    phone: contactData.contact2,
                    // Using contact2 for Support phone
                    email: contactData.email2,
                    // Using email2 for Support email
                    primaryColor: AppColor.darkBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- Follow & Connect With Us Section ---
            const Text(
              'Follow & Connect With Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            _buildSocialMediaRow(contactData, AppColor.darkBlue),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widget Builders ---

  Widget _buildAddressSection(
      BuildContext context, ContactUsModel data, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Our Office Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Text(
            data.address,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.map,
                text: 'Open in Maps',
                color: primaryColor,
                onPressed: () {
                  if (data.mapLocationLink.isNotEmpty) {
                    _launchUrl(data.mapLocationLink);
                  } else {
                    _openInMaps(data.address);
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.share,
                text: 'Share App',
                color: primaryColor,
                onPressed: () {
                  debugPrint('Share App button pressed');
                  if (data.shareAppLink.isNotEmpty) {
                    Share.share(data.shareAppLink);
                  } else {
                    debugPrint('Share link is empty!');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share link is not available')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String phone,
    required String email,
    required Color primaryColor,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.call, color: primaryColor, size: 20),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Phone Button
        _buildPhoneEmailButton(
          icon: Icons.phone,
          text: phone,
          backgroundColor: primaryColor,
          onPressed: () => _makeCall(phone),
        ),
        const SizedBox(height: 15),
        // Email Link
        InkWell(
          onTap: () => _sendEmail(email),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${title} email ID\n',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: email,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        // WhatsApp Button
        _buildPhoneEmailButton(
          icon: Icons.chat, // Using chat icon for WhatsApp
          text: 'WhatsApp Chat',
          backgroundColor: Colors.green, // WhatsApp color
          onPressed: () => _openWhatsApp(phone),
        ),
      ],
    );
  }

  Widget _buildPhoneEmailButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaRow(ContactUsModel data, Color primaryColor) {
    final socialLinks = [
      {'url': data.facebook, 'icon': data.facebookIcon},
      {'url': data.instagram, 'icon': data.instagramIcon},
      {'url': data.twitter, 'icon': data.twitterIcon},
      {'url': data.linkedin, 'icon': data.linkedinIcon},
      {'url': data.youtube, 'icon': data.youtubeIcon},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: socialLinks.map((entry) {
        final url = entry['url'] as String;
        final iconUrl = entry['icon'] as String;

        // Only build if we have a valid icon URL
        if (url.isNotEmpty && iconUrl.isNotEmpty) {
          return _buildSocialNetworkIcon(
            imageUrl: iconUrl,
            url: url,
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildSocialNetworkIcon(
      {required String imageUrl, required String url}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to a generic icon if network image fails
                return const Icon(Icons.link, size: 20, color: Colors.grey);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Keep the original _buildSocialIcon if you need it elsewhere, otherwise it can be removed ---
  Widget _buildSocialIcon({
    required IconData icon,
    required String url,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: url.isNotEmpty ? () => _launchUrl(url) : null,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
