import 'package:flutter/material.dart';

// Widget para cada categoria de lugar
Widget categoryTag(String label, bool isSelected) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isSelected ? Color(0xFFEFDF58) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Color(0xFF080808),
        fontSize: 12,
        fontFamily: 'Sora',
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
