import 'package:sigacidades/domain/entities/place.dart';

/// fetchInvalidFields identifica e lista campos inválidos de uma instância de Place.

List<String> fetchInvalidFields(Place place) {
  final invalidFields = <String>[];

  if (place.name == 'Nome não disponível') invalidFields.add('Nome');
  if (place.city == 'Cidade não especificada') invalidFields.add('Cidade');
  if (place.category == 'Categoria não especificada') {
    invalidFields.add('Categoria');
  }
  if (place.description == 'Descrição indisponível') {
    invalidFields.add('Descrição');
  }
  if (place.adress == 'Endereço indisponível') invalidFields.add('Endereço');
  if (place.imageUrl.isEmpty) invalidFields.add('URL da Imagem');
  if (place.imageDescription == 'Imagem não disponível') {
    invalidFields.add('Descrição da Imagem');
  }
  if (place.audioDescriptionUrl.isEmpty) {
    invalidFields.add('URL de Áudio da Descrição');
  }
  if (place.audioPlaceInfoUrl.isEmpty) {
    invalidFields.add('URL de Áudio das Informações');
  }

  if (place.coordinates.latitude == 0 && place.coordinates.longitude == 0) {
    invalidFields.add('Coordenadas');
  }

  return invalidFields;
}
