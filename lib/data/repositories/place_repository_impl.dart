import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para o uso do Geolocator
import 'package:geolocator/geolocator.dart'; // Para o cálculo de distância

// Implementação concreta do PlaceRepository, que é responsável por fornecer os dados.
class PlaceRepositoryImpl implements PlaceRepository {
  // Lista de todos os lugares, dessa vez com coordenadas definidas.
  final List<Place> allPlaces = [
    Place(
      name: 'Bosque da Saude',
      city: 'Botucatu',
      category: 'Bosques e Parques',
      description: 'Um ótimo lugar para fazer trilhas e curtir a natureza.',
      adress: 'Rua das Árvores, 123, Botucatu, SP',
      imageUrl: 'https://via.placeholder.com/164x100',
      imgDescription: 'Vista do bosque durante o dia',
      linkAD: 'https://audiodescricao-bosque.com',
      linkHist: 'https://historia-bosque.com',
      coordinates:
          GeoPoint(-22.885897, -48.445049), // Coordenada aleatória em Botucatu
    ),
    Place(
      name: 'Horto Florestal',
      city: 'Bauru',
      category: 'Bosques e Parques',
      description: 'Um grande parque com muitas árvores e fauna local.',
      adress: 'Av. Getúlio Vargas, Bauru, SP',
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/06/e2/9b/f0/horto-florestal-de-bauru.jpg?w=1200&h=1200&s=1',
      imgDescription: 'Entrada do Horto Florestal',
      linkAD: 'https://audiodescricao-horto.com',
      linkHist: 'https://historia-horto.com',
      coordinates:
          GeoPoint(-22.314459, -49.062146), // Coordenada aleatória em Bauru
    ),
    Place(
      name: 'Casarão da Picanha',
      city: 'Bauru',
      category: 'Comércio',
      description: 'Um restaurante tradicional com a melhor picanha da região.',
      adress: 'Av. Pedro de Toledo, 500, Bauru, SP',
      imageUrl: 'https://via.placeholder.com/164x100',
      imgDescription: 'Fachada do Casarão da Picanha',
      linkAD: 'https://audiodescricao-casarao.com',
      linkHist: 'https://historia-casarao.com',
      coordinates:
          GeoPoint(-22.315488, -49.060902), // Coordenada aleatória em Bauru
    ),
    Place(
      name: 'Bar do Roberto',
      city: 'Bauru',
      category: 'Comércio',
      description: 'Um famoso bar com petiscos e bebidas de alta qualidade.',
      adress: 'Rua Primeiro de Agosto, 600, Bauru, SP',
      imageUrl: 'https://via.placeholder.com/164x100',
      imgDescription: 'Fachada do Bar do Roberto',
      linkAD: 'https://audiodescricao-barroberto.com',
      linkHist: 'https://historia-barroberto.com',
      coordinates:
          GeoPoint(-22.316137, -49.065791), // Coordenada aleatória em Bauru
    ),
    Place(
      name: 'Bar do Juca',
      city: 'Presidente Prudente',
      category: 'Comércio',
      description:
          'Um bar histórico conhecido pelo atendimento e pratos típicos.',
      adress: 'Rua das Palmeiras, 34, Presidente Prudente, SP',
      imageUrl: 'https://via.placeholder.com/164x100',
      imgDescription: 'Fachada do Bar do Juca',
      linkAD: 'https://audiodescricao-barjuca.com',
      linkHist: 'https://historia-barjuca.com',
      coordinates: GeoPoint(-22.120929,
          -51.387166), // Coordenada aleatória em Presidente Prudente
    ),
  ];

  // ====================================
  // Busca lugares com base na categoria
  // ====================================
  @override
  Future<List<Place>> fetchPlacesByCategory(int categoryIndex) async {
    final categories = [
      'Bosques e Parques',
      'Comércio',
      'Cultura, Lazer e Esporte',
      'Edificações Públicas',
      'Educação e Terceiro Setor',
      'Logradouros e Praças',
      'Religião',
      'Saúde'
    ];

    if (categoryIndex < 0 || categoryIndex >= categories.length) {
      return []; // Se o index estiver fora do intervalo, retorna uma lista vazia
    }

    // Filtra os lugares com base na categoria associada ao index
    return allPlaces
        .where((place) => place.category == categories[categoryIndex])
        .toList();
  }

  // ====================================
  // Busca todos os lugares de uma cidade específica.
  // ====================================
  @override
  Future<List<Place>> fetchPlacesByCity(String city) async {
    return allPlaces
        .where((place) => place.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  // ====================================
  // Busca os lugares mais próximos com base nas coordenadas do usuário
  // ====================================
  // Função para buscar lugares próximos com as distâncias calculadas.
  @override
  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(
      Position userPosition) async {
    List<Map<String, dynamic>> placesWithDistance = [];

    // Calcula a distância para cada lugar e armazena no mapa
    for (var place in allPlaces) {
      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        place.coordinates.latitude,
        place.coordinates.longitude,
      );

      placesWithDistance.add({
        'place': place,
        'distance': distanceInMeters, // Inclui a distância calculada
      });
    }

    // Ordena os lugares pela distância mais próxima
    placesWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));

    // Retorna os 9 lugares mais próximos com suas distâncias
    return placesWithDistance.take(9).toList();
  }
}
