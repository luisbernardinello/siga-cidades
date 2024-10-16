import 'package:equatable/equatable.dart';

// evento bloc que seleciona categoria
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class SelectCategoryEvent extends CategoryEvent {
  final int selectedIndex;

  const SelectCategoryEvent(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}
