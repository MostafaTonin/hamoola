import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Production-ready utility to launch phone calls and WhatsApp chats
/// with resilient fallback and user feedback.
class CommunicationLauncher {
  // Official company contact numbers
  static const String tollFreeNumber = '800002026';
  static const String tollFreeDisplay = '800002026';
  static const String whatsAppRawNumber = '783707104';
  static const String whatsAppInternational = '967783707104';
  static const String whatsAppDisplay = '+967 783 707 104';

  /// Opens the device phone dialer with the company toll-free or specified number
  static Future<bool> makePhoneCall(
    BuildContext? context, {
    String phoneNumber = tollFreeNumber,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);

    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        launched = await launchUrl(uri);
      }
    } catch (_) {
      launched = false;
    }

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            launched
                ? 'جاري فتح تطبيق الاتصال: $phoneNumber'
                : 'الاتصال برقم خدمة العملاء: $phoneNumber',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return launched;
  }

  /// Opens WhatsApp directly targeting the company official WhatsApp or specified phone
  static Future<bool> openWhatsApp(
    BuildContext? context, {
    String phoneNumber = whatsAppInternational,
    String message = 'مرحباً، أحتاج إلى مساعدة واستفسار بخصوص منصة حمولة',
  }) async {
    // Ensure international format without + or dashes
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '967${cleanPhone.substring(1)}';
    } else if (cleanPhone.length == 9 && cleanPhone.startsWith('7')) {
      cleanPhone = '967$cleanPhone';
    }

    final encodedMsg = Uri.encodeComponent(message);
    final universalUrl = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMsg');
    final nativeUrl = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMsg');

    bool launched = false;
    try {
      if (await canLaunchUrl(universalUrl)) {
        launched = await launchUrl(
          universalUrl,
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(nativeUrl)) {
        launched = await launchUrl(
          nativeUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        launched = await launchUrl(universalUrl);
      }
    } catch (_) {
      launched = false;
    }

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            launched
                ? 'جاري التحويل إلى محادثة واتساب الرسمية (783707104)...'
                : 'فتح محادثة واتساب خدمة العملاء: $whatsAppDisplay',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return launched;
  }
}
