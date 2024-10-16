import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_chip.dart';
import 'package:sigacidades/presentation/home/widgets/locale_card.dart';
import 'package:sigacidades/data/repositories/locale_repository_impl.dart'; // Instância do repositório concreto
import 'package:sigacidades/common/widgets/app_search_bar.dart';
import 'package:sigacidades/core/utils/category_utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancia a implementação correta do repositório
    final localeRepository = LocaleRepositoryImpl();

    return BlocProvider(
      create: (context) =>
          CategoryBloc(localeRepository)..add(SelectCategoryEvent(0)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: Stack(
          children: [
            // Barra de pesquisa no topo
            Positioned(
              top: 47,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppSearchBar(
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  localeRepository: localeRepository,
                ),
              ),
            ),
            // Conteúdo da página abaixo da barra de pesquisa
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha separadora
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: const Color(0xFFE4E4E4),
                  ),
                  const SizedBox(height: 16),

                  // Container do filtro de categorias
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

                        // BlocBuilder para exibir as categorias
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
                                          // Envia evento para selecionar uma categoria
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
                              return Container(); // Retorna um container vazio para outros estados
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BlocBuilder para exibir os locais filtrados
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
                            itemCount: state.filteredLocales.length,
                            itemBuilder: (context, index) {
                              return localeCard(state.filteredLocales[index]);
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
                          return Container(); // Retorna um container vazio para outros estados
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
