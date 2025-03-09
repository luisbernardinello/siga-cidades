import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'distances_event.dart';
import 'distances_state.dart';

class DistancesBloc extends Bloc<DistancesEvent, DistancesState> {
  final PlaceRepository placeRepository;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;
  Timer? _refreshTimer;

  // Flag para controlar quando uma atualização está em andamento
  bool _isUpdating = false;

  DistancesBloc(this.placeRepository) : super(DistancesInitial()) {
    on<FetchNearbyPlacesEvent>(_onFetchNearbyPlaces);
    on<LocationUpdatedEvent>(_onLocationUpdated);
  }

  @override
  Future<void> close() {
    _positionStream?.cancel();
    _refreshTimer?.cancel();
    return super.close();
  }

  // Método para buscar os lugares próximos
  Future<void> _onFetchNearbyPlaces(
    FetchNearbyPlacesEvent event,
    Emitter<DistancesState> emit,
  ) async {
    try {
      // Se já estiver carregando, não faz nada
      if (state is DistancesLoading || _isUpdating) return;

      emit(DistancesLoading());

      // Verifica se o serviço de localização está ativo
      if (!await _checkLocationService()) {
        emit(const DistancesError(
            "Serviço de localização está desativado. Por favor, ative-o nas configurações."));
        return;
      }

      // Verifica e solicita a permissão de localização
      if (!await _checkAndRequestLocationPermission(emit)) {
        return;
      }

      // Pega a posição atual
      Position userPosition = await _getCurrentPosition();
      _lastPosition = userPosition;

      // Busca os lugares mais próximos com tempo limite para não travar a interface do usuario
      final nearbyPlacesWithDistances =
          await placeRepository.fetchNearbyPlaces(userPosition);

      // Inicia o monitoramento de localização depois da primeira carga feita com sucesso
      _startLocationMonitoring();

      emit(DistancesLoaded(nearbyPlacesWithDistances));
    } catch (e) {
      emit(DistancesError("Erro ao buscar lugares próximos: $e"));
    }
  }

  // Método para atualizar lugares quando a localização muda
  Future<void> _onLocationUpdated(
    LocationUpdatedEvent event,
    Emitter<DistancesState> emit,
  ) async {
    try {
      // Previne atualizações simultâneas
      if (_isUpdating) return;
      _isUpdating = true;

      // Pega o estado atual para preservar a interface do usuario durante a atualização
      final currentState = state;

      // Só atualiza se a distância for significativa (>100m) em relação à última posição coletada pelo usuario
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          event.position.latitude,
          event.position.longitude,
        );

        // Se a distância for pequena, ignora a atualização
        if (distance < 100) {
          _isUpdating = false;
          return;
        }
      }

      _lastPosition = event.position;

      // Busca os lugares mais próximos sem mostrar o icone de carregamento
      final nearbyPlacesWithDistances =
          await placeRepository.fetchNearbyPlaces(event.position);

      // Só emite se o estado não tiver mudado durante a busca
      if (state == currentState) {
        emit(DistancesLoaded(nearbyPlacesWithDistances));
      }

      _isUpdating = false;
    } catch (e) {
      _isUpdating = false;
      // Caso de erro durante a atualização automática
      print("Erro ao atualizar lugares próximos: $e");
    }
  }

  // Inicia o monitoramento de localização
  void _startLocationMonitoring() {
    // Cancela streams anteriores, se existirem
    _positionStream?.cancel();
    _refreshTimer?.cancel();

    // Configuração para o monitoramento de localização
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy
          .medium, // Balanceia entre precisão e consumo de bateria
      distanceFilter: 50, // Atualiza quando o usuário mover 50m
    );

    // Listener para as mudanças de localização
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      add(LocationUpdatedEvent(position));
    });

    // Atualiza a cada 2 minutos
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_lastPosition != null) {
        add(LocationUpdatedEvent(_lastPosition!));
      }
    });
  }

  // Verifica se o serviço de localização está ativo
  Future<bool> _checkLocationService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Verifica e solicita permissão de localização
  Future<bool> _checkAndRequestLocationPermission(
      Emitter<DistancesState> emit) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(const DistancesPermissionRequired(
            "Permissão de localização é necessária para buscar lugares próximos."));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(const DistancesError(
          "Permissão de localização foi negada permanentemente. Habilite nas configurações."));
      return false;
    }

    return true;
  }

  // Pega a posição atual com timeout para não travar a UI
  Future<Position> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5), // Timeout para evitar travar
      );
    } catch (e) {
      // Se ocorrer erro ou timeout, tenta usar a última posição conhecida como fallback
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }
      // Se não conseguir, propaga o erro
      rethrow;
    }
  }
}

// Evento para atualizar localização
class LocationUpdatedEvent extends DistancesEvent {
  final Position position;

  const LocationUpdatedEvent(this.position);

  @override
  List<Object> get props => [position];
}
