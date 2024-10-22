import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_bloc.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_event.dart';
import 'package:sigacidades/presentation/distances/bloc/distances_state.dart';
import 'package:sigacidades/presentation/distances/widgets/place_distance_widget.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';

/// Página que exibe os locais próximos ao usuário.
/// Utiliza o padrão Bloc para gerenciar o estado da busca de locais.
class DistancesPage extends StatelessWidget {
  static const routeName = '/distances'; // Nome da rota para navegação

  const DistancesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Define a margem lateral da página
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinhamento do conteúdo na esquerda
        children: [
          const SizedBox(height: 16),

          // ====================================
          // Seção: Título "Locais próximos"
          // ====================================
          const Text(
            'Locais próximos',
            style: TextStyle(
              color: Color(0xFF080808),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),

          // ====================================
          // Seção: Lista de lugares com distâncias
          // ====================================
          Expanded(
            child: BlocProvider(
              // BLoC responsável por buscar os lugares próximos
              create: (context) => DistancesBloc(
                  context.read<PlaceRepository>())
                ..add(
                    FetchNearbyPlacesEvent()), // Evento para carregar lugares próximos
              child: BlocBuilder<DistancesBloc, DistancesState>(
                builder: (context, state) {
                  if (state is DistancesLoading) {
                    // Estado de carregamento, exibe o indicador de carregamento enquanto os lugares estão sendo buscados
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DistancesPermissionRequired ||
                      state is DistancesError) {
                    // Mensagens de erro ou permissão necessária
                    String message;
                    if (state is DistancesPermissionRequired) {
                      message =
                          state.message; // Mensagem de permissão necessária
                    } else if (state is DistancesError) {
                      message = state.message; // Mensagem de erro
                    } else {
                      message =
                          "Ocorreu um erro inesperado."; // Caso ocorra um erro não previsto
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
                                // Botão de tentar novamente gera o evento para tentar buscar os lugares
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
                    // Quando os lugares e distâncias são carregados com sucesso
                    final nearbyPlaces = state
                        .nearbyPlacesWithDistances; // Lista de lugares e suas distâncias

                    return ListView.builder(
                      itemCount: nearbyPlaces
                          .length, // Define a quantidade de itens na lista
                      itemBuilder: (context, index) {
                        final placeData = nearbyPlaces[
                            index]; // Dados do lugar no index atual
                        final place =
                            placeData['place'] as Place; // Instância do lugar
                        final distance = placeData['distance']
                            as double; // Distância do lugar

                        // Adiciona GestureDetector para navegação ao PlacePage ao clicar no card
                        return GestureDetector(
                          onTap: () {
                            // Navega para a pagina de detalhes do lugar
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlacePage(
                                    place:
                                        place), // Passa o lugar selecionado para PlacePage
                              ),
                            );
                          },
                          child: PlaceDistanceWidget(
                            place: place, // Passa o lugar para o widget
                            distance:
                                distance, // Passa a distância para o widget
                          ),
                        );
                      },
                    );
                  }
                  return Container(); // Retorna um container vazio para o estado padrão
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
