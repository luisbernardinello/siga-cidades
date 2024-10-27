import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/common/widgets/app_search_bar.dart';

class CustomDesktopNavBar extends StatelessWidget {
  final int currentPage; // Página selecionada.
  final ValueChanged<int> onSelectPage; // Callback para trocar a página.
  final VoidCallback onMenuTap; // Callback para abrir o Drawer.
  final String? selectedCity; // Cidade selecionada para busca.

  const CustomDesktopNavBar({
    Key? key,
    required this.currentPage,
    required this.onSelectPage,
    required this.onMenuTap,
    required this.selectedCity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // Cor de fundo da barra.
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ícone de menu para abrir o Drawer (mantido à esquerda).
          GestureDetector(
            onTap: onMenuTap,
            child: const Icon(Icons.menu, color: Color(0xFF080808)),
          ),

          // Navegação principal no centro da barra.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavItem(context, 'Início', Icons.home, 0),
              _buildNavItem(context, 'Distâncias', Icons.list, 1),
              _buildNavItem(context, 'Mapa', Icons.map, 2),
              _buildNavItem(context, 'Sobre', Icons.info, 3),
              _buildNavItem(context, 'Feedback', Icons.message, 4),
            ],
          ),

          // Barra de busca alinhada à direita.
          SizedBox(
            width: 300,
            child: AppSearchBar(
              onMenuTap: onMenuTap, // Função que não será usada aqui.
              placeRepository: context.read(), // Repositório de locais
              selectedCity: selectedCity, // Cidade selecionada
            ),
          ),
        ],
      ),
    );
  }

  // ====================================
  // _buildNavItem: Constrói os ícones e textos da barra de navegação desktop.
  // ====================================
  // Constrói o item de navegação com ícone e texto, com cor de destaque
  // para o item selecionado.
  Widget _buildNavItem(
      BuildContext context, String label, IconData icon, int index) {
    final bool isSelected = currentPage == index;

    return GestureDetector(
      onTap: () => onSelectPage(index), // Troca a página ao clicar.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.purple : Colors.black,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.purple : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: Colors.purple,
            ),
        ],
      ),
    );
  }
}
