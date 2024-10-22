import 'package:flutter/material.dart';

// ====================================
// CustomNavBar: Barra de navegação personalizada
// ====================================
// Esta barra de navegação é usada para permitir a troca entre diferentes
// páginas da aplicação. Cada item da navbar está associado a uma página,
// e a página selecionada é destacada visualmente.
// O onSelectPage é usado para enviar o índice da página selecionada para o
// widget pai, que controla qual página deve ser exibida.
class CustomNavBar extends StatelessWidget {
  final int currentPage; // Página selecionada.
  final ValueChanged<int> onSelectPage; // Callback para trocar a pagina.

  const CustomNavBar({
    super.key,
    required this.currentPage,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 78,
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32, bottom: 8),
      decoration: const ShapeDecoration(
        color: Color(0xFFF2F2F2), // Cor de fundo da barra.
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFE4E4E4)), // Borda.
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícones da barra de navegação, com base no índice de cada página.
          _buildNavItem(context, Icons.home, 0), // Página inicial.
          _buildNavItem(context, Icons.list, 1), // Distâncias.
          _buildCenterItem(context, 2), // Mapa, ícone central destacado.
          _buildNavItem(context, Icons.info, 3), // Sobre.
          _buildNavItem(context, Icons.message, 4), // Feedback.
        ],
      ),
    );
  }

  // ====================================
  // _buildNavItem: Constrói os ícones regulares da navbar.
  // ====================================
  // Este método constrói um ícone que ao ser selcionado troca para a
  // página correspondente. A cor e o destaque visual são aplicados com base
  // no estado da página atual (currentPage).
  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    return GestureDetector(
      onTap: () => onSelectPage(index), // Troca a página quando clicado.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Círculo que destaca o ícone selecionado.
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: currentPage == index
                  ? Colors.purple
                  : Colors.transparent, // Cor de destaque.
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: currentPage == index
                  ? Colors.white
                  : Colors.black, // Ícone em branco se selecionado.
            ),
          ),
          const SizedBox(height: 4),
          // Ponto amarelo abaixo do ícone selecionado.
          Container(
            width: 4,
            height: 4,
            decoration: ShapeDecoration(
              color: currentPage == index
                  ? const Color(0xFFEFDF58) // Se for selecionado, cor amarela.
                  : const Color(0xFFA2A2A2), // Cinza se não selecionado.
              shape: const OvalBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================
  // _buildCenterItem: Constrói o ícone central da navbar.
  // ====================================
  // O ícone central é maior e fica destacado no meio da navbar, representando
  // a página de mapas.

  Widget _buildCenterItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => onSelectPage(index), // Troca a página quando clicado.
      child: Container(
        width: 60,
        height: 60,
        decoration: ShapeDecoration(
          color: currentPage == index
              ? Colors.purple
              : const Color(0xFFC6C6C6), // Destaque do selecionado.
          shape: const CircleBorder(),
        ),
        child: Icon(
          Icons.location_on_outlined,
          size: 40,
          color: currentPage == index
              ? Colors.white
              : Colors.black, // Ícone branco se selecionado.
        ),
      ),
    );
  }
}
