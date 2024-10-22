import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_tag.dart';
import 'package:sigacidades/presentation/home/widgets/place_card.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';
import 'package:sigacidades/core/utils/category_utils.dart';

// ====================================
// Classe HomePage (Tela Inicial)
// ====================================
// Tela principal que exibe as categorias e lugares. Usa o Bloc para gerenciar
// o estado da tela com base na seleção de categorias.
class HomePage extends StatelessWidget {
  static const routeName = '/home'; // Nome da rota para navegação

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0), // Espaçamento lateral
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ====================================
          // Seção: Título "Explore"
          // ====================================
          const Text(
            'Explore',
            style: TextStyle(
              color: Color(0xFF080808),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),

          // ====================================
          // Seção: Categorias dos lugares
          // ====================================
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoaded) {
                // Exibe as categorias como botões horizontais
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      getCategoryNames().length,
                      (index) => GestureDetector(
                        onTap: () {
                          // Dispara evento de seleção de categoria
                          context
                              .read<CategoryBloc>()
                              .add(SelectCategoryEvent(index));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0), // Espaçamento entre categorias
                          child: categoryTag(
                            getCategoryNames()[index],
                            index ==
                                state
                                    .selectedIndex, // Verifica se a categoria está selecionada
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else if (state is CategoryLoading) {
                // Exibe o loading enquanto carrega as categorias
                return const Center(child: CircularProgressIndicator());
              } else if (state is CategoryError) {
                // Exibe mensagem de erro se não conseguir carregar as categorias
                return Center(child: Text(state.message));
              } else {
                return Container();
              }
            },
          ),
          const SizedBox(height: 20),

          // ====================================
          // Seção: Grid que contém os lugares
          // ====================================
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded) {
                  // Exibe os lugares em um GridView
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Número de colunas no grid
                      crossAxisSpacing:
                          16.0, // Espaçamento horizontal entre os cards
                      mainAxisSpacing:
                          16.0, // Espaçamento vertical entre os cards
                      childAspectRatio:
                          1.2, // Proporção largura/altura dos cards
                    ),
                    itemCount: state
                        .filteredPlaces.length, // Número de lugares filtrados
                    itemBuilder: (context, index) {
                      final place =
                          state.filteredPlaces[index]; // Obtém o lugar atual

                      // Adiciona GestureDetector para navegar para PlacePage
                      return GestureDetector(
                        onTap: () {
                          // Navega para PlacePage ao clicar no card
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlacePage(place: place),
                            ),
                          );
                        },
                        child: placeCard(place), // Exibe o card do lugar
                      );
                    },
                  );
                } else if (state is CategoryLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Exibe loading enquanto carrega os lugares
                } else if (state is CategoryError) {
                  return Center(
                      child: Text(state.message)); // Exibe mensagem de erro
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
