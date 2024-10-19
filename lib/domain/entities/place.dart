import 'package:cloud_firestore/cloud_firestore.dart'; // Para o uso do GeoPoint (Firebase)

// A entidade Place representa um local na cidade, com vários detalhes
class Place {
  final String name; // Nome do local
  final String city; // Cidade do local
  final String category; // Categoria do local
  final String description; // Descrição do local
  final String adress; // Endereço do local
  final String imageUrl; // URL para a imagem do local
  final String imgDescription; // Descrição da imagem
  final String linkAD; // Link para áudio-descrição do local
  final String linkHist; // Link para áudio da história do local
  final GeoPoint coordinates; // Coordenadas do local (latitude, longitude)

  Place({
    required this.name,
    required this.city,
    required this.category,
    required this.description,
    required this.adress,
    required this.imageUrl,
    required this.imgDescription,
    required this.linkAD,
    required this.linkHist,
    required this.coordinates,
  });
}
