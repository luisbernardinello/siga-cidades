import 'package:equatable/equatable.dart';
import 'package:sigacidades/domain/entities/place.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

// estado de loading (carregamento)
class CategoryLoading extends CategoryState {}

// estado de carregamento feito com sucesso, com os locais filtrados
class CategoryLoaded extends CategoryState {
  final int selectedIndex;
  final List<Place> filteredPlaces;

  const CategoryLoaded({
    required this.selectedIndex,
    required this.filteredPlaces,
  });

  @override
  List<Object?> get props => [selectedIndex, filteredPlaces];
}

// estado que gera erro
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
