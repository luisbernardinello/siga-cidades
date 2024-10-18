import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_chip.dart';
import 'package:sigacidades/presentation/home/widgets/place_card.dart';
import 'package:sigacidades/data/repositories/place_repository_impl.dart';
import 'package:sigacidades/common/widgets/app_search_bar.dart';
import 'package:sigacidades/common/widgets/drawer_menu.dart';
import 'package:sigacidades/core/utils/category_utils.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart'; // Import da PlacePage

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final placeRepository = PlaceRepositoryImpl();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF2F2F2),
      drawer: DrawerMenu(
        onCitySelected: (city) {
          context.read<CategoryBloc>().add(SelectCityEvent(city));
        },
      ),
      body: Stack(
        children: [
          Positioned(
            top: 47,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchBar(
                onMenuTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                placeRepository: placeRepository,
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 16,
            right: 16,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 2,
                  color: const Color(0xFFE4E4E4),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 71,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Explore',
                            style: TextStyle(
                              color: Color(0xFF080808),
                              fontSize: 16,
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 15),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoaded) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  getCategoryNames().length,
                                  (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        context
                                            .read<CategoryBloc>()
                                            .add(SelectCategoryEvent(index));
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: categoryChip(
                                          getCategoryNames()[index],
                                          index == state.selectedIndex,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          } else if (state is CategoryLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is CategoryError) {
                            return Center(
                              child: Text(state.message),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: state.filteredPlaces.length,
                          itemBuilder: (context, index) {
                            final place = state.filteredPlaces[index];

                            // Navega para PlacePage ao clicar no card
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlacePage(place: place),
                                  ),
                                );
                              },
                              child: placeCard(place),
                            );
                          },
                        );
                      } else if (state is CategoryLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is CategoryError) {
                        return Center(
                          child: Text(state.message),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
