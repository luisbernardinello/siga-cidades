import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/maps/bloc/maps_bloc.dart';
import 'package:sigacidades/presentation/maps/bloc/maps_event.dart';
import 'package:sigacidades/presentation/maps/bloc/maps_state.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapsPage extends StatefulWidget {
  static const routeName = '/maps';

  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  late MapController _mapController;
  late LatLng _currentPosition;
  final List<Marker> _markers = [];

  // Definimos os limites da América do Sul
  final LatLngBounds _southAmericaBounds = LatLngBounds(
    LatLng(-56.0, -81.0), // Extremo sudoeste (Chile)
    LatLng(13.0, -34.0), // Extremo nordeste (Venezuela)
  );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Dispara evento para carregar localização do usuário e os lugares
    context.read<MapsBloc>().add(LoadUserLocationAndPlaces());
  }

  // Função para animar suavemente o mapa para a posição desejada, com duração reduzida
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.forward();
  }

  // Função para abrir o Map Launcher com os mapas disponíveis no dispositivo
  Future<void> _openInMapLauncher(Place place) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                children: availableMaps.map((map) {
                  return ListTile(
                    onTap: () {
                      map.showMarker(
                        coords: Coords(
                          place.coordinates.latitude,
                          place.coordinates.longitude,
                        ),
                        title: place.name,
                        description: place.adress,
                      );
                      Navigator.pop(context);
                    },
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon, // Ícone do app de mapas
                      height: 30,
                      width: 30,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum aplicativo de mapas encontrado.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapsBloc, MapsState>(
      builder: (context, state) {
        if (state is MapsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MapsLoaded) {
          _currentPosition = LatLng(
            state.userLocation.latitude,
            state.userLocation.longitude,
          );

          if (!_southAmericaBounds.contains(_currentPosition)) {
            _currentPosition = _southAmericaBounds.center;
          }

          _markers.add(
            Marker(
              point: _currentPosition,
              width: 80,
              height: 80,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 40,
              ),
            ),
          );

          for (Place place in state.places) {
            _markers.add(
              Marker(
                point: LatLng(
                  place.coordinates.latitude,
                  place.coordinates.longitude,
                ),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => _openInMapLauncher(place),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentPosition, // Centraliza no local do usuário
                    initialZoom: 15, // Zoom inicial
                    maxZoom: 18,
                    cameraConstraint: CameraConstraint.contain(
                      bounds:
                          _southAmericaBounds, // Limite até a América do Sul
                    ),
                    interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.all &
                            ~InteractiveFlag.rotate // não pode arrastar o mapa
                        ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: NetworkTileProvider(),
                      keepBuffer:
                          3, // Manter mais tiles em memória enquanto navega
                      panBuffer:
                          2, // Carregar mais tiles ao redor durante o movimento do mapa
                    ),
                    MarkerLayer(
                      markers: _markers,
                    ),
                  ],
                ),

                // Título "Mapa Interativo"
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    color: Colors.black.withOpacity(0.2),
                    child: const Text(
                      'Mapa Interativo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Botões de zoom no canto superior direito
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoom_in',
                        mini: true,
                        onPressed: () {
                          _animatedMapMove(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoom_out',
                        mini: true,
                        onPressed: () {
                          _animatedMapMove(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),

                // Botão para centralizar o mapa na posição do usuário
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: 'center_on_user',
                    mini: true,
                    onPressed: () {
                      _animatedMapMove(_currentPosition,
                          15); // Anima suavemente para o usuário
                    },
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is MapsError) {
          return Center(
            child: Text(
              'Erro ao carregar mapa: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return Container(); // Estado padrão
      },
    );
  }
}
