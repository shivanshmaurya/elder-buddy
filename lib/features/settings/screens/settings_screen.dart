import 'package:flutter/material.dart';
import '../../call/services/tts_service.dart';
import '../../contacts/contact_picker_service.dart';
import '../../contacts/widgets/phone_number_picker_dialog.dart';
import '../../contacts/widgets/add_contact_dialog.dart';
import '../../contacts/models/contact_tile_model.dart';
import '../../../storage/contact_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ContactTileModel)? onContactAdded;

  const SettingsScreen({
    super.key,
    this.onContactAdded,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _ttsEnabled = true;

  void _testTts() async {
    await TtsService.speak(
        'Hello! This is a test of the text to speech feature.');
  }

  Future<void> _addContact() async {
    // Pick a contact from phone
    final contact = await ContactPickerService.pickContact(context);
    if (contact == null || !mounted) return;

    if (contact.phones.isEmpty) {
      _showSnackBar('This contact has no phone number');
      return;
    }

    // Get phone number (show picker if multiple)
    String? phoneNumber;
    if (contact.phones.length == 1) {
      phoneNumber = contact.phones.first.number;
    } else {
      phoneNumber = await showDialog<String>(
        context: context,
        builder: (context) => PhoneNumberPickerDialog(contact: contact),
      );
    }

    if (phoneNumber == null || !mounted) return;

    // Check if already exists
    final existingContacts = await ContactStorageService.loadContacts();
    if (existingContacts.any((c) => c.phoneNumber == phoneNumber)) {
      _showSnackBar('This contact is already added');
      return;
    }

    // Show add contact dialog for nickname
    final newContact = await showDialog<ContactTileModel>(
      context: context,
      builder: (context) => AddContactDialog(
        contact: contact,
        phoneNumber: phoneNumber!,
      ),
    );

    if (newContact == null || !mounted) return;

    // Save to storage
    final success = await ContactStorageService.addContact(newContact);
    if (success) {
      widget.onContactAdded?.call(newContact);
      TtsService.speak('${newContact.nickname} added');
      _showSnackBar('${newContact.nickname} added successfully');
    } else {
      _showSnackBar('Failed to add contact');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Add Contact Button - Prominent at the top
          _buildSectionHeader('Manage Contacts', isDark),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ElevatedButton.icon(
              onPressed: _addContact,
              icon: const Icon(Icons.person_add, size: 32),
              label: const Text(
                'ADD CONTACT',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // App Info Section
          _buildSectionHeader('About Easy Call', isDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Easy Call',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A simple calling app designed for elderly users with large buttons and easy-to-read text.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Accessibility Section
          _buildSectionHeader('Accessibility', isDark),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Voice Feedback',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    'Speak contact names when selected',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _ttsEnabled,
                  onChanged: (value) {
                    setState(() => _ttsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Test Voice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    'Play a sample voice message',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.play_arrow, size: 28),
                  onTap: _testTts,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Help Section
          _buildSectionHeader('How to Use', isDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem(
                  '1.',
                  'Go to Settings and tap "ADD CONTACT" to add someone from your phone contacts.',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  '2.',
                  'Tap on a contact to call them. You\'ll see a confirmation screen first.',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  '3.',
                  'Press and hold a contact to remove them from the list.',
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Theme Info
          _buildSectionHeader('Display', isDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'The app automatically adjusts to your phone\'s light or dark mode setting.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildHelpItem(String number, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
