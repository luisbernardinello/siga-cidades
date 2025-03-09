import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';

/// CategoryBloc gerencia a seleção de categorias e cidades,
/// centralizando a lógica de negócios e mantendo o estado atualizado.
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final PlaceRepository placeRepository; // Instância do repositório de dados
  String selectedCity = 'Bauru'; // Cidade padrão
  int currentCategoryIndex = -1; // Índice inicial para a categoria "Todos"

  // Cache dos lugares para melhorar o desempenho
  final Map<String, Map<int, List<Place>>> _placesCache = {};

  CategoryBloc(this.placeRepository) : super(CategoryLoading()) {
    // Evento de seleção de categoria, incluindo a lógica para categoria Todos
    on<SelectCategoryEvent>((event, emit) async {
      emit(CategoryLoading()); // Sempre emite o estado de carregamento

      currentCategoryIndex = event.selectedIndex;

      // Verifica se o cache possui a cidade e categoria selecionada
      if (_placesCache[selectedCity] != null &&
          _placesCache[selectedCity]!.containsKey(event.selectedIndex)) {
        // Usa cache se disponível
        emit(CategoryLoaded(
          selectedIndex: event.selectedIndex,
          filteredPlaces: _placesCache[selectedCity]![event.selectedIndex]!,
        ));
      } else {
        List<Place> places;
        if (event.selectedIndex == -1) {
          // Lógica para carregar todos os lugares da cidade sem filtrar categoria
          places = await placeRepository.fetchPlacesByCity(selectedCity);
        } else {
          // Lógica para carregar lugares de uma categoria específica
          places =
              await placeRepository.fetchPlacesByCategory(event.selectedIndex);
          places = places.where((place) => place.city == selectedCity).toList();
        }

        // Atualiza o cache com a lista carregada
        _placesCache.putIfAbsent(selectedCity, () => {});
        _placesCache[selectedCity]![event.selectedIndex] = places;

        emit(CategoryLoaded(
          selectedIndex: event.selectedIndex,
          filteredPlaces: places,
        ));
      }
    });

    // Evento para seleção de cidade
    on<SelectCityEvent>((event, emit) async {
      selectedCity = event.city;
      add(SelectCategoryEvent(
          -1)); // Atualiza para a categoria "Todos" ao mudar de cidade
    });
  }
}
