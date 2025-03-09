import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sigacidades/core/place_invalid_fields.dart';
import 'package:sigacidades/domain/entities/place.dart';

// O PlaceModel extende a entidade Place e faz a conversão de JSON para o PlaceModel e do PlaceModel para JSON.
/// Lida com o mapeamento e a validação das informações vindas do Firestore para um objeto do tipo Place

class PlaceModel extends Place {
  PlaceModel({
    required super.name,
    required super.city,
    required super.category,
    required super.description,
    required super.adress,
    required super.imageUrl,
    required super.imageDescription,
    required super.audioDescriptionUrl,
    required super.audioPlaceInfoUrl,
    required super.coordinates,
  });

  /// Construtor factory que cria um PlaceModel a partir de um Map JSON.
  // Converte um objeto JSON para um PlaceModel.
  /// No caso de dados ausentes ou inválidos, campos padrão são atribuídos.
  /// Objetivo é a camada de dados se manter independente do restante do sistema.
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: json['name'] ?? 'Nome não disponível',
      city: json['city'] ?? 'Cidade não especificada',
      category: json['category'] ?? 'Categoria não especificada',
      description: json['description'] ?? 'Descrição indisponível',
      adress: json['adress'] ?? 'Endereço indisponível',
      imageUrl: json['imageUrl'] ?? '',
      imageDescription: json['imageDescription'] ?? 'Imagem não disponível',
      audioDescriptionUrl: json['audioDescriptionUrl'] ?? '',
      audioPlaceInfoUrl: json['audioPlaceInfoUrl'] ?? '',
      coordinates: json['coordinates'] ?? const GeoPoint(0, 0),
    );
  }

  /// Método para obter a lista de campos inválidos de uma instância de PlaceModel.
  /// Usa a fetchInvalidFields, que faz a validação dos campos
  /// Se vier errado do objeto Place, são marcados como inválidos.
  List<String> getInvalidFields() {
    return fetchInvalidFields(this);
  }
}
