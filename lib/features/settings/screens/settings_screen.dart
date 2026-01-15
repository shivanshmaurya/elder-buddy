import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../call/services/tts_service.dart';
import '../../contacts/contact_picker_service.dart';
import '../../contacts/widgets/phone_number_picker_dialog.dart';
import '../../contacts/widgets/add_contact_dialog.dart';
import '../../contacts/models/contact_tile_model.dart';
import '../../../storage/contact_storage_service.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ContactTileModel)? onContactAdded;

  const SettingsScreen({
    super.key,
    this.onContactAdded,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _ttsEnabled = true;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _loadTtsState();
  }

  Future<void> _loadTtsState() async {
    final enabled = await TtsService.isEnabled();
    if (mounted) {
      setState(() => _ttsEnabled = enabled);
    }
  }

  Future<void> _toggleTts(bool enabled) async {
    HapticFeedback.selectionClick();
    setState(() => _ttsEnabled = enabled);
    await TtsService.setEnabled(enabled);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _testTts() async {
    HapticFeedback.lightImpact();
    // Force speak for testing even if disabled
    await TtsService.speakForce(
        'Hello! This is a test of the text to speech feature.');
  }

  Future<void> _addContact() async {
    HapticFeedback.mediumImpact();

    final contact = await ContactPickerService.pickContact(context);
    if (contact == null || !mounted) return;

    if (contact.phones.isEmpty) {
      _showSnackBar('This contact has no phone number');
      return;
    }

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

    final existingContacts = await ContactStorageService.loadContacts();
    if (existingContacts.any((c) => c.phoneNumber == phoneNumber)) {
      _showSnackBar('This contact is already added');
      return;
    }

    final newContact = await showDialog<ContactTileModel>(
      context: context,
      builder: (context) => AddContactDialog(
        contact: contact,
        phoneNumber: phoneNumber!,
      ),
    );

    if (newContact == null || !mounted) return;

    final success = await ContactStorageService.addContact(newContact);
    if (success) {
      widget.onContactAdded?.call(newContact);
      TtsService.speak('${newContact.realName} added');
      _showSnackBar('${newContact.realName} added successfully');
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
        backgroundColor: AppTheme.cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Add Contact Button
              _buildAnimatedSection(
                delay: 0,
                child: _buildAddContactSection(),
              ),
              const SizedBox(height: 28),

              // Quick Actions Grid
              _buildAnimatedSection(
                delay: 100,
                child: _buildQuickActionsGrid(),
              ),
              const SizedBox(height: 28),

              // About Section
              _buildAnimatedSection(
                delay: 200,
                child: _buildAboutSection(),
              ),
              const SizedBox(height: 28),

              // Help Section
              _buildAnimatedSection(
                delay: 300,
                child: _buildHelpSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _GlassBackButton(onPressed: () => Navigator.pop(context)),
      title: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLight,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.settings,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAddContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.person_add, color: AppTheme.accentCyan, size: 22),
            SizedBox(width: 8),
            Text(
              'Manage Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _GradientActionButton(
          onPressed: _addContact,
          icon: Icons.person_add,
          label: 'ADD NEW CONTACT',
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.grid_view, color: AppTheme.accentCyan, size: 22),
            SizedBox(width: 8),
            Text(
              'Quick Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.record_voice_over,
                label: 'Voice',
                sublabel: _ttsEnabled ? 'On' : 'Off',
                isActive: _ttsEnabled,
                onTap: () => _toggleTts(!_ttsEnabled),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.play_circle,
                label: 'Test',
                sublabel: 'Voice',
                onTap: _testTts,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.phone_in_talk,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Easy Call',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'A simple calling app designed for elderly users with large buttons and easy-to-read text.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_outline, color: AppTheme.accentCyan, size: 22),
                SizedBox(width: 8),
                Text(
                  'How to Use',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _HelpStep(
              number: '1',
              text: 'Tap "ADD NEW CONTACT" to add someone.',
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 14),
            _HelpStep(
              number: '2',
              text: 'Tap a contact tile to call them.',
              color: AppTheme.deepPurple,
            ),
            const SizedBox(height: 14),
            _HelpStep(
              number: '3',
              text: 'Hold & drag to reorder. Hold 5s for delete bin.',
              color: AppTheme.accentCyan,
            ),
          ],
        ),
      ),
    );
  }
}

// Glass-style back button
class _GlassBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _GlassBackButton({required this.onPressed});

  @override
  State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: _isPressed
              ? AppTheme.accentGradient
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed
                ? AppTheme.accentCyan
                : Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          color: _isPressed ? Colors.white : AppTheme.accentCyan,
          size: 24,
        ),
      ),
    );
  }
}

// Gradient action button
class _GradientActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _GradientActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<_GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<_GradientActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 68,
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(_isPressed ? 0.6 : 0.35),
              blurRadius: _isPressed ? 25 : 15,
              offset: const Offset(0, 8),
              spreadRadius: _isPressed ? 2 : 0,
            ),
          ],
        ),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 26),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quick action card
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: widget.isActive || _isPressed
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.4),
                    AppTheme.deepPurple.withOpacity(0.3),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isActive || _isPressed
                ? AppTheme.accentCyan.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              widget.icon,
              size: 32,
              color: widget.isActive ? AppTheme.accentCyan : AppTheme.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color:
                    widget.isActive ? AppTheme.textLight : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.sublabel,
              style: TextStyle(
                fontSize: 12,
                color: widget.isActive
                    ? AppTheme.accentCyan
                    : AppTheme.textMuted.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Glass card
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardDark.withOpacity(0.95),
                AppTheme.cardDarkLight.withOpacity(0.85),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Help step widget
class _HelpStep extends StatelessWidget {
  final String number;
  final String text;
  final Color color;

  const _HelpStep({
    required this.number,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
