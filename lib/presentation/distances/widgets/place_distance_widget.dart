import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/place.dart';

class PlaceDistanceWidget extends StatelessWidget {
  final Place place;
  final double distance; // Adicionando distância como parâmetro

  const PlaceDistanceWidget({
    Key? key,
    required this.place,
    required this.distance, // Passamos a distância
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${place.category} - ${place.city}'),
            // Exibe a distância formatada em metros ou quilômetros
            Text(
              _formatDistance(distance),
              style: const TextStyle(
                color: Color(0xFF00FF00), // Cor verde
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formata a distância para exibir em metros ou quilômetros
  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} metros';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }
}
