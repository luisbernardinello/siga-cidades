import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/data/repositories/place_repository_impl.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_tag.dart';
import 'package:sigacidades/presentation/home/widgets/place_card.dart';
import 'package:sigacidades/common/widgets/app_search_bar.dart';
import 'package:sigacidades/common/widgets/drawer_menu.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';
import 'package:sigacidades/core/utils/category_utils.dart';

class HomePage extends StatelessWidget {
  // Identificador, serve para preservar o estado quando existe mudança de posição do widget na árvore de widgets
  // Não é estritamente necessário
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializado o placeRepository aqui para ser passado ao AppSearchBar, o que permite que o AppSearchBar
    // acesse os dados dos locais por meio do repositório.
    final placeRepository = PlaceRepositoryImpl();

    // A GlobalKey serve para acessar o estado do Scaffold para controlar a abertura e fechamento do DrawerMenu.
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      // O Scaffold é a base da tela, é a estrutura padrão (AppBar, Drawer, Body).
      key: _scaffoldKey, // Coloca a key ao Scaffold para acessar o estado.
      backgroundColor: const Color(0xFFF2F2F2),

      // ====================================
      // Seção: Drawer Menu
      // ====================================
      drawer: DrawerMenu(
        // Uso do context.read<CategoryBloc>() serve para acessar o Bloc e enviar eventos.
        // Nesse caso, quando uma cidade é selecionada no DrawerMenu, o evento SelectCityEvent é enviado, o que altera o estado da cidade.
        onCitySelected: (city) {
          context.read<CategoryBloc>().add(SelectCityEvent(city));
        },
      ),

      // ====================================
      // Seção: Corpo da página
      // ====================================
      body: Stack(
        children: [
          // ====================================
          // Seção: App Search Bar
          // ====================================
          Positioned(
            top: 47,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchBar(
                // Quando o botão de menu no AppSearchBar é pressionado, o _scaffoldKey.currentState abre o Drawer.
                onMenuTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                // Aqui é passado o placeRepository para o AppSearchBar para que ele possa buscar os lugares do repositório.
                placeRepository: placeRepository,
              ),
            ),
          ),

          // ====================================
          // Seção: Conteúdo principal (categorias e lugares)
          // ====================================
          Positioned(
            top: 120,
            left: 16,
            right: 16,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====================================
                // Seção: Linha divisória
                // ====================================
                Container(
                  width: double.infinity,
                  height: 2,
                  color: const Color(0xFFE4E4E4),
                ),
                const SizedBox(height: 16),

                // ====================================
                // Seção: Título "Explore"
                // ====================================
                const Text(
                  'Explore',
                  style: TextStyle(
                    color: Color(0xFF080808),
                    fontSize: 16,
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),

                // ====================================
                // Seção: Categorias dos lugares
                // ====================================
                BlocBuilder<CategoryBloc, CategoryState>(
                  // O BlocBuilder fica observando as mudanças de estado no CategoryBloc.
                  // Dependendo do estado (carregando, carregado ou erro).
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      // Quando o estado é de carregado, exibe a lista de categorias como SingleChildScrollView.
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            getCategoryNames().length,
                            (index) => GestureDetector(
                              // Envia o evento de seleção de categoria ao clicar em uma tag.
                              onTap: () {
                                context
                                    .read<CategoryBloc>()
                                    .add(SelectCategoryEvent(index));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
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
                      // Estado "Carregando": exibe uma barra de loading enquanto as categorias são carregadas.
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoryError) {
                      // Estado "Erro": Exibe uma mensagem de erro.
                      return Center(child: Text(state.message));
                    } else {
                      // Estado Padrão: Trata o caso de não ter nenhum estado, retorna um Container vazio.
                      return Container();
                    }
                  },
                ),

                const SizedBox(height: 20),

                // ====================================
                // Seção: Grid que contém os lugares
                // ====================================
                Expanded(
                  // O Expanded é para o grid ocupar todo o espaço restante dentro do Column.
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        // Estado "Carregado": Exibe a lista de lugares em um grid.
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Duas colunas no grid.
                            crossAxisSpacing: 16.0, // Espaçamento horizontal.
                            mainAxisSpacing: 16.0, // Espaçamento vertical.
                            childAspectRatio: 1.2, // Proporção largura/altura.
                          ),
                          // itemCount gera o número de itens no grid com base no número de lugares que foram carregados.
                          itemCount: state.filteredPlaces.length,
                          // itemBuilder constrói cada item (card do lugar) do grid com os detalhes do lugar.
                          itemBuilder: (context, index) {
                            final place = state.filteredPlaces[index];
                            return GestureDetector(
                              onTap: () {
                                // Se clicar em um lugar, vai para a página PlacePage e exibe o lugar.
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
                        // Estado "Carregando": exibe uma barra de loading enquanto as categorias são carregadas.
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CategoryError) {
                        // Estado "Erro": Exibe uma mensagem de erro.
                        return Center(child: Text(state.message));
                      } else {
                        // Estado Padrão: Trata o caso de não ter nenhum estado, retorna um Container vazio.
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
