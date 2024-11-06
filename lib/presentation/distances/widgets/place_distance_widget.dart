import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/place.dart';

class PlaceDistanceWidget extends StatelessWidget {
  final Place place;
  final double distance;
  final bool isTablet;
  final bool isDesktop;

  const PlaceDistanceWidget({
    super.key,
    required this.place,
    required this.distance,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    double cardVerticalPadding = isDesktop ? 16.0 : (isTablet ? 12.0 : 8.0);
    double titleFontSize = isDesktop ? 20 : (isTablet ? 18 : 16);
    double subtitleFontSize = isDesktop ? 16 : 14;
    double distanceFontSize = isDesktop ? 18 : 16;

    return Card(
      margin:
          EdgeInsets.symmetric(vertical: cardVerticalPadding, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: cardVerticalPadding),
        child: ListTile(
          title: Semantics(
            label: 'Nome do local: ',
            child: Text(
              place.name, // Nome do local
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          subtitle: Semantics(
            label:
                '${place.category}, ${place.city}, a uma distância de ${_formatDistance(distance)}.',
            hint: 'Toque para mais detalhes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Text(
                    '${place.category} - ${place.city}',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFDF58), // Fundo com contraste alto
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Semantics(
                    excludeSemantics: true,
                    child: Text(
                      _formatDistance(distance),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: distanceFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} metros';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} quilômetros';
    }
  }
}
