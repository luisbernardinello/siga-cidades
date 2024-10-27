import 'package:flutter/material.dart';

Widget categoryTag(String label, bool isSelected,
    {double screenWidth = 360.0}) {
  double fontSize = screenWidth < 400 ? 12.0 : 14.0;
  double paddingHorizontal = screenWidth < 400 ? 8.0 : 12.0;
  double paddingVertical = screenWidth < 400 ? 6.0 : 8.0;

  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal, vertical: paddingVertical),
    decoration: BoxDecoration(
      color: isSelected ? Color(0xFFEFDF58) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      maxLines: 1, // Evita quebras de linha em textos longos
      overflow: TextOverflow
          .ellipsis, // Se o texto for longo demais, coloca reticências
      style: TextStyle(
        color: Color(0xFF080808),
        fontSize: fontSize,
        fontFamily: 'Sora',
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
