import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// evento de seleção de categoria
class SelectCategoryEvent extends CategoryEvent {
  final int selectedIndex;

  SelectCategoryEvent(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}

// evento de seleção de cidade
class SelectCityEvent extends CategoryEvent {
  final String city;

  SelectCityEvent(this.city);

  @override
  List<Object> get props => [city];
}
