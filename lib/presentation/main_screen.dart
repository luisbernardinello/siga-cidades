import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/common/widgets/app_search_bar.dart';
import 'package:sigacidades/common/widgets/nav_bar.dart';
import 'package:sigacidades/common/widgets/drawer_menu.dart';
import 'package:sigacidades/presentation/home/screens/home_page.dart';
import 'package:sigacidades/presentation/distances/screens/distances_page.dart';
import 'package:sigacidades/presentation/maps/screens/maps_page.dart';
import 'package:sigacidades/presentation/about/screens/about_page.dart';
import 'package:sigacidades/presentation/feedback/screens/feedback_page.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';

  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Controla a página atual que foi selecionada no IndexedStack (definido na seção conteúdo dinâmico)
  int _selectedIndex = 0;

  // Lista com todas as páginas que serão carregadas dinamicamente
  final List<Widget> _pages = [
    const HomePage(),
    const DistancesPage(),
    const MapsPage(),
    const AboutPage(),
    const FeedbackPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // GlobalKey para o controle do Drawer
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF2F2F2),

      // ====================================
      // Seção: Drawer Menu
      // ====================================
      drawer: DrawerMenu(
        onCitySelected: (city) {
          // Passa a função para o drawer e recebe o callback com o nome da cidade
          // Usamos aqui o Semantics por questões de acessibilidade ao selecionar a cidade do drawer
          // SemanticsService é usada em contexto global
          // A cidade será lida pelo leitor de tela sem precisar ser inserido em um contexto de algum widget específico.
          SemanticsService.announce(
            'Cidade selecionada: $city',
            TextDirection.ltr,
          );
        },
      ),

      // ====================================
      // Seção: App Search Bar
      // ====================================
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
                placeRepository: context.read(), // Repositório de locais
              ),
            ),
          ),

          // ====================================
          // Seção: Linha divisória abaixo da barra de busca
          // ====================================
          Positioned(
            top: 120, // Alinha logo abaixo da AppSearchBar
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 2,
                  color: const Color(0xFFE4E4E4),
                ),
                const SizedBox(height: 16), // Espaçamento depois da linha
              ],
            ),
          ),

          // ====================================
          // Seção: Conteúdo dinâmico
          // ====================================
          Positioned(
            top: 120, // Alinha o conteúdo após a linha divisória e o padding
            left: 0,
            right: 0,
            bottom: 0,
            // Aqui temos a IndexedStack que carrega as páginas da lista e passa o index da página selecionada
            child: IndexedStack(
              index: _selectedIndex, // Carrega a página selecionada
              children: _pages, // Carrega todas as páginas
            ),
          ),
        ],
      ),

      // ====================================
      // Seção: Barra de Navegação
      // ====================================
      bottomNavigationBar: CustomNavBar(
        currentPage: _selectedIndex,
        onSelectPage: (index) {
          setState(() {
            _selectedIndex =
                index; // Aqui recebemos o index da página e fazemos a atualização da página selecionada na NavBar pelo usuário
          });
        },
      ),
    );
  }
}
