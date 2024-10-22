import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sigacidades/domain/entities/place.dart';

abstract class MapsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapsLoading extends MapsState {}

class MapsLoaded extends MapsState {
  final Position userLocation;
  final List<Place> places;

  MapsLoaded({required this.userLocation, required this.places});

  @override
  List<Object?> get props => [userLocation, places];
}

class MapsError extends MapsState {
  final String message;

  MapsError(this.message);

  @override
  List<Object?> get props => [message];
}
