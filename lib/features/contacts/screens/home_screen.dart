import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact_tile_model.dart';
import '../widgets/contact_tile.dart';
import '../../call/screens/call_confirmation_screen.dart';
import '../../call/services/tts_service.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../storage/contact_storage_service.dart';
import '../../../storage/photo_storage_service.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<ContactTileModel> _contacts = [];
  bool _isLoading = true;
  bool _isDragging = false;
  bool _showBin = false;
  bool _isOverBin = false;
  Timer? _binTimer;
  bool _hasAnimatedEntrance = false;

  late AnimationController _binAnimationController;
  late Animation<double> _binScaleAnimation;
  late AnimationController _emptyStateController;
  late Animation<double> _emptyFadeAnimation;
  late Animation<Offset> _emptySlideAnimation;

  @override
  void initState() {
    super.initState();
    _loadContacts();

    _binAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _binScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _binAnimationController, curve: Curves.elasticOut),
    );

    _emptyStateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _emptyFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _emptySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _binTimer?.cancel();
    _binAnimationController.dispose();
    _emptyStateController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await ContactStorageService.loadContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
      _hasAnimatedEntrance = false;
    });

    if (_contacts.isEmpty) {
      _emptyStateController.forward();
    }
  }

  void _onContactAdded(ContactTileModel contact) {
    setState(() {
      _contacts.add(contact);
    });
  }

  void _onDragStarted(int index) {
    setState(() {
      _isDragging = true;
    });

    HapticFeedback.mediumImpact();

    _binTimer?.cancel();
    _binTimer = Timer(const Duration(seconds: 5), () {
      if (_isDragging && mounted) {
        setState(() => _showBin = true);
        _binAnimationController.forward(from: 0);
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _onDragEnd() {
    _binTimer?.cancel();
    setState(() {
      _isDragging = false;
      _showBin = false;
      _isOverBin = false;
    });
    _binAnimationController.reverse();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isNearBottom = details.globalPosition.dy > screenHeight - 150;

    if (_showBin && isNearBottom != _isOverBin) {
      setState(() => _isOverBin = isNearBottom);
      if (isNearBottom) {
        HapticFeedback.selectionClick();
      }
    }
  }

  Future<void> _deleteContact(ContactTileModel contact) async {
    HapticFeedback.heavyImpact();

    final success =
        await ContactStorageService.removeContact(contact.phoneNumber);
    if (success) {
      await PhotoStorageService.deletePhoto(contact.photoPath);
      setState(() {
        _contacts.removeWhere((c) => c.phoneNumber == contact.phoneNumber);
      });
      TtsService.speak('${contact.realName ?? contact.nickname} removed');

      if (_contacts.isEmpty) {
        _emptyStateController.forward(from: 0);
      }
    }
  }

  void _reorderContacts(int oldIndex, int newIndex) {
    setState(() {
      final item = _contacts.removeAt(oldIndex);
      _contacts.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    });
    ContactStorageService.saveContacts(_contacts);
    HapticFeedback.lightImpact();
  }

  Future<void> _callContact(ContactTileModel contact) async {
    await TtsService.speakContactName(contact.realName ?? contact.nickname);

    if (!mounted) return;

    await Navigator.push(
      context,
      FadeScalePageRoute(
        page: CallConfirmationScreen(contact: contact),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      SlideUpPageRoute(
        page: SettingsScreen(onContactAdded: _onContactAdded),
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
          child: _isLoading
              ? _buildLoadingState()
              : _contacts.isEmpty
                  ? _buildEmptyState()
                  : _buildDraggableGrid(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.phone,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Elder Buddy',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        _GlassIconButton(
          icon: Icons.settings,
          onPressed: _openSettings,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading contacts...',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _emptyFadeAnimation,
      child: SlideTransition(
        position: _emptySlideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon with gradient
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.2),
                          AppTheme.deepPurple.withOpacity(0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentCyan.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      size: 80,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'No Contacts Yet',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add your first contact from Settings',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _GradientButton(
                  onPressed: _openSettings,
                  icon: Icons.settings,
                  label: 'GO TO SETTINGS',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableGrid() {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final crossAxisCount =
                isLandscape ? (constraints.maxWidth > 900 ? 4 : 3) : 2;

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, _showBin ? 160 : 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return _buildDraggableTile(contact, index);
              },
            );
          },
        ),

        // Bin area
        if (_showBin)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScaleTransition(
              scale: _binScaleAnimation,
              child: _buildBinArea(),
            ),
          ),

        // Dragging hint
        if (_isDragging && !_showBin)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.cardDark.withOpacity(0.95),
                        AppTheme.cardDarkLight.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.accentCyan.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: AppTheme.accentCyan,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Hold for 5 seconds to delete',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDraggableTile(ContactTileModel contact, int index) {
    Widget tile = LongPressDraggable<int>(
      data: index,
      delay: const Duration(milliseconds: 200),
      onDragStarted: () => _onDragStarted(index),
      onDragEnd: (_) => _onDragEnd(),
      onDragUpdate: _onDragUpdate,
      feedback: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 160,
          height: 185,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ContactTile(
            contact: contact,
            onTap: () {},
            enableHero: false,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: ContactTile(
          contact: contact,
          onTap: () {},
          enableHero: false,
        ),
      ),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => details.data != index,
        onAcceptWithDetails: (details) {
          _reorderContacts(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          final isTarget = candidateData.isNotEmpty;
          return AnimatedScale(
            scale: isTarget ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: ContactTile(
              contact: contact,
              onTap: () => _callContact(contact),
              index: index,
            ),
          );
        },
      ),
    );

    // Staggered entrance animation
    if (!_hasAnimatedEntrance) {
      if (index == _contacts.length - 1) {
        Future.delayed(Duration(milliseconds: index * 80 + 500), () {
          if (mounted) setState(() => _hasAnimatedEntrance = true);
        });
      }

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + index * 50),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 40 * (1 - value)),
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            ),
          );
        },
        child: tile,
      );
    }

    return tile;
  }

  Widget _buildBinArea() {
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final contact = _contacts[details.data];
        _deleteContact(contact);
        _onDragEnd();
      },
      onMove: (_) {
        if (!_isOverBin) setState(() => _isOverBin = true);
      },
      onLeave: (_) {
        if (_isOverBin) setState(() => _isOverBin = false);
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty || _isOverBin;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 130,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isActive
                ? AppTheme.cancelButtonGradient
                : LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.2),
                      Colors.red.withOpacity(0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isActive ? Colors.red[300]! : Colors.red.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.3 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.delete_forever,
                  size: 44,
                  color: isActive ? Colors.white : Colors.red[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isActive ? 'Release to Delete' : 'Drop Here to Delete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.red[400],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Glass-style icon button
class _GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
        HapticFeedback.lightImpact();
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: _isPressed
                    ? AppTheme.accentGradient
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isPressed
                      ? AppTheme.accentCyan
                      : Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(
                widget.icon,
                size: 24,
                color: _isPressed ? Colors.white : AppTheme.accentCyan,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Gradient button
class _GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
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
        HapticFeedback.mediumImpact();
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue
                        .withOpacity(_isPressed ? 0.6 : 0.4),
                    blurRadius: _isPressed ? 25 : 15,
                    offset: const Offset(0, 8),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
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
          );
        },
      ),
    );
  }
}
