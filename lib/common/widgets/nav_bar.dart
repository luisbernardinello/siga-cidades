import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomNavBar extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onSelectPage;

  const CustomNavBar({
    super.key,
    required this.currentPage,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final double navHeight = screenHeight > 800
        ? (screenWidth >= 600 ? 95 : 85)
        : (screenWidth >= 600 ? 85 : 75);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFFF2F2F2),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: navHeight,
          margin: EdgeInsets.only(
              bottom: bottomPadding > 0 ? bottomPadding / 2 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE4E4E4),
              width: 1.5,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 600;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(context, Icons.home, 0, isTablet, 'Início'),
                  _buildNavItem(context, Icons.list, 1, isTablet, 'Distâncias'),
                  _buildCenterItem(context, 2, isTablet),
                  _buildNavItem(context, Icons.info, 3, isTablet, 'Sobre'),
                  _buildNavItem(
                      context, Icons.message, 4, isTablet, 'Feedback'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index,
      bool isTablet, String label) {
    return Expanded(
      child: Center(
        child: MergeSemantics(
          child: Semantics(
            label: label,
            hint:
                'Botão do menu, no momento ${currentPage == index ? "selecionado" : "não selecionado"}',
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              highlightColor: Colors.purple.withOpacity(0.1),
              splashColor: Colors.purple.withOpacity(0.2),
              onTap: () => onSelectPage(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isTablet ? 44 : 40,
                      height: isTablet ? 44 : 40,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? Colors.purple
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: currentPage == index
                            ? [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: isTablet ? 32 : 28,
                          color: currentPage == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 5,
                      height: 5,
                      decoration: ShapeDecoration(
                        color: currentPage == index
                            ? const Color(0xFFEFDF58)
                            : const Color(0xFFA2A2A2),
                        shape: const OvalBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem(BuildContext context, int index, bool isTablet) {
    return Expanded(
      child: Center(
        child: MergeSemantics(
          child: Semantics(
            label: 'Mapa interativo',
            hint:
                'Botão central do menu, no momento ${currentPage == index ? "selecionado" : "não selecionado"}',
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              highlightColor: Colors.purple.withOpacity(0.1),
              splashColor: Colors.purple.withOpacity(0.2),
              onTap: () => onSelectPage(index),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isTablet ? 68 : 58,
                  height: isTablet ? 68 : 58,
                  decoration: ShapeDecoration(
                    color: currentPage == index
                        ? Colors.purple
                        : const Color(0xFFC6C6C6),
                    shape: const CircleBorder(),
                    shadows: currentPage == index
                        ? [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_outlined,
                      size: isTablet ? 44 : 38,
                      color: currentPage == index ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
