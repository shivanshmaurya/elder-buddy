import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/contact_tile_model.dart';
import '../../../storage/photo_storage_service.dart';

class AddContactDialog extends StatefulWidget {
  final Contact contact;
  final String phoneNumber;

  const AddContactDialog({
    super.key,
    required this.contact,
    required this.phoneNumber,
  });

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  bool _isSaving = false;

  Future<void> _saveContact() async {
    setState(() => _isSaving = true);

    // Save photo if available
    String? photoPath;
    final photoBytes = widget.contact.photo;
    if (photoBytes != null && photoBytes.isNotEmpty) {
      photoPath = await PhotoStorageService.savePhoto(
        photoBytes,
        widget.phoneNumber,
      );
    }

    final contact = ContactTileModel(
      nickname: widget.contact.displayName, // Use real name as nickname too
      realName: widget.contact.displayName,
      phoneNumber: widget.phoneNumber,
      photoPath: photoPath,
    );

    if (mounted) {
      Navigator.pop(context, contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final photoBytes = widget.contact.photo;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Contact',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Contact photo preview
              Center(
                child: _buildPhotoPreview(photoBytes, isDark),
              ),
              const SizedBox(height: 16),

              // Contact info display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.contact.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.phoneNumber,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirmation text
              Text(
                'Add this contact to your home screen?',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(Uint8List? photoBytes, bool isDark) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      backgroundImage: photoBytes != null && photoBytes.isNotEmpty
          ? MemoryImage(photoBytes)
          : null,
      child: photoBytes == null || photoBytes.isEmpty
          ? Icon(
              Icons.person,
              size: 50,
              color: isDark ? Colors.white : Colors.black,
            )
          : null,
    );
  }
}
