import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  // locais simulados, agrupando tudo em uma lista única
  final List<Place> allPlaces = [
    Place(
        name: 'Bosque da Saude',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Botucatu'),
    Place(
        name: 'Horto Florestal',
        imageUrl:
            'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/06/e2/9b/f0/horto-florestal-de-bauru.jpg?w=1200&h=1200&s=1',
        city: 'Bauru'),
    Place(
        name: 'Casarão da Picanha',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Bauru'),
    Place(
        name: 'Bar do Roberto',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Bauru'),
    Place(
        name: 'Bar do Juca',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Presidente Prudente'),
    Place(
        name: 'Bar do Rogerio',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Presidente Prudente'),
    Place(
        name: 'Farmácia Droga Raia',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Botucatu'),
    Place(
        name: 'Supermercado Confiança',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Botucatu'),
    Place(
        name: 'Centro Cultural',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Bauru'),
    Place(
        name: 'Museu de Arte',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Presidente Prudente'),
    Place(
        name: 'Igreja Universal',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Bauru'),
    Place(
        name: 'Hospital Estadual',
        imageUrl: 'https://via.placeholder.com/164x100',
        city: 'Bauru'),
  ];

  @override
  Future<List<Place>> fetchPlacesByCategory(int categoryIndex) async {
    // simula dados locais com cidade associada
    switch (categoryIndex) {
      case 0: // Bosques e Parques
        return allPlaces
            .where((place) =>
                place.name.contains('Bosque') || place.name.contains('Horto'))
            .toList();
      case 1: // Comércio
        return allPlaces
            .where((place) =>
                place.name.contains('Bar') ||
                place.name.contains('Supermercado') ||
                place.name.contains('Farmácia'))
            .toList();
      case 2: // Cultura, Lazer e Esporte
        return allPlaces
            .where((place) =>
                place.name.contains('Centro') || place.name.contains('Museu'))
            .toList();
      case 3: // Edificações Públicas
        return [];
      case 4: // Educação e Terceiro Setor
        return [];
      case 5: // Logradouros e Praças
        return [];
      case 6: // Religião
        return allPlaces
            .where((place) => place.name.contains('Igreja'))
            .toList();
      case 7: // Saúde
        return allPlaces
            .where((place) => place.name.contains('Hospital'))
            .toList();
      default:
        return [];
    }
  }

  @override
  Future<List<Place>> fetchPlacesByCity(String city) async {
    // retorna todos os locais da cidade
    return allPlaces
        .where((place) => place.city.toLowerCase() == city.toLowerCase())
        .toList();
  }
}
