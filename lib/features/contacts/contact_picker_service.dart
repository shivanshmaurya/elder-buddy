import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/contact_picker_dialog.dart';

class ContactPickerService {
  static Future<Contact?> pickContact(BuildContext context) async {
    // Show loading overlay
    final loadingOverlay = _showLoadingOverlay(context);

    try {
      // Request permission using permission_handler
      final status = await Permission.contacts.request();

      if (status.isDenied) {
        loadingOverlay.remove();
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
        return null;
      }

      if (status.isPermanentlyDenied) {
        loadingOverlay.remove();
        if (context.mounted) {
          _showOpenSettingsDialog(context);
        }
        return null;
      }

      if (!status.isGranted) {
        loadingOverlay.remove();
        debugPrint('Contacts permission not granted: $status');
        return null;
      }

      // Get all contacts
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // Remove loading overlay
      loadingOverlay.remove();

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
    } catch (e) {
      loadingOverlay.remove();
      debugPrint('Error picking contact: $e');
      return null;
    }
  }

  static OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => const _LoadingOverlay(),
    );
    overlay.insert(entry);
    return entry;
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

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E2E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.cyanAccent
                                : Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading Contacts...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
