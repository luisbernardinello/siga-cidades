import 'package:sigacidades/domain/entities/place.dart';

// Interface do Repositório.
// A camada de domínio define o contrato e a entidade
// O contrato é gerado com base no paradigma orientado a objetos, se trata da interface que a camada de dados deve implementar.
abstract class PlaceRepository {
  // Busca lugares com base na categoria.
  Future<List<Place>> fetchPlacesByCategory(int categoryIndex);

  // Busca lugares com base na cidade.
  Future<List<Place>> fetchPlacesByCity(String city);
}
