import 'package:flutter/material.dart';

class ChipThemeUtil {
  static const Color chipPurple = Color(0xFF7E57C2);

  static Widget buildStyledChip({
    required String label,
    TextStyle? labelStyle,
    VoidCallback? onDeleted,
    Icon? deleteIcon,
  }) {
    return Chip(
      label: Text(
        label,
        style: labelStyle?.copyWith(color: Colors.white,fontWeight: FontWeight.bold) ??
            const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipPurple,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onDeleted: onDeleted,
      deleteIcon: deleteIcon,
    );
  }
}