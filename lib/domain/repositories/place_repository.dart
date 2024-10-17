import 'package:sigacidades/domain/entities/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> fetchPlacesByCategory(int categoryIndex);

  //  método que busca todos os locais de uma cidade
  Future<List<Place>> fetchPlacesByCity(String city);
}
