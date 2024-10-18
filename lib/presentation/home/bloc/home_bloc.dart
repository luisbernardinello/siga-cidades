import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';

// O BLoC (Business Logic Component) gerencia a lógica entre a interface e os dados.
// Ele recebe eventos (CategoryEvent), faz o processamento e envia novos estados (home_state).
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final PlaceRepository placeRepository; // Dependência do repositório de dados.
  String selectedCity = 'Bauru'; // Cidade inicial que irá para o Drawer(Bauru).

  // O construtor inicializa o BLoC com o estado de carregamento.
  // O construtor também define como lidar com cada evento (categoria e cidade).
  CategoryBloc(this.placeRepository) : super(CategoryLoading()) {
    // ====================================
    // Manipulação do evento de seleção de categoria
    // ====================================
    on<SelectCategoryEvent>((event, emit) async {
      emit(
          CategoryLoading()); // Emite o estado de carregamento enquanto busca os dados.

      // Acessa o repositório para buscar os lugares com base na categoria.
      final places =
          await placeRepository.fetchPlacesByCategory(event.selectedIndex);

      // Filtra os lugares pela cidade selecionada.
      final filteredPlaces =
          places.where((place) => place.city == selectedCity).toList();

      // Emite o estado de sucesso (CategoryLoaded) com a lista filtrada de lugares.
      emit(CategoryLoaded(
        selectedIndex: event.selectedIndex,
        filteredPlaces: filteredPlaces,
      ));
    });

    // ====================================
    // Manipulação do evento de seleção de cidade
    // ====================================
    on<SelectCityEvent>((event, emit) async {
      selectedCity = event.city; // Atualiza a cidade selecionada.

      // Reenvia o evento de categoria para refiltrar os locais com base na cidade.
      if (state is CategoryLoaded) {
        // Se a categoria ja está carregada, reenvia o evento para manter a categoria atual mesmo que mude a cidade.
        add(SelectCategoryEvent((state as CategoryLoaded).selectedIndex));
      } else {
        // Se não tiver estiver carregado, carrega a categoria padrão (0 = Bosques e Parques).
        add(SelectCategoryEvent(0));
      }
    });
  }
}
