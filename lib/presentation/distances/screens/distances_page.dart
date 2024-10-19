import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_bloc.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_event.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_state.dart';
import 'package:sigacidades/presentation/distances/widgets/place_distance_widget.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/domain/entities/place.dart';

class DistancesPage extends StatelessWidget {
  static const routeName = '/distances';

  const DistancesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mantemos a lógica do DistancesBloc para obter os lugares e distâncias
    return BlocProvider(
      create: (context) => DistancesBloc(context.read<PlaceRepository>())
        ..add(FetchNearbyPlacesEvent()), // Carregar lugares próximos
      child: BlocBuilder<DistancesBloc, DistancesState>(
        builder: (context, state) {
          if (state is DistancesLoading) {
            // Exibe um indicador de carregamento enquanto os lugares estão sendo carregados
            return const Center(child: CircularProgressIndicator());
          } else if (state is DistancesPermissionRequired ||
              state is DistancesError) {
            // Lógica de exibição de mensagem de erro ou permissão requerida
            String message;
            if (state is DistancesPermissionRequired) {
              message = state.message;
            } else if (state is DistancesError) {
              message = state.message;
            } else {
              message = "Ocorreu um erro inesperado.";
            }

            // Exibe a mensagem de erro centralizada
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<DistancesBloc>()
                            .add(FetchNearbyPlacesEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Tentar Novamente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is DistancesLoaded) {
            // Quando os lugares e distâncias são carregados
            final nearbyPlaces = state.nearbyPlacesWithDistances;

            return ListView.builder(
              itemCount: nearbyPlaces.length,
              itemBuilder: (context, index) {
                final placeData = nearbyPlaces[index];
                final place = placeData['place'] as Place;
                final distance = placeData['distance'] as double;

                return PlaceDistanceWidget(
                  place: place,
                  distance: distance,
                );
              },
            );
          }
          return Container(); // Estado padrão
        },
      ),
    );
  }
}
