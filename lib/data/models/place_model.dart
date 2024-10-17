import 'package:sigacidades/domain/entities/place.dart';

class PlaceModel extends Place {
  PlaceModel(
      {required String name, required String imageUrl, required String city})
      : super(name: name, imageUrl: imageUrl, city: city);

  // converte JSON para o modelo
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: json['name'],
      imageUrl: json['imageUrl'],
      city: json['city'],
    );
  }

  // converte o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'city': city,
    };
  }
}
