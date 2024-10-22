import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'maps_event.dart';
import 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  final PlaceRepository placeRepository;

  MapsBloc(this.placeRepository) : super(MapsLoading()) {
    on<LoadUserLocationAndPlaces>(_onLoadUserLocationAndPlaces);
  }

  Future<void> _onLoadUserLocationAndPlaces(
      LoadUserLocationAndPlaces event, Emitter<MapsState> emit) async {
    emit(MapsLoading());
    try {
      // Obtém a localização do usuário
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Busca os lugares próximos com distâncias
      List<Map<String, dynamic>> placesWithDistance =
          await placeRepository.fetchNearbyPlaces(userPosition);

      // Extrai apenas os objetos Place da lista
      List<Place> places = placesWithDistance
          .map((placeData) => placeData['place'] as Place)
          .toList();

      emit(MapsLoaded(userLocation: userPosition, places: places));
    } catch (e) {
      emit(MapsError('Erro ao carregar o mapa e os lugares.'));
    }
  }
}
