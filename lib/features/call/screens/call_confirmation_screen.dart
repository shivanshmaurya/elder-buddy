import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../contacts/models/contact_tile_model.dart';
import '../services/tts_service.dart';
import '../services/direct_call_service.dart';
import '../../../core/theme/app_theme.dart';

class CallConfirmationScreen extends StatefulWidget {
  final ContactTileModel contact;

  const CallConfirmationScreen({
    super.key,
    required this.contact,
  });

  @override
  State<CallConfirmationScreen> createState() => _CallConfirmationScreenState();
}

class _CallConfirmationScreenState extends State<CallConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _entranceController.forward();
    TtsService.speakCallConfirmation(
        widget.contact.realName ?? widget.contact.nickname);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _ringController.dispose();
    TtsService.stop();
    super.dispose();
  }

  Future<void> _makeCall() async {
    HapticFeedback.mediumImpact();
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
        SnackBar(
          content: const Text(
            'Could not make call. Please check your phone app.',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: AppTheme.cardDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _cancel() {
    HapticFeedback.lightImpact();
    TtsService.stop();
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                // Photo with animated rings
                _buildPhotoWithRings(),
                const SizedBox(height: 36),

                // Contact info
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContactInfo(),
                  ),
                ),

                const SizedBox(height: 36),

                // Confirmation card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildConfirmationCard(),
                ),

                const Spacer(),

                // Action buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildActionButtons(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoWithRings() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated rings
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _ringAnimation,
              builder: (context, child) {
                final delay = index * 0.3;
                final progress = (_ringAnimation.value - delay).clamp(0.0, 1.0);
                return Opacity(
                  opacity: (1 - progress) * 0.5,
                  child: Container(
                    width: 160 + (progress * 80),
                    height: 160 + (progress * 80),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentCyan.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Photo
          Hero(
            tag: 'contact_photo_${widget.contact.phoneNumber}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.contact.photoPath == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.4),
                          AppTheme.deepPurple.withOpacity(0.4),
                        ],
                      )
                    : null,
                border: Border.all(
                  color: AppTheme.accentCyan.withOpacity(0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.transparent,
                backgroundImage: widget.contact.photoPath != null
                    ? FileImage(File(widget.contact.photoPath!))
                    : null,
                child: widget.contact.photoPath == null
                    ? const Icon(
                        Icons.person,
                        size: 70,
                        color: AppTheme.accentCyan,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    final displayName = widget.contact.realName ?? widget.contact.nickname;

    return Column(
      children: [
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phone,
                size: 18,
                color: AppTheme.accentCyan.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                widget.contact.phoneNumber,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted.withOpacity(0.9),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Ready to call?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: _ActionButton(
            onPressed: _cancel,
            gradient: AppTheme.cancelButtonGradient,
            icon: Icons.close,
            label: 'CANCEL',
          ),
        ),
        const SizedBox(width: 16),
        // Call button with pulse
        Expanded(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _ActionButton(
                  onPressed: _makeCall,
                  gradient: AppTheme.callButtonGradient,
                  icon: Icons.phone,
                  label: 'CALL',
                  isPrimary: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _ActionButton({
    required this.onPressed,
    required this.gradient,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 72,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first
                        .withOpacity(_isPressed ? 0.6 : 0.4),
                    blurRadius: _isPressed ? 25 : 15,
                    offset: const Offset(0, 8),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
