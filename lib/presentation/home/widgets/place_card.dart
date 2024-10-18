import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/place.dart';

// Widget que exibe cada lugar
Widget placeCard(Place place) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0.5,
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Centraliza horizontalmente
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            place.name,
            textAlign: TextAlign.center, // Centraliza o texto
            style: const TextStyle(
              color: Color.fromARGB(255, 71, 71, 71),
              fontSize: 12,
              fontFamily: 'Sora',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Exibe a imagem do lugar
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            image: DecorationImage(
              image: NetworkImage(place.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ),
  );
}
