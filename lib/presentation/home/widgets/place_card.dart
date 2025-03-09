import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sigacidades/data/models/place_model.dart';
import 'package:sigacidades/domain/entities/place.dart';

Widget placeCard(Place place, bool isDesktop,
    Function(bool isError) onWidgetTypeDetermined) {
  final invalidFields = (place as PlaceModel).getInvalidFields();

  // Verifica se há erros e chama o callback indicando o estado do widget
  if (invalidFields.isNotEmpty) {
    onWidgetTypeDetermined(true); // Se houver erro
    return errorCard(invalidFields, place);
  } else {
    onWidgetTypeDetermined(false); // Se não houver erro
  }

  final double imageHeight = isDesktop ? 200.0 : 100.0;

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0.5,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Semantics(
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                place.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF474747),
                  fontSize: isDesktop ? 18 : 14,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: Semantics(
            excludeSemantics: true,
            button: true,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: place.imageUrl,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Widget de erro para o caso de campos errados do objeto Place.
Widget errorCard(List<String> invalidFields, Place place) {
  return Semantics(
    excludeSemantics: true,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.5,
      color: Colors.red.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Erro: "${place.name}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 12,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              minFontSize: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
