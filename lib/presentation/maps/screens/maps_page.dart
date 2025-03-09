import 'dart:io';
import 'package:flutter/foundation.dart';
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
import 'package:sigacidades/presentation/place/screens/place_page.dart';

class MapsPage extends StatefulWidget {
  static const routeName = '/maps';

  // Adicionando o FocusNode como parâmetro opcional
  final FocusNode? focusNode;

  const MapsPage({super.key, this.focusNode});

  @override
  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  // Controller do mapa
  late MapController _mapController;

  // Posição atual do usuário
  late LatLng _currentPosition;

  // Lista de marcadores para exibir no mapa
  final List<Marker> _markers = [];

  // Limites da América do Sul
  final LatLngBounds _southAmericaBounds = LatLngBounds(
    const LatLng(-56.0, -81.0), // Ponto no extremo sudoeste (Chile)
    const LatLng(13.0, -34.0), // Ponto no extremo nordeste (Venezuela)
  );
  OverlayEntry? _overlayEntry;
  // ====================================
  // Método initState
  // ====================================
  @override
  void initState() {
    super.initState();

    // Inicializa o MapController
    _mapController = MapController();

    // Envia o evento Bloc para carregar a localização do usuário e os lugares
    context.read<MapsBloc>().add(LoadUserLocationAndPlaces());
  }

  @override
  void dispose() {
    _removeOverlay(); // Fechar o overlay automaticamente
    _mapController.dispose(); // Liberar recursos do MapController
    super.dispose();
  }

  // ====================================
  // Função para animar o movimento do mapa
  // ====================================

  // Torna suave a transição do mapa para uma nova posição e nível de zoom (zoom in e zoom out),
  // em vez de mudar agressivamente.
  // Tween<double> cria uma interpolação (pega dois valores (início e fim) e gera valores intermediários).
  // Faz isso para valores de latitude, longitude e zoom.
  // AnimationController controla a animação e o TickerProviderStateMixin é usado para sincronizar
  // essa animação com o tempo de tela.

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
      vsync: this,
    );

    // Curva de animação, usa um movimento easeInOut para ficar suave no início e no fim.
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    // O listener faz a atualização do mapa conforme a animação é executada.
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
// Função para abrir aplicativos externos de mapas usando map_launcher e direcionar para a página de lugares
// ====================================
  /// Função que adapta a exibição do modal para todas as plataformas
  Future<void> _showPlaceDetailsModal(Place place) async {
    final availableMaps = await MapLauncher.installedMaps;

    // Verifica se o widget ainda está montado após o await.
    if (!mounted) return;

    // Seleciona a função correta com base na plataforma
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      _showDialog(place, availableMaps);
    } else {
      _showBottomSheet(place, availableMaps);
    }
  }

// Função auxiliar para o diálogo (ex: para Web)
  void _showDialog(Place place, List<AvailableMap> availableMaps) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFae35c1),
          title: const Text('Detalhes do Lugar',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nome: ${place.name}',
                  style: const TextStyle(color: Colors.white)),
              Text('Endereço: ${place.adress}',
                  style: const TextStyle(color: Colors.white)),
              if (availableMaps.isNotEmpty)
                ...availableMaps.map((map) {
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
                      Navigator.pop(dialogContext);
                    },
                    title: Text(map.mapName,
                        style: const TextStyle(color: Colors.white)),
                    leading: SvgPicture.asset(map.icon, height: 30, width: 30),
                  );
                }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

// Função auxiliar para o modal (ex: para Android/iOS)
  void _showBottomSheet(Place place, List<AvailableMap> availableMaps) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // 75% da altura
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF444444)),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                  Expanded(
                    child: Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacePage(place: place),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFae35c1)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Mais Detalhes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFae35c1),
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Color(0xFFae35c1), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Abrir com",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                itemCount: availableMaps.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Color(0xFFE0E0E0), height: 1),
                itemBuilder: (context, index) {
                  final map = availableMaps[index];
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
                      Navigator.pop(bottomSheetContext);
                    },
                    title: Text(
                      map.mapName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444),
                      ),
                    ),
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 28,
                      width: 28,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF444444), size: 20),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOverlay(Place place) {
    // Remove overlay se já estiver ativo
    if (_overlayEntry != null) _overlayEntry!.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  place.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(place.adress,
                    style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _removeOverlay();
                  },
                ),
              ),
              const Divider(color: Colors.white),
              TextButton(
                  onPressed: () {
                    _removeOverlay();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlacePage(place: place)),
                    );
                  },
                  child: const SizedBox(
                    width: 300,
                    height: 80,
                    child: ListTile(
                      title: Text(
                        "Ver Detalhes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );

    // Insere o overlay na árvore de widgets
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  // ====================================
  // Widget build
  // ====================================
  // Builda o layout da página com o mapa e os componentes
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    double buttonUserLocationFocus =
        isDesktop ? 40.0 : (isTablet ? 25.0 : 20.0);
    double buttonZoom = isDesktop ? 40.0 : (isTablet ? 25.0 : 20.0);
    double titlePosition = isDesktop ? 30 : (isTablet ? 20 : 10);
    double markerSize = isDesktop ? 100 : (isTablet ? 90 : 80);
    double locationPinIcon = isDesktop ? 60 : (isTablet ? 50 : 40);
    double placeText = isDesktop ? 13 : (isTablet ? 12 : 12);

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

          // Marcador da Posição do Usuário
          _markers.clear(); // Limpa os marcadores antes de adicionar novamente
          _markers.add(
            Marker(
              point: _currentPosition,
              width: markerSize,
              height: markerSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: markerSize * 0.5,
                    height: markerSize * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          Colors.white.withOpacity(0.5), // Círculo translucido
                    ),
                  ),
                  Container(
                    width: markerSize * 0.3,
                    height: markerSize * 0.3,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Círculo sólido
                    ),
                  ),
                  Container(
                    width: markerSize * 0.3,
                    height: markerSize * 0.3,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );

          // Adiciona os marcadores de lugares carregados no Mapa
          for (Place place in state.places) {
            _markers.add(
              Marker(
                point: LatLng(
                  place.coordinates.latitude,
                  place.coordinates.longitude,
                ),
                width: markerSize * 1.15, // 15% a mais do tamanho do container
                height: markerSize *
                    1.3, // 30% a mais de altura em relação ao markerSize para não criar outra variável
                child: kIsWeb ||
                        defaultTargetPlatform == TargetPlatform.macOS ||
                        defaultTargetPlatform == TargetPlatform.windows ||
                        defaultTargetPlatform == TargetPlatform.linux
                    ? ElevatedButton(
                        onPressed: () => _showOverlay(place),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: locationPinIcon,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(153, 0, 0, 0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 160,
                                maxHeight: 80,
                              ),
                              child: Text(
                                place.name,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: placeText,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => _showPlaceDetailsModal(place),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: locationPinIcon,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 160,
                                maxHeight: 80,
                              ),
                              child: Text(
                                place.name,
                                maxLines: 3, // 3 linhas de texto no máximo
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: placeText,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          }

          // Envolve o Scaffold com um widget Focus para gerenciar o foco da página
          return Focus(
            focusNode:
                widget.focusNode, // Usa o FocusNode fornecido pelo MainScreen
            autofocus: true, // Foca automaticamente ao entrar na página
            child: Semantics(
              label:
                  'Conteúdo com Mapa visual interativo para pessoas com baixa visão. Para saber as distâncias aos locais, vá para a página de locais próximos.',
              excludeSemantics: true,
              child: Scaffold(
                body: Stack(
                  children: [
                    Semantics(
                      label: 'Mapa Interativo.',
                      child: // ====================================
                          // FlutterMap
                          // ====================================
                          // Componente principal que renderiza o mapa.
                          FlutterMap(
                        mapController: _mapController, // Controlador do mapa.
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
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all &
                                ~InteractiveFlag
                                    .rotate, // Permite todas as interações e desativa somente a rotação do mapa
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            tileProvider: (kIsWeb ||
                                    Platform.isWindows ||
                                    Platform.isMacOS ||
                                    Platform.isLinux)
                                ? NetworkTileProvider()
                                : const FMTCStore('mapStore')
                                    .getTileProvider(), // Usa cache de tiles do flutter_map_tile_caching
                            keepBuffer: 3, // Colocamos mais tiles na memória
                            panBuffer:
                                2, // Carrega mais tiles ao redor da camera
                          ),
                          MarkerLayer(
                            markers: _markers, // Exibe os marcadores no mapa
                          ),
                        ],
                      ),
                    ),

                    // ====================================
                    // Título "Mapa Interativo"
                    // ====================================
                    // Título do Mapa com fundo escuro e texto claro
                    Positioned(
                      top: titlePosition,
                      left: titlePosition,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Mapa Interativo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // ===============================
                    // Botões de Zoom In e Zoom Out
                    // ===============================
                    Positioned(
                      top: buttonZoom,
                      right: buttonZoom,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'zoom_in',
                            backgroundColor: const Color(0xFFae35c1),
                            onPressed: () {
                              _animatedMapMove(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              );
                            },
                            child: const Icon(Icons.zoom_in,
                                color: Colors.white, size: 34),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'zoom_out',
                            backgroundColor: const Color(0xFFae35c1),
                            onPressed: () {
                              _animatedMapMove(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              );
                            },
                            child: const Icon(Icons.zoom_out,
                                color: Colors.white, size: 34),
                          ),
                        ],
                      ),
                    ),

                    // ===============================
                    // Botão para centralizar no usuário
                    // ===============================
                    Positioned(
                      bottom: buttonUserLocationFocus,
                      right: buttonUserLocationFocus,
                      child: FloatingActionButton(
                        heroTag: 'center_on_user',
                        backgroundColor: const Color(0xFFae35c1),
                        onPressed: () {
                          _animatedMapMove(_currentPosition, 15);
                        },
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 34, // Ícone aumentado
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is MapsError) {
          // Caso de erro, gera erro com mensagem do estado do erro como feedback para o usuário
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
