import 'package:sigacidades/domain/entities/place.dart';

// O PlaceModel extende a entidade Place (Lugar) da camada de domínio.
// O PlaceModel se trata de um DTO (Data Transfer Object) que faz a conversão dos dados entre JSON e o modelo de entidade.
class PlaceModel extends Place {
  PlaceModel({
    required String name,
    required String imageUrl,
    required String city,
  }) : super(name: name, imageUrl: imageUrl, city: city);

  // Converte um objeto JSON para um PlaceModel.
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: json['name'],
      imageUrl: json['imageUrl'],
      city: json['city'],
    );
  }

  // Converte o PlaceModel para um objeto JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'city': city,
    };
  }
}
