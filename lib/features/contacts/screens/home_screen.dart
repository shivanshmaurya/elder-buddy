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

  late AnimationController _binAnimationController;
  late Animation<double> _binScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadContacts();

    _binAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _binScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _binAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _binTimer?.cancel();
    _binAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await ContactStorageService.loadContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
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

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Start 5-second timer for bin
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
    // Check if over bin area (bottom of screen)
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
      TtsService.speak('${contact.nickname} removed');
    }
  }

  void _reorderContacts(int oldIndex, int newIndex) {
    setState(() {
      final item = _contacts.removeAt(oldIndex);
      _contacts.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    });
    // Save the new order
    ContactStorageService.saveContacts(_contacts);
    HapticFeedback.lightImpact();
  }

  Future<void> _callContact(ContactTileModel contact) async {
    await TtsService.speakContactName(contact.nickname,
        realName: contact.realName);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallConfirmationScreen(contact: contact),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          onContactAdded: _onContactAdded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Easy Call',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildDraggableGrid(),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 100,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Contacts Yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first contact from Settings',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 64,
              child: ElevatedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings, size: 28),
                label: const Text(
                  'GO TO SETTINGS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Main grid
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

        // Bin area at bottom
        if (_showBin)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScaleTransition(
              scale: _binScaleAnimation,
              child: _buildBinArea(isDark),
            ),
          ),

        // Dragging hint
        if (_isDragging && !_showBin)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Hold for 5 seconds to delete',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDraggableTile(ContactTileModel contact, int index) {
    return LongPressDraggable<int>(
      data: index,
      delay: const Duration(milliseconds: 200),
      onDragStarted: () => _onDragStarted(index),
      onDragEnd: (_) => _onDragEnd(),
      onDragUpdate: _onDragUpdate,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 160,
          height: 180,
          child: ContactTile(
            contact: contact,
            onTap: () {},
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: ContactTile(
          contact: contact,
          onTap: () {},
        ),
      ),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => details.data != index,
        onAcceptWithDetails: (details) {
          _reorderContacts(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          final isTarget = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isTarget
                ? (Matrix4.identity()..scale(0.95))
                : Matrix4.identity(),
            child: ContactTile(
              contact: contact,
              onTap: () => _callContact(contact),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBinArea(bool isDark) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final contact = _contacts[details.data];
        _deleteContact(contact);
        _onDragEnd();
      },
      onMove: (_) {
        if (!_isOverBin) {
          setState(() => _isOverBin = true);
        }
      },
      onLeave: (_) {
        if (_isOverBin) {
          setState(() => _isOverBin = false);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty || _isOverBin;

        return Container(
          height: 140,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.red[700]
                : (isDark
                    ? Colors.red[900]?.withOpacity(0.5)
                    : Colors.red[100]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? Colors.red[300]! : Colors.red[400]!,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_forever,
                size: isActive ? 56 : 48,
                color: isActive ? Colors.white : Colors.red[700],
              ),
              const SizedBox(height: 8),
              Text(
                isActive ? 'Release to Delete' : 'Drop Here to Delete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.red[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
