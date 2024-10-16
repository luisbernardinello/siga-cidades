import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/repositories/locale_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final LocaleRepository localeRepository;

  CategoryBloc(this.localeRepository) : super(CategoryInitial()) {
    on<SelectCategoryEvent>((event, emit) async {
      // Não emitir o estado de carregamento
      try {
        // Buscar os locais de acordo com a categoria selecionada
        final locales =
            await localeRepository.fetchLocalesByCategory(event.selectedIndex);

        // Emitir o estado de sucesso com os locais filtrados
        emit(CategoryLoaded(
          selectedIndex: event.selectedIndex,
          filteredLocales: locales,
        ));
      } catch (error) {
        // Emitir o estado de erro caso algo dê errado
        emit(CategoryError('Erro ao carregar os locais.'));
      }
    });
  }
}
