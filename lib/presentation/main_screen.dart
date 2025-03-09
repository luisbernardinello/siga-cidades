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

  // Adicionamos este parâmetro para controlar o foco inicial
  final bool initialFocus;

  const MainScreen({super.key, this.initialFocus = false});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
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

  // FocusNode específico para a navbar
  final FocusNode _navBarFocusNode = FocusNode();

  // FocusNode gerencia o escopo do foco geral
  final FocusScopeNode _mainFocusScope = FocusScopeNode();

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
    _initializePages();

    // Se initialFocus for true, programamos para focar na navbar
    if (widget.initialFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Foco na navbar depois do build estar completo
        _navBarFocusNode.requestFocus();

        SemanticsService.announce(
          'Menu de navegação em foco. Use as setas para navegar entre as opções.',
          TextDirection.ltr,
        );
      });
    }
  }

  void _initializePages() {
    _pages = [
      HomePage(focusNode: _pageFocusNodes[0]),
      DistancesPage(focusNode: _pageFocusNodes[1]),
      MapsPage(focusNode: _pageFocusNodes[2]),
      AboutPage(focusNode: _pageFocusNodes[3]),
      FeedbackPage(focusNode: _pageFocusNodes[4]),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _selectedIndex = 0;
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

            // ====== Conteúdo principal  ======
            Expanded(
              child: FocusScope(
                node: _mainFocusScope,
                child: Semantics(
                  label: 'Página ${_pageTitles[_selectedIndex]}',
                  child: _pages[_selectedIndex],
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
    });

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
}
