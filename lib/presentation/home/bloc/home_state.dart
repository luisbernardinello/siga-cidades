import 'package:equatable/equatable.dart';
import 'package:sigacidades/domain/entities/locale.dart';

// Estado base, usado para comparação de estados no BLoC
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

// Estado inicial, usado quando o aplicativo carrega pela primeira vez
class CategoryInitial extends CategoryState {}

// Estado de carregamento, exibido quando os dados estão sendo buscados
class CategoryLoading extends CategoryState {}

// Estado de sucesso, usado quando os dados são carregados com sucesso
class CategoryLoaded extends CategoryState {
  final int selectedIndex;
  final List<Locale> filteredLocales;

  const CategoryLoaded({
    required this.selectedIndex,
    required this.filteredLocales,
  });

  @override
  List<Object?> get props => [selectedIndex, filteredLocales];
}

// Estado de erro, usado quando ocorre um erro durante a busca de dados
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
