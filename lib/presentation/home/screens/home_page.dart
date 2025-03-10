import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/home/widgets/category_tag.dart';
import 'package:sigacidades/presentation/home/widgets/place_card.dart';
import 'package:sigacidades/core/utils/category_list.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';
// ====================================
// HomePage: Tela inicial com categorias e lugares
// ====================================
// A HomePage exibe categorias e os lugares disponíveis para uma cidade
// selecionada. Ela utiliza o CategoryBloc para gerenciar o estado das
// categorias e dos lugares. O usuário consegue ir para a screen de detalhes
// de um lugar ao clicar em um card.

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  // FocusNode que recebido do MainScreen`
  final FocusNode? focusNode;

  const HomePage({super.key, this.focusNode});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Mantem um FocusNode que será recriado conforme necessário
  FocusNode? _gridFocusNode;
  final FocusNode _categoriesFocusNode = FocusNode();
  final FocusNode _mainContentFocusNode = FocusNode();

  // Para rastrear quando uma categoria for selecionada
  bool _isCategorySelected = false;

  @override
  void initState() {
    super.initState();

    // Listener para quando o focusNode do widget receber o foco
    if (widget.focusNode != null) {
      widget.focusNode?.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus == true) {
      // tempo para os widgets finalizarem a renderização
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _categoriesFocusNode.requestFocus();

        SemanticsService.announce(
          'Página inicial carregada.',
          TextDirection.ltr,
        );
      });
    }
  }

  @override
  void dispose() {
    _gridFocusNode?.dispose();
    _categoriesFocusNode.dispose();
    _mainContentFocusNode.dispose();
    // Remove o listener para evitar memory leaks
    if (widget.focusNode != null) {
      widget.focusNode?.removeListener(_handleFocusChange);
    }

    super.dispose();
  }

  // Aloca memória para instanciar dinamicamente um FocusNode sempre que o usuário clica em alguma categoria.
  // Assim garantimos que o FocusNode vai estar sempre disponível e direcionado para o grid de lugares.
  // Isso foi feito para resolver o problema do FocusNode ir para o grid apenas na primeira vez que uma categoria é selecionada.
  void _updateFocusNode() {
    // Descarta o antigo FocusNode se existir para evitar memory leaks
    _gridFocusNode?.dispose();
    // Cria um FocusNode para a interação
    _gridFocusNode = FocusNode();
    // Muda o foco depois da renderização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Solicita o foco para o grid e reseta a flag
      if (_isCategorySelected &&
          _gridFocusNode != null &&
          _gridFocusNode!.canRequestFocus) {
        _gridFocusNode!.requestFocus();
        _isCategorySelected = false;

        // Colocado atraso de 1 segundo antes de descartar o FocusNode para garantir que dê tempo do foco ir para o grid de lugares
        Future.delayed(const Duration(seconds: 1), () {
          _gridFocusNode?.dispose();
          _gridFocusNode = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery para obter o tamanho da tela
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    final double horizontalPadding = isDesktop ? 32.0 : 16.0;
    final double categoryTagWidth =
        isDesktop ? 150.0 : (isTablet ? 140.0 : 130.0);
    final int gridCrossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return Focus(
      focusNode: widget.focusNode,
      autofocus: false,
      child: Semantics(
        label:
            'Conteúdo principal de seleção de lugares com opção de filtros de categoria.',
        focusable: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Título da seção "Explore"
              BlocBuilder<CategoryBloc, CategoryState>(
                buildWhen: (previous, current) {
                  // Rebuild somente quando a cidade mudar
                  return previous is! CategoryLoaded ||
                      current is! CategoryLoaded ||
                      context.read<CategoryBloc>().selectedCity !=
                          (previous).selectedCity;
                },
                builder: (context, state) {
                  final cityName = context.read<CategoryBloc>().selectedCity;
                  return Semantics(
                    header: true,
                    focusable: true,
                    label:
                        'Explore locais em $cityName ou escolha uma nova cidade no menu superior',
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

              // Carrossel de categorias
              BlocBuilder<CategoryBloc, CategoryState>(
                buildWhen: (previous, current) {
                  // Rebuild somente quando a categoria selecionada mudar
                  if (previous is CategoryLoaded && current is CategoryLoaded) {
                    return previous.selectedIndex != current.selectedIndex;
                  }
                  return true;
                },
                builder: (context, state) {
                  final selectedIndex =
                      (state is CategoryLoaded) ? state.selectedIndex : -1;
                  final categoryNames = getCategoryNames();

                  return Focus(
                    focusNode: _categoriesFocusNode,
                    onKey: (FocusNode node, RawKeyEvent event) {
                      if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.tab) {
                        _mainContentFocusNode.requestFocus();
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Semantics(
                      header: true,
                      focusable: true,
                      label: 'Categorias',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: ScrollController(
                          initialScrollOffset: selectedIndex >= 0
                              ? (selectedIndex + 1) * categoryTagWidth
                              : 0,
                        ),
                        child: Row(
                          children: List.generate(
                            categoryNames.length,
                            (index) {
                              final isSelected = index - 1 == selectedIndex;

                              return GestureDetector(
                                onTap: () {
                                  // Categoria foi selecionada
                                  _isCategorySelected = true;

                                  // Atualiza a categoria e disparar o evento
                                  context
                                      .read<CategoryBloc>()
                                      .add(SelectCategoryEvent(index - 1));

                                  // Atualiza o FocusNode para o grid
                                  _updateFocusNode();

                                  SemanticsService.announce(
                                    '${categoryNames[index]} selecionada.',
                                    TextDirection.ltr,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: categoryTag(
                                    categoryNames[index],
                                    isSelected,
                                    screenWidth: screenWidth,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Grid de lugares
              Expanded(
                child: Focus(
                  focusNode: _mainContentFocusNode,
                  child: Semantics(
                    header: true,
                    label: 'Lugares',
                    focusable: true,
                    child: BlocBuilder<CategoryBloc, CategoryState>(
                      buildWhen: (previous, current) {
                        // Build somente quando os lugares filtrados mudarem
                        if (previous is CategoryLoaded &&
                            current is CategoryLoaded) {
                          if (previous.filteredPlaces.length !=
                              current.filteredPlaces.length) {
                            return true;
                          }

                          return previous.selectedIndex !=
                              current.selectedIndex;
                        }
                        return true;
                      },
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is CategoryLoaded) {
                          if (state.filteredPlaces.isEmpty) {
                            // Usar SemanticsService fora do build
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              SemanticsService.announce(
                                'Nenhum lugar encontrado para a categoria selecionada',
                                TextDirection.ltr,
                              );
                            });

                            return const Center(
                              child: Text(
                                'Nenhum lugar encontrado',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            );
                          }

                          return GridView.builder(
                            // Otimizar o GridView
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCrossAxisCount,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 1.2,
                            ),
                            cacheExtent: 500, // Cache de 500 pixels
                            itemCount: state.filteredPlaces.length,
                            itemBuilder: (context, index) {
                              final place = state.filteredPlaces[index];
                              bool isError = false;

                              // Memoriza o card
                              final card = placeCard(place, isDesktop,
                                  (bool widgetIsError) {
                                isError = widgetIsError;
                              });

                              return Focus(
                                // Atribuir o FocusNode apenas ao primeiro item quando necessário
                                focusNode: index == 0 ? _gridFocusNode : null,
                                child: Semantics(
                                  label: '${place.name}, lugar.',
                                  hint: isError
                                      ? 'Erro ao carregar, ${place.name} não pode ser selecionado. Por favor, contate-nos!.'
                                      : 'Toque para mais detalhes',
                                  button: !isError,
                                  child: isError
                                      ? card
                                      : GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PlacePage(place: place),
                                              ),
                                            );

                                            SemanticsService.announce(
                                              '${place.name}, lugar selecionado.',
                                              TextDirection.ltr,
                                            );
                                          },
                                          child: card,
                                        ),
                                ),
                              );
                            },
                          );
                        } else if (state is CategoryError) {
                          return Center(child: Text(state.message));
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
