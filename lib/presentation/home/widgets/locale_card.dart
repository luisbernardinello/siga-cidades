import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/locale.dart';

// widget que exibe cada local
Widget localeCard(Locale locale) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0.5,
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.center, // centraliza horizontalmente
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            locale.name,
            textAlign: TextAlign.center, // centraliza o texto
            style: const TextStyle(
              color: Color.fromARGB(255, 71, 71, 71),
              fontSize: 12,
              fontFamily: 'Sora',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // imagem do local
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            image: DecorationImage(
              image: NetworkImage(locale.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ),
  );
}
