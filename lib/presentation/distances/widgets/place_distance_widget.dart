import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sigacidades/data/models/place_model.dart';
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
  // Método para verificar se existe erro nos dados da instância de Place
  bool hasError() {
    final invalidFields = (place as PlaceModel).getInvalidFields();
    return invalidFields.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Valida os campos do Place usando o método getInvalidFields do modelo PlaceModel
    final invalidFields = (place as PlaceModel).getInvalidFields();

    // Se existirem campos inválidos, exibe o PlaceDistanceError
    if (invalidFields.isNotEmpty) {
      return PlaceDistanceError(invalidFields: invalidFields, place: place);
    }

    // Layout para o card padrão
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
            button: true,
            child: Text(
              place.name,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF474747),
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
                    color: const Color(0xFFEFDF58),
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

// Widget de erro para o caso de campos errados do objeto Place.
class PlaceDistanceError extends StatelessWidget {
  final List<String> invalidFields;
  final Place place;

  const PlaceDistanceError({
    super.key,
    required this.invalidFields,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Erro: "${place.name}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 30,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AutoSizeText(
                  'Campos ausentes ou incorretos: ${invalidFields.join(", ")}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  minFontSize: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
