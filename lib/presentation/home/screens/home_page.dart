import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_tag.dart';
import 'package:sigacidades/presentation/home/widgets/place_card.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';
import 'package:sigacidades/core/utils/category_utils.dart';

/// Página principal (Home) com exibição das categorias e lugares.
/// Esta classe utiliza do Bloc para pegar os dados e controlar o estado da interface.
class HomePage extends StatelessWidget {
  static const routeName =
      '/home'; // Nome da rota para uso na main_screen.dart.

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0), // Espaçamento lateral.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ====================================
          // Seção: Título "Explore"
          // ====================================
          // Exibe o título principal "Explore" na página inicial.
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
          // Seção: Carrossel de categorias
          // ====================================
          // O BlocBuilder monitora as mudanças de estado e atualiza o carrossel de categorias.
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              // Define a categoria selecionada sendo o index da CategoryLoaded.
              final selectedIndex =
                  (state is CategoryLoaded) ? state.selectedIndex : 0;

              // Usa um controlador de scroll para manter a posição do carrossel na categoria selecionada.
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: ScrollController(
                  initialScrollOffset: selectedIndex * 80.0,
                ),
                child: Row(
                  children: List.generate(
                    getCategoryNames().length,
                    (index) => GestureDetector(
                      onTap: () {
                        // Ao clicar em uma categoria, emite um evento para selecionar a categoria.
                        context
                            .read<CategoryBloc>()
                            .add(SelectCategoryEvent(index));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        // Usa o widget categoryTag para exibir a tag de cada categoria.
                        child: categoryTag(
                          getCategoryNames()[index],
                          index ==
                              selectedIndex, // Passa o index sendo a categoria selecionada.
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ====================================
          // Seção: Exibição de lugares no grid
          // ====================================
          // O GridView exibe os lugares da categoria selecionada e faz o monitoramento das mudanças de estado no CategoryBloc.
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded) {
                  // Faz a exibição dos lugares usando um GridView com base nos dados filtrados da categoria selecionada.
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Exibe duas colunas de cards.
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: state.filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = state.filteredPlaces[index];

                      // Ao clicar em um lugar, direciona para a página de detalhes do lugar.
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlacePage(place: place),
                            ),
                          );
                        },
                        child: placeCard(
                            place), // Usa o widget placeCard para exibir o card de cada lugar.
                      );
                    },
                  );
                } else if (state is CategoryError) {
                  // Em caso de erro exibe uma feedback para o usuário.
                  return Center(child: Text(state.message));
                } else {
                  return Container(); // Retorna um layout vazio durante o carregamento (para não exibir o loader).
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
