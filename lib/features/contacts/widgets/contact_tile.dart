import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact_tile_model.dart';
import '../../../core/theme/app_theme.dart';

class ContactTile extends StatefulWidget {
  final ContactTileModel contact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? index;
  final bool enableHero;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.onLongPress,
    this.index,
    this.enableHero = true,
  });

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile>
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

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.contact.photoPath != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: hasPhoto ? _buildPhotoTile() : _buildNameOnlyTile(),
          );
        },
      ),
    );
  }

  Widget _buildPhotoTile() {
    final photoWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isPressed
              ? AppTheme.accentCyan.withOpacity(0.6)
              : Colors.white.withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isPressed
                ? AppTheme.primaryBlue.withOpacity(0.4)
                : Colors.black.withOpacity(0.3),
            blurRadius: _isPressed ? 20 : 15,
            offset: const Offset(0, 8),
            spreadRadius: _isPressed ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full cover image
            Image.file(
              File(widget.contact.photoPath!),
              fit: BoxFit.cover,
            ),
            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
            // Glow effect when pressed
            if (_isPressed)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                ),
              ),
            // Name at bottom
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: Text(
                widget.contact.realName ?? widget.contact.nickname,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.enableHero) {
      return Hero(
        tag: 'contact_photo_${widget.contact.phoneNumber}',
        child: photoWidget,
      );
    }
    return photoWidget;
  }

  Widget _buildNameOnlyTile() {
    // Use real name, fallback to nickname
    final displayName = widget.contact.realName ?? widget.contact.nickname;

    // Get initials for the avatar
    final initials = _getInitials(displayName);

    // Generate a consistent color based on the name
    final colorIndex = displayName.hashCode % _avatarColors.length;
    final avatarGradient = _avatarColors[colorIndex.abs()];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isPressed
              ? [
                  avatarGradient[0].withOpacity(0.9),
                  avatarGradient[1].withOpacity(0.9),
                ]
              : avatarGradient,
        ),
        border: Border.all(
          color: _isPressed
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: avatarGradient[0].withOpacity(_isPressed ? 0.5 : 0.3),
            blurRadius: _isPressed ? 25 : 15,
            offset: const Offset(0, 8),
            spreadRadius: _isPressed ? 3 : 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pattern overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CustomPaint(
                painter: _PatternPainter(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large initials
                Text(
                  initials,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  // Beautiful gradient colors for avatars without photos
  static const List<List<Color>> _avatarColors = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // Purple-violet
    [Color(0xFF11998e), Color(0xFF38ef7d)], // Teal-green
    [Color(0xFFee0979), Color(0xFFff6a00)], // Pink-orange
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue-cyan
    [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink-rose
    [Color(0xFF5ee7df), Color(0xFFb490ca)], // Cyan-lavender
    [Color(0xFFfa709a), Color(0xFFfee140)], // Pink-yellow
    [Color(0xFF667eea), Color(0xFF43e97b)], // Purple-green
  ];
}

// Pattern painter for visual interest on name-only tiles
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw subtle circles pattern
    for (var i = 0; i < 3; i++) {
      final radius = 30.0 + (i * 40);
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
