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
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapsPage extends StatefulWidget {
  static const routeName = '/maps';

  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  // Controller do mapa
  late MapController _mapController;

  // Posição atual do usuário
  late LatLng _currentPosition;

  // Lista de marcadores para exibir no mapa
  final List<Marker> _markers = [];

  // Definimos os limites da América do Sul
  final LatLngBounds _southAmericaBounds = LatLngBounds(
    LatLng(-56.0, -81.0), // Extremo sudoeste (Chile)
    LatLng(13.0, -34.0), // Extremo nordeste (Venezuela)
  );

  // ====================================
  // Método initState
  // ====================================
  @override
  void initState() {
    super.initState();

    // Inicializa o MapController
    _mapController = MapController();

    // Dispara o evento Bloc para carregar a localização do usuário e os lugares
    context.read<MapsBloc>().add(LoadUserLocationAndPlaces());
  }

  // ====================================
  // Função para animar o movimento do mapa
  // ====================================
  // Anima suavemente a transição do mapa para uma nova posição e nível de zoom
  // Utilizamos o Tween<double> para criar uma interpolação entre os valores de latitude, longitude e zoom.
  // O AnimationController controla a animação e o TickerProviderStateMixin é usado para sincronizar essa animação com o tempo de tela.
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;

    // Interpolação entre os valores de latitude e longitude atuais e os valores de destino
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Controller da animação, responsável por gerenciar o tempo de animação.
    // O vsync controla a sincronização da animação com o tempo da tela para otimizar o desempenho.
    final controller = AnimationController(
      duration:
          const Duration(milliseconds: 300), // Duração da animação (300ms)
      vsync: this, // Vsync usado para gerenciar a animação de forma eficiente
    );

    // Definimos a curva de animação, que usa um movimento suave de início e término (easeInOut).
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    // O listener atualiza o mapa à medida que a animação é executada.
    controller.addListener(() {
      _mapController.move(
        LatLng(
            latTween.evaluate(animation),
            lngTween.evaluate(
                animation)), // Movimenta o mapa para as novas coordenadas
        zoomTween.evaluate(animation), // Aplica o novo nível de zoom
      );
    });

    // Inicia a animação
    controller.forward();
  }

  // ====================================
  // Função para abrir aplicativos externos de mapas usando map_launcher (Google Maps, Waze, etc.)
  // ====================================
  // MapLauncher detecta os mapas instalados no dispositivo do usuário
  Future<void> _openInMapLauncher(Place place) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                // Exibe a lista de aplicativos de mapas disponíveis
                children: availableMaps.map((map) {
                  return ListTile(
                    onTap: () {
                      // Abre o mapa escolhido e marca a localização de Place
                      map.showMarker(
                        coords: Coords(
                          place.coordinates.latitude,
                          place.coordinates.longitude,
                        ),
                        title: place.name,
                        description: place.adress,
                      );
                      Navigator.pop(
                          context); // Fecha o modal depoois da seleção
                    },
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon, // Icone do app de mapas do SVG (na documentação, a maioria dos apps de localização estão disponíveis)
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
      // Caso nenhum app de mapas seja encontrado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum aplicativo de mapas encontrado.'),
        ),
      );
    }
  }

  // ====================================
  // Widget build
  // ====================================
  // Responsável por construir o layout da página com o mapa e os componentes
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapsBloc, MapsState>(
      builder: (context, state) {
        if (state is MapsLoading) {
          // Exibe o loading enquanto o mapa está sendo carregado
          return const Center(child: CircularProgressIndicator());
        } else if (state is MapsLoaded) {
          // Posição do usuário carregada do estado
          _currentPosition = LatLng(
            state.userLocation.latitude,
            state.userLocation.longitude,
          );

          // Se a posição estiver fora dos limites da América do Sul, ajusta para o centro
          if (!_southAmericaBounds.contains(_currentPosition)) {
            _currentPosition = _southAmericaBounds.center;
          }

          // Adiciona o marcador da posição atual do usuário no mapa
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

          // Adiciona os marcadores dos lugares carregados
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
                  onTap: () => _openInMapLauncher(
                      place), // Abre os mapas externos ao clicar
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
                // ====================================
                // FlutterMap
                // ====================================
                // Componente principal que renderiza o mapa
                FlutterMap(
                  mapController: _mapController, // Controlador do mapa
                  // Opções do mapa
                  options: MapOptions(
                    initialCenter:
                        _currentPosition, // Posição inicial do usuário
                    initialZoom: 15, // Zoom inicial
                    maxZoom: 18, // Zoom máximo permitido
                    cameraConstraint: CameraConstraint.contain(
                      bounds:
                          _southAmericaBounds, // Limita a área de navegação do mapa
                    ),
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all &
                          ~InteractiveFlag
                              .rotate, // Permite todas as interações e desativa somente a rotação do mapa
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: FMTCStore('mapStore')
                          .getTileProvider(), // Usa cache de tiles do flutter_map_tile_caching
                      keepBuffer: 3, // Colocamos mais tiles na memória
                      panBuffer: 2, // Carrega mais tiles ao redor da camera
                    ),
                    MarkerLayer(
                      markers: _markers, // Exibe os marcadores no mapa
                    ),
                  ],
                ),

                // ====================================
                // Título "Mapa Interativo"
                // ====================================
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

                // ====================================
                // Botões de Zoom In e Zoom Out
                // ====================================
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
                            _mapController.camera.zoom + 1, // Aumenta o zoom
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
                            _mapController.camera.zoom - 1, // Diminui o zoom
                          );
                        },
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),

                // ====================================
                // Botão para centralizar no usuário
                // ====================================
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: 'center_on_user',
                    mini: true,
                    onPressed: () {
                      _animatedMapMove(
                          _currentPosition, 15); // Centraliza o mapa no usuário
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
