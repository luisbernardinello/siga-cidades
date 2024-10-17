import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final PlaceRepository placeRepository;
  String selectedCity = 'Bauru'; // cidade base inicial.

  CategoryBloc(this.placeRepository) : super(CategoryLoading()) {
    // faz a manipulação do evento de seleção de categoria
    on<SelectCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      // busca os locais pela categoria que foi selecionada
      final places =
          await placeRepository.fetchPlacesByCategory(event.selectedIndex);

      // filtra os locais pela cidade selecionada
      final filteredPlaces =
          places.where((place) => place.city == selectedCity).toList();

      emit(CategoryLoaded(
        selectedIndex: event.selectedIndex,
        filteredPlaces: filteredPlaces,
      ));
    });

    // faz a manipulação do evento de seleção de cidade
    on<SelectCityEvent>((event, emit) async {
      selectedCity = event.city; // atualiza a cidade selecionada

      // reenvia o evento de categoria atual para refiltrar os locais
      if (state is CategoryLoaded) {
        add(SelectCategoryEvent((state as CategoryLoaded).selectedIndex));
      } else {
        add(SelectCategoryEvent(
            0)); // 0 é a categoria padrão "Bosques e Parques"
      }
    });
  }
}
