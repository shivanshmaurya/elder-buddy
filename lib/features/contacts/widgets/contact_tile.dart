import 'dart:io';
import 'package:flutter/material.dart';
import '../models/contact_tile_model.dart';

class ContactTile extends StatelessWidget {
  final ContactTileModel contact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 3,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPhoto(isDark),
              const SizedBox(height: 12),
              _buildNickname(isDark),
              if (contact.realName != null) _buildRealName(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(bool isDark) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      backgroundImage: contact.photoPath != null
          ? FileImage(File(contact.photoPath!))
          : null,
      child: contact.photoPath == null
          ? Icon(
              Icons.person,
              size: 48,
              color: isDark ? Colors.white : Colors.black,
            )
          : null,
    );
  }

  Widget _buildNickname(bool isDark) {
    return Text(
      contact.nickname,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildRealName(bool isDark) {
    return Text(
      contact.realName!,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }
}
