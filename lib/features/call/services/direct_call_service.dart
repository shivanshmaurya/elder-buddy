import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectCallService {
  static const MethodChannel _channel =
      MethodChannel('com.easycall/direct_call');

  /// Make a direct phone call (requires CALL_PHONE permission)
  static Future<bool> makeCall(String phoneNumber) async {
    // Clean the phone number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Request CALL_PHONE permission
    final status = await Permission.phone.request();

    if (!status.isGranted) {
      // Fall back to dialer if permission denied
      return _openDialer(cleanNumber);
    }

    try {
      // Try native direct call
      final result = await _channel.invokeMethod<bool>('makeCall', {
        'phoneNumber': cleanNumber,
      });
      return result ?? false;
    } on PlatformException {
      // Fall back to dialer if native call fails
      return _openDialer(cleanNumber);
    } on MissingPluginException {
      // Fall back to dialer if plugin not implemented
      return _openDialer(cleanNumber);
    }
  }

  static Future<bool> _openDialer(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
}
