import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_bloc.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_event.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_state.dart';
import 'package:sigacidades/presentation/distances/widgets/place_distance_widget.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';

class DistancesPage extends StatefulWidget {
  static const routeName = '/distances';

  final FocusNode? focusNode;

  const DistancesPage({super.key, this.focusNode});

  @override
  State<DistancesPage> createState() => _DistancesPageState();
}

class _DistancesPageState extends State<DistancesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final DistancesBloc _distancesBloc;

  final Map<String, Widget> _memoizedWidgets = {};

  @override
  void initState() {
    super.initState();
    _distancesBloc = DistancesBloc(context.read<PlaceRepository>())
      ..add(FetchNearbyPlacesEvent());
  }

  @override
  void dispose() {
    _distancesBloc.close();
    // Limpa o cache de widgets
    _memoizedWidgets.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    final titleFontSize = isDesktop ? 16.0 : (isTablet ? 18.0 : 16.0);
    final buttonFontSize = isDesktop ? 18.0 : 16.0;
    final spacingBetweenItems = isDesktop ? 24.0 : 16.0;

    return Focus(
      focusNode: widget.focusNode,
      autofocus: true,
      child: Semantics(
        label:
            'Conteúdo de localização, contendo os lugares mais próximos por distância',
        focusable: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _getOrCreateMemoizedWidget(
                'header_$titleFontSize',
                () => _buildHeader(titleFontSize),
              ),
              SizedBox(height: spacingBetweenItems),
              Expanded(
                child: BlocProvider.value(
                  value: _distancesBloc,
                  child: BlocBuilder<DistancesBloc, DistancesState>(
                    builder: (context, state) {
                      if (state is DistancesLoading) {
                        return _getOrCreateMemoizedWidget(
                          'loading_indicator',
                          () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is DistancesPermissionRequired ||
                          state is DistancesError) {
                        final message = state is DistancesPermissionRequired
                            ? state.message
                            : (state as DistancesError).message;
                        return _buildErrorView(
                          message,
                          titleFontSize,
                          buttonFontSize,
                        );
                      } else if (state is DistancesLoaded) {
                        return _buildPlacesList(
                          state.nearbyPlacesWithDistances,
                          isTablet,
                          isDesktop,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sistema de memoização para widgets que não mudam frequentemente
  Widget _getOrCreateMemoizedWidget(String key, Widget Function() builder) {
    return _memoizedWidgets.putIfAbsent(key, builder);
  }

  Widget _buildHeader(double titleFontSize) {
    return Semantics(
      label: "Locais próximos",
      header: true,
      focusable: true,
      excludeSemantics: true,
      child: Text(
        'Locais próximos',
        style: TextStyle(
          color: const Color(0xFF080808),
          fontSize: titleFontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildErrorView(
      String message, double titleFontSize, double buttonFontSize) {
    final key = 'error_view_${message.hashCode}_$titleFontSize';

    return _getOrCreateMemoizedWidget(
      key,
      () => Center(
        child: Semantics(
          label: 'Erro ao carregar locais próximos: $message',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _distancesBloc.add(FetchNearbyPlacesEvent()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Tentar Novamente',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacesList(
      List<Map<String, dynamic>> nearbyPlaces, bool isTablet, bool isDesktop) {
    final separatorHeight = isDesktop ? 16.0 : 8.0;
    final separatorWidget = SizedBox(height: separatorHeight);

    return ListView.separated(
      key: const ValueKey('places-list'),
      itemCount: nearbyPlaces.length,
      cacheExtent: 500, // Aumenta o cache para manter mais itens em memória
      addAutomaticKeepAlives: true, // Mantem os itens mesmo quando não visíveis
      separatorBuilder: (context, index) => separatorWidget,
      itemBuilder: (context, index) {
        final placeData = nearbyPlaces[index];
        final place = placeData['place'] as Place;
        final distance = placeData['distance'] as double;

        // Usa RepaintBoundary
        return RepaintBoundary(
          child: _PlaceItem(
            place: place,
            distance: distance,
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        );
      },
    );
  }
}

class _PlaceItem extends StatelessWidget {
  final Place place;
  final double distance;
  final bool isTablet;
  final bool isDesktop;

  const _PlaceItem({
    required this.place,
    required this.distance,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final widget = PlaceDistanceWidget(
      place: place,
      distance: distance,
      isTablet: isTablet,
      isDesktop: isDesktop,
    );

    final isError = widget.hasError();

    return Semantics(
      label: isError ? '${place.name}, lugar.' : null,
      hint: isError
          ? 'Erro ao carregar, ${place.name} não pode ser selecionado. Por favor, contate-nos!'
          : null,
      button: !isError,
      child: isError
          ? widget
          : GestureDetector(
              onTap: isError
                  ? null
                  : () {
                      SemanticsService.announce(
                        '${place.name}, lugar selecionado.',
                        TextDirection.ltr,
                      );
                      // Vai para a página do lugar
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlacePage(place: place),
                        ),
                      );
                    },
              child: widget,
            ),
    );
  }
}
