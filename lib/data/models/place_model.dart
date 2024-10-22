import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sigacidades/domain/entities/place.dart';

// O PlaceModel extende a entidade Place e faz a conversão de JSON para o modelo e vice-versa.
class PlaceModel extends Place {
  PlaceModel({
    required String name,
    required String city,
    required String category,
    required String description,
    required String adress,
    required String imageUrl,
    required String imgDescription,
    required String linkAD,
    required String linkHist,
    required GeoPoint coordinates,
  }) : super(
          name: name,
          city: city,
          category: category,
          description: description,
          adress: adress,
          imageUrl: imageUrl,
          imgDescription: imgDescription,
          linkAD: linkAD,
          linkHist: linkHist,
          coordinates: coordinates,
        );

  // Converte um objeto JSON para um PlaceModel.
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: json['name'],
      city: json['city'],
      category: json['category'],
      description: json['description'],
      adress: json['adress'],
      imageUrl: json['imageUrl'],
      imgDescription: json['imgDescription'],
      linkAD: json['linkAD'],
      linkHist: json['linkHist'],
      coordinates: json['coordinates'],
    );
  }

  // Converte o PlaceModel para um objeto JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'category': category,
      'description': description,
      'adress': adress,
      'imageUrl': imageUrl,
      'imgDescription': imgDescription,
      'linkAD': linkAD,
      'linkHist': linkHist,
      'coordinates': coordinates,
    };
  }
}
