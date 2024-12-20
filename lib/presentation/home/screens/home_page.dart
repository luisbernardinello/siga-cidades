import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_tag.dart';
import 'package:sigacidades/presentation/home/widgets/place_card.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';
import 'package:sigacidades/core/utils/category_list.dart';

// ====================================
// HomePage: Tela inicial com categorias e lugares
// ====================================
// A HomePage exibe categorias e os lugares disponíveis para uma cidade
// selecionada. Ela utiliza o CategoryBloc para gerenciar o estado das
// categorias e dos lugares. O usuário consegue ir para a screen de detalhes
// de um lugar ao clicar em um card.
class HomePage extends StatelessWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    final double horizontalPadding = isDesktop ? 32.0 : 16.0;
    final double categoryTagWidth =
        isDesktop ? 150.0 : (isTablet ? 120.0 : 100.0);
    final int gridCrossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Título da seção "Explore"
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              final cityName = context.read<CategoryBloc>().selectedCity;
              return Semantics(
                header: false,
                label:
                    'Conteúdo principal de seleção de lugares com opção de filtros de categoria.',
                hint:
                    'Explore locais em $cityName ou escolha uma nova cidade no menu superior',
                excludeSemantics: true,
                child: const Text(
                  'Explore',
                  style: TextStyle(
                    color: Color(0xFF080808),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 15),

          // Carrossel de categorias com acessibilidade
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              final selectedIndex =
                  (state is CategoryLoaded) ? state.selectedIndex : -1;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: ScrollController(
                  initialScrollOffset: (selectedIndex + 1) * categoryTagWidth,
                ),
                child: Row(
                  children: List.generate(
                    getCategoryNames().length,
                    (index) => GestureDetector(
                      onTap: () {
                        context
                            .read<CategoryBloc>()
                            .add(SelectCategoryEvent(index - 1));

                        SemanticsService.announce(
                          '${getCategoryNames()[index]} selecionada',
                          TextDirection.ltr,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: categoryTag(
                          getCategoryNames()[index],
                          index - 1 == selectedIndex,
                          screenWidth: screenWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Grid de lugares com acessibilidade
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCrossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: state.filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = state.filteredPlaces[index];

                      // PlaceCard com FutureBuilder para exibir CircularProgressIndicator enquanto carrega
                      return FutureBuilder(
                        future: Future.delayed(Duration.zero),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          return Semantics(
                            label: 'Lugar: ${place.name}',
                            hint: 'Toque para mais detalhes',
                            button: true,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlacePage(place: place),
                                  ),
                                );
                              },
                              child: placeCard(place, isDesktop),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryError) {
                  return Center(child: Text(state.message));
                } else {
                  return Container();
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
