import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/contact_picker_dialog.dart';

class ContactPickerService {
  static Future<Contact?> pickContact(BuildContext context) async {
    // Request permission using permission_handler
    final status = await Permission.contacts.request();

    if (status.isDenied) {
      if (context.mounted) {
        _showPermissionDeniedDialog(context);
      }
      return null;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showOpenSettingsDialog(context);
      }
      return null;
    }

    if (!status.isGranted) {
      debugPrint('Contacts permission not granted: $status');
      return null;
    }

    // Get all contacts
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    // Return null if empty
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No contacts found on this device',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }
      return null;
    }

    if (!context.mounted) return null;

    // Show the contact picker dialog
    final selectedContact = await showDialog<Contact?>(
      context: context,
      builder: (context) => ContactPickerDialog(contacts: contacts),
    );

    return selectedContact;
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Permission Needed',
          style: TextStyle(fontSize: 24),
        ),
        content: const Text(
          'To add contacts, please allow access to your contacts.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  static void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Permission Required',
          style: TextStyle(fontSize: 24),
        ),
        content: const Text(
          'Contacts permission was denied. Please enable it in Settings to add contacts.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
