import 'package:equatable/equatable.dart';

abstract class MapsEvent extends Equatable {
  const MapsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserLocationAndPlaces extends MapsEvent {}
