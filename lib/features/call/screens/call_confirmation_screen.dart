import 'dart:io';
import 'package:flutter/material.dart';
import '../../contacts/models/contact_tile_model.dart';
import '../services/tts_service.dart';
import '../services/direct_call_service.dart';

class CallConfirmationScreen extends StatefulWidget {
  final ContactTileModel contact;

  const CallConfirmationScreen({
    super.key,
    required this.contact,
  });

  @override
  State<CallConfirmationScreen> createState() => _CallConfirmationScreenState();
}

class _CallConfirmationScreenState extends State<CallConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Speak the confirmation message
    TtsService.speakCallConfirmation(widget.contact.nickname);
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  Future<void> _makeCall() async {
    try {
      final success =
          await DirectCallService.makeCall(widget.contact.phoneNumber);

      if (success) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showCallError();
      }
    } catch (e) {
      _showCallError();
    }
  }

  void _showCallError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not make call. Please check your phone app.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
  }

  void _cancel() {
    TtsService.stop();
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Call'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contact photo
              _buildPhoto(),
              const SizedBox(height: 32),

              // Contact info
              Text(
                widget.contact.nickname,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.contact.realName != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.contact.realName!,
                  style: TextStyle(
                    fontSize: 24,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                widget.contact.phoneNumber,
                style: TextStyle(
                  fontSize: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Confirmation message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Are you sure you want to call?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: ElevatedButton(
                        onPressed: _cancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Call button
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: ElevatedButton(
                        onPressed: _makeCall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'CALL',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  Widget _buildPhoto() {
    return CircleAvatar(
      radius: 80,
      backgroundImage: widget.contact.photoPath != null
          ? FileImage(File(widget.contact.photoPath!))
          : null,
      child: widget.contact.photoPath == null
          ? const Icon(Icons.person, size: 80)
          : null,
    );
  }
}
