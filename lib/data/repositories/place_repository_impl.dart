import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/data/models/place_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

/// Implementação do PlaceRepository
class PlaceRepositoryImpl implements PlaceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache para os diferentes consultas
  final Map<int, List<Place>> _categoryCache = {};
  final Map<String, List<Place>> _cityCache = {};
  final Map<String, List<Map<String, dynamic>>> _nearbyPlacesCache = {};
  final Map<String, List<Place>> _mapPlacesCache = {};

  // Tempos de expiração do cache
  final Map<String, DateTime> _cacheTimes = {};

  // Tempo de expiração do cache (5 minutos)
  final Duration _cacheExpiration = const Duration(minutes: 5);

  // Lista de categorias
  final List<String> _categories = [
    'Bosques e Parques',
    'Comércio',
    'Cultura, Lazer e Esporte',
    'Edificações Públicas',
    'Educação e Terceiro Setor',
    'Logradouros e Praças',
    'Religião',
    'Saúde'
  ];

  // Cache de todos os lugares para evitar consultas repetidas
  List<Place>? _allPlacesCache;
  DateTime? _allPlacesCacheTime;

  // ====================================
  // Seção: Busca de lugares por categoria
  // ====================================
  @override
  Future<List<Place>> fetchPlacesByCategory(int categoryIndex) async {
    // Verifica se o índice é válido
    if (categoryIndex < 0 || categoryIndex >= _categories.length) {
      return [];
    }

    // Verifica se existe cache válido
    if (_categoryCache.containsKey(categoryIndex) &&
        _isCacheValid('category_$categoryIndex')) {
      return _categoryCache[categoryIndex]!;
    }

    // Pega a categoria pelo índice
    final category = _categories[categoryIndex];

    try {
      // Consulta o Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('lugares')
          .where('category', isEqualTo: category)
          .get();

      // Converte os documentos e faz a ordenaçao
      final places = querySnapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      // Armazena no cache
      _categoryCache[categoryIndex] = places;
      _setCacheTime('category_$categoryIndex');

      return places;
    } catch (e) {
      // Se tiver erro retorna o cache se existir, mesmo que expirado
      if (_categoryCache.containsKey(categoryIndex)) {
        return _categoryCache[categoryIndex]!;
      }
      // Se não tiver cache, propaga o erro
      rethrow;
    }
  }

  // ====================================
  // Seção: Busca de lugares por cidade
  // ====================================
  @override
  Future<List<Place>> fetchPlacesByCity(String city) async {
    // Verifica se existe cache válido
    if (_cityCache.containsKey(city) && _isCacheValid('city_$city')) {
      return _cityCache[city]!;
    }

    try {
      // Consulta o Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('lugares')
          .where('city', isEqualTo: city)
          .get();

      // Converte os documentos e ordena
      final places = querySnapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      // Armazena no cache
      _cityCache[city] = places;
      _setCacheTime('city_$city');

      return places;
    } catch (e) {
      if (_cityCache.containsKey(city)) {
        return _cityCache[city]!;
      }
      // Se não tiver cache, propaga o erro
      rethrow;
    }
  }

  // ====================================
  // Seção: Busca de lugares próximos ao usuário
  // ====================================
  @override
  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(
      Position userPosition) async {
    // Gera a chave de cache baseada na posição aproximada (~100m)
    final cacheKey = _generatePositionCacheKey(userPosition);

    // Verifica se existe cache válido
    if (_nearbyPlacesCache.containsKey(cacheKey) &&
        _isCacheValid('nearby_$cacheKey')) {
      return _nearbyPlacesCache[cacheKey]!;
    }

    try {
      // Pega todos os lugares (usando cache se possível)
      final allPlaces = await _getAllPlaces();

      // Calcula a distância para cada lugar e cria a lista com lugares e distâncias
      List<Map<String, dynamic>> placesWithDistance = allPlaces.map((place) {
        final distanceInMeters = _calculateHaversineDistance(
          userPosition.latitude,
          userPosition.longitude,
          place.coordinates.latitude,
          place.coordinates.longitude,
        );

        return {
          'place': place,
          'distance': distanceInMeters,
        };
      }).toList();

      // Ordena por distância
      placesWithDistance.sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double));

      // Pega os 9 mais próximos
      final nearbyPlaces = placesWithDistance.take(9).toList();

      // Armazena no cache
      _nearbyPlacesCache[cacheKey] = nearbyPlaces;
      _setCacheTime('nearby_$cacheKey');

      return nearbyPlaces;
    } catch (e) {
      if (_nearbyPlacesCache.containsKey(cacheKey)) {
        return _nearbyPlacesCache[cacheKey]!;
      }
      // Se não tiver cache, propaga o erro
      rethrow;
    }
  }

  // ====================================
  // Seção: Busca de lugares para o mapa
  // ====================================
  @override
  Future<List<Place>> fetchPlacesMap(Position userPosition) async {
    // Gera a chave de cache baseada na posição aproximada
    final cacheKey = _generatePositionCacheKey(userPosition);

    // Verifica se existe cache válido
    if (_mapPlacesCache.containsKey(cacheKey) &&
        _isCacheValid('map_$cacheKey')) {
      return _mapPlacesCache[cacheKey]!;
    }

    try {
      // Pega todos os lugares (usando cache se possível)
      final allPlaces = await _getAllPlaces();

      // Cria uma cópia para ordenação
      final sortedPlaces = List<Place>.from(allPlaces);

      // Ordena pela distância
      sortedPlaces.sort((a, b) {
        final distanceA = _calculateHaversineDistance(
          userPosition.latitude,
          userPosition.longitude,
          a.coordinates.latitude,
          a.coordinates.longitude,
        );

        final distanceB = _calculateHaversineDistance(
          userPosition.latitude,
          userPosition.longitude,
          b.coordinates.latitude,
          b.coordinates.longitude,
        );

        return distanceA.compareTo(distanceB);
      });

      // Armazena no cache
      _mapPlacesCache[cacheKey] = sortedPlaces;
      _setCacheTime('map_$cacheKey');

      return sortedPlaces;
    } catch (e) {
      if (_mapPlacesCache.containsKey(cacheKey)) {
        return _mapPlacesCache[cacheKey]!;
      }
      // Se não tiver cache, propaga o erro
      rethrow;
    }
  }

  // ====================================
  // Métodos auxiliares
  // ====================================

  // Pega todos os lugares
  Future<List<Place>> _getAllPlaces() async {
    // Se o cache for válido, retorna
    if (_allPlacesCache != null &&
        _allPlacesCacheTime != null &&
        DateTime.now().difference(_allPlacesCacheTime!) < _cacheExpiration) {
      return _allPlacesCache!;
    }

    // Se não, consulta o Firestore
    QuerySnapshot querySnapshot = await _firestore.collection('lugares').get();

    // Converte e armazena no cache
    _allPlacesCache = querySnapshot.docs
        .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    _allPlacesCacheTime = DateTime.now();

    return _allPlacesCache!;
  }

  // Gera uma chave de cache baseada na posição do usuário
  String _generatePositionCacheKey(Position position) {
    // Arredonda para criar "células" de aproximadamente 100m
    final lat = (position.latitude * 100).round() / 100;
    final lng = (position.longitude * 100).round() / 100;
    return '$lat,$lng';
  }

  // Verifica se o cache ainda é válido
  bool _isCacheValid(String key) {
    return _cacheTimes.containsKey(key) &&
        DateTime.now().difference(_cacheTimes[key]!) < _cacheExpiration;
  }

  // Define o tempo atual para uma chave de cache
  void _setCacheTime(String key) {
    _cacheTimes[key] = DateTime.now();
  }

  // Implementação da fórmula de Haversine para cálculo de distância
  double _calculateHaversineDistance(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) {
    const double earthRadius = 6371000; // metros

    final dLat = _toRadians(endLatitude - startLatitude);
    final dLon = _toRadians(endLongitude - startLongitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(startLatitude)) *
            math.cos(_toRadians(endLatitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c; // Retorna a distância em metros
  }

  // Converte de graus para radianos
  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  // Método para limpar os caches manualmente quando necessário
  void clearCaches() {
    _categoryCache.clear();
    _cityCache.clear();
    _nearbyPlacesCache.clear();
    _mapPlacesCache.clear();
    _cacheTimes.clear();
    _allPlacesCache = null;
    _allPlacesCacheTime = null;
  }
}
