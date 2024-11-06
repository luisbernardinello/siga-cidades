import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/common/widgets/app_search_bar.dart';
import 'package:sigacidades/common/widgets/nav_bar.dart';
import 'package:sigacidades/common/widgets/desktop_nav_bar.dart';
import 'package:sigacidades/common/widgets/drawer_menu.dart';
import 'package:sigacidades/presentation/home/screens/home_page.dart';
import 'package:sigacidades/presentation/distances/screens/distances_page.dart';
import 'package:sigacidades/presentation/maps/screens/maps_page.dart';
import 'package:sigacidades/presentation/about/screens/about_page.dart';
import 'package:sigacidades/presentation/feedback/screens/feedback_page.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';

  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? selectedCity;
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _navBarFocusNode = FocusNode();

  final List<Widget> _pages = [
    const HomePage(),
    const DistancesPage(),
    const MapsPage(),
    const AboutPage(),
    const FeedbackPage(),
  ];

  final Map<int, String> _pageTitles = {
    0: 'Explorar',
    1: 'Distâncias',
    2: 'Mapa',
    3: 'Sobre',
    4: 'Feedback'
  };

  @override
  void dispose() {
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double paddingHorizontal = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    double topPadding = isDesktop ? -60 : (isTablet ? 56 : 47);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF2F2F2),
      drawer: DrawerMenu(
        onCitySelected: (city) {
          setState(() {
            selectedCity = city;
          });
          SemanticsService.announce(
            'Cidade selecionada: $city',
            TextDirection.ltr,
          );
        },
      ),

      // ====================================
      // Seção: CustomDesktopNavBar com Barra de Busca para Desktop
      // ====================================
      body: Column(
        children: [
          if (isDesktop)
            Semantics(
              label: 'Barra de navegação principal',
              focusable: true,
              child: Focus(
                focusNode: _navBarFocusNode,
                child: CustomDesktopNavBar(
                  currentPage: _selectedIndex,
                  onSelectPage: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _contentFocusNode.requestFocus();
                    });
                    SemanticsService.announce(
                      'Página ${_pageTitles[index]} selecionada.',
                      TextDirection.ltr,
                    );
                  },
                  onMenuTap: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                  selectedCity: selectedCity,
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                // ====================================
                // Seção: App Search Bar para Tablet e Mobile
                // ====================================
                if (!isDesktop)
                  Positioned(
                    top: topPadding,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: paddingHorizontal),
                      child: AppSearchBar(
                        onMenuTap: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                        placeRepository: context.read(),
                        selectedCity: selectedCity,
                      ),
                    ),
                  ),

                // Seção de conteúdo dinâmico
                Positioned(
                  top: topPadding + 65,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Semantics(
                    label: 'Conteúdo da página ${_pageTitles[_selectedIndex]}',
                    focusable: true,
                    child: Focus(
                      focusNode: _contentFocusNode,
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _pages,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ====================================
      // Seção: Barra de Navegação Inferior (CustomNavBar) em Dispositivos Móveis e Tablet
      // ====================================
      bottomNavigationBar: isDesktop
          ? null
          : Semantics(
              label: 'Barra de navegação principal',
              focusable: true,
              // focused: true,
              child: Focus(
                focusNode: _navBarFocusNode,
                autofocus: true,
                child: CustomNavBar(
                  currentPage: _selectedIndex,
                  onSelectPage: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _contentFocusNode.requestFocus();
                    });
                    SemanticsService.announce(
                      'Página ${_pageTitles[index]} selecionada.',
                      TextDirection.ltr,
                    );
                  },
                ),
              ),
            ),
    );
  }
}
