import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_tag.dart';
import 'package:sigacidades/presentation/home/widgets/place_card.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';
import 'package:sigacidades/core/utils/category_utils.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

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
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      getCategoryNames().length,
                      (index) => GestureDetector(
                        onTap: () {
                          context
                              .read<CategoryBloc>()
                              .add(SelectCategoryEvent(index));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0), // Espaçamento entre categorias
                          child: categoryTag(
                            getCategoryNames()[index],
                            index == state.selectedIndex,
                          ),
                        ),
                      ),
                    ),
                  ),
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

          const SizedBox(height: 20),

          // ====================================
          // Seção: Grid que contém os lugares
          // ====================================
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Duas colunas no grid
                      crossAxisSpacing:
                          16.0, // Espaçamento horizontal entre cards
                      mainAxisSpacing: 16.0, // Espaçamento vertical entre cards
                      childAspectRatio: 1.2, // Proporção largura/altura
                    ),
                    itemCount: state.filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = state.filteredPlaces[index];

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
                        child: placeCard(place),
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
          ),
        ],
      ),
    );
  }
}
