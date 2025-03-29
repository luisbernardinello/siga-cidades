import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/common/widgets/app_search_bar.dart';
import 'package:sigacidades/common/widgets/nav_bar.dart';
import 'package:sigacidades/common/widgets/desktop_nav_bar.dart';
import 'package:sigacidades/common/widgets/drawer_menu.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/screens/home_page.dart';
import 'package:sigacidades/presentation/distances/screens/distances_page.dart';
import 'package:sigacidades/presentation/maps/screens/maps_page.dart';
import 'package:sigacidades/presentation/about/screens/about_page.dart';
import 'package:sigacidades/presentation/feedback/screens/feedback_page.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';

  // Controla o foco inicial
  final bool initialFocus;

  // Indexação inicial
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialFocus = false,
    this.initialIndex = 0,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  late int _selectedIndex;
  String? selectedCity;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Key para a barra de navegação
  final GlobalKey _navBarKey = GlobalKey();

  // Map de FocusNodes para cada pagina
  final Map<int, FocusNode> _pageFocusNodes = {
    0: FocusNode(),
    1: FocusNode(),
    2: FocusNode(),
    3: FocusNode(),
    4: FocusNode(),
  };

  // FocusNode em específico para a navbar
  final FocusNode _navBarFocusNode = FocusNode();

  // FocusNode que gerencia o escopo do foco geral
  final FocusScopeNode _mainFocusScope = FocusScopeNode();

  // Controllers para PageView
  late PageController _pageController;

  // Controla o carregamento lazy
  final Map<int, bool> _pageLoaded = {
    0: true, // Home sempre carregada
    1: false,
    2: false,
    3: false,
    4: false,
  };

  late List<Widget> _pages;

  final Map<int, String> _pageTitles = {
    0: 'Explorar',
    1: 'Distâncias',
    2: 'Mapa',
    3: 'Sobre',
    4: 'Feedback'
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Inicializa o controller com a página inicial
    _pageController = PageController(initialPage: _selectedIndex);

    // Pré-carrega a página do mapa se estiver nela no inicio
    if (_selectedIndex == 2) {
      _pageLoaded[2] = true;
    }

    _initializePages();

    // Se initialFocus for true, foco vai para navbar
    if (widget.initialFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Foco depois do build completo
        _navBarFocusNode.requestFocus();

        SemanticsService.announce(
          'Menu de navegação em foco. Use as setas para navegar entre as opções.',
          TextDirection.ltr,
        );
      });
    }

    // Carrega o mapa em segundo plano depois do build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadMapPage();
    });
  }

  void _preloadMapPage() {
    if (_selectedIndex != 2 && _pageLoaded[2] != true) {
      setState(() {
        _pageLoaded[2] = true;
      });
    }
  }

  void _initializePages() {
    _pages = [
      HomePage(focusNode: _pageFocusNodes[0]),
      _pageLoaded[1] == true
          ? DistancesPage(focusNode: _pageFocusNodes[1])
          : Container(),
      _pageLoaded[2] == true
          ? MapsPage(focusNode: _pageFocusNodes[2])
          : Container(),
      _pageLoaded[3] == true
          ? AboutPage(focusNode: _pageFocusNodes[3])
          : Container(),
      _pageLoaded[4] == true
          ? FeedbackPage(focusNode: _pageFocusNodes[4])
          : Container(),
    ];
  }

  @override
  void dispose() {
    // Libera todos os FocusNodes ao dispose
    for (var node in _pageFocusNodes.values) {
      node.dispose();
    }
    _navBarFocusNode.dispose();
    _mainFocusScope.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Necessário para funcionar o AutomaticKeepAliveClientMixin

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double paddingHorizontal = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    double topPadding = isDesktop ? 0 : (isTablet ? 24.0 : 16.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF2F2F2),
      drawer: DrawerMenu(
        onCitySelected: (city) {
          setState(() {
            selectedCity = city;
            // Se a cidade for selecionada força a navegação para a home (índice 0)
            _changePage(0);
          });
          _scaffoldKey.currentState?.closeDrawer();

          SemanticsService.announce(
            'Cidade $city selecionada. Redirecionando para a página principal.',
            TextDirection.ltr,
          );

          // Atualiza o foco para a nova pagina
          Future.microtask(() {
            _mainFocusScope.requestFocus();
            _pageFocusNodes[0]?.requestFocus();
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ====== CustomDesktopNavBar (Somente Desktop) ======
            if (isDesktop)
              Focus(
                focusNode: _navBarFocusNode,
                child: CustomDesktopNavBar(
                  key: _navBarKey,
                  currentPage: _selectedIndex,
                  onSelectPage: _changePage,
                  onMenuTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  selectedCity: selectedCity,
                ),
              ),

            // ====== AppSearchBar (Apenas Mobile & Tablet) ======
            if (!isDesktop)
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: paddingHorizontal,
                  right: paddingHorizontal,
                ),
                child: AppSearchBar(
                  onMenuTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  placeRepository: context.read<PlaceRepository>(),
                  selectedCity: selectedCity,
                  onCloseModal: () {
                    //
                  },
                ),
              ),

            // ====== Conteúdo principal utiliza do PageView para manter o estado ======
            Expanded(
              child: FocusScope(
                node: _mainFocusScope,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // Evita que o PageView carregue todas páginas
                    if (notification is ScrollEndNotification) {
                      final page = _pageController.page?.round() ?? 0;
                      if (page != _selectedIndex) {
                        _changePage(page);
                      }
                    }
                    return false;
                  },
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                        _loadPageAtIndex(index);
                      });
                    },
                    children: List.generate(_pages.length, (index) {
                      return Semantics(
                        label: 'Página ${_pageTitles[index]}',
                        child: KeepAliveWrapper(
                          keepAlive: index ==
                              2, // Keep Alive usado de modo a manter a página do mapa viva
                          child: _pageLoaded[index] == true
                              ? _pages[index]
                              : Container(
                                  color: const Color(0xFFF2F2F2),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : Focus(
              focusNode: _navBarFocusNode,
              child: CustomNavBar(
                key: _navBarKey,
                currentPage: _selectedIndex,
                onSelectPage: _changePage,
              ),
            ),
    );
  }

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;

      _loadPageAtIndex(index);
    });

    _pageController.jumpToPage(index);

    // Animação teste de pagina
    // _pageController.animateToPage(
    //   index,
    //   duration: const Duration(milliseconds: 250),
    //   curve: Curves.easeInOut,
    // );

    SemanticsService.announce(
      'Página ${_pageTitles[index]} selecionada.',
      TextDirection.ltr,
    );

    // Envia o foco para o conteúdo principal da página selecionada
    Future.microtask(() {
      _mainFocusScope.requestFocus();
      _pageFocusNodes[index]?.requestFocus();
    });
  }

  void _loadPageAtIndex(int index) {
    if (_pageLoaded[index] != true) {
      setState(() {
        _pageLoaded[index] = true;
        _initializePages();
      });
    }
  }

  @override
  bool get wantKeepAlive => true; // Implementa o AutomaticKeepAliveClientMixin
}

// Widget criado a fim de manter o estado da página
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  final bool keepAlive;

  const KeepAliveWrapper({
    super.key,
    required this.child,
    this.keepAlive = true,
  });

  @override
  // ignore: library_private_types_in_public_api
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
