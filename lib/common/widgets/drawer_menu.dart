import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';

class DrawerMenu extends StatelessWidget {
  final Function(String) onCitySelected;

  const DrawerMenu({
    super.key,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    // busca a cidade atual diretamente do bloc
    final currentCity = context.read<CategoryBloc>().selectedCity;

    return Drawer(
      child: Semantics(
        focusable: true,
        child: Container(
          padding: EdgeInsets.only(
            top: isTablet ? 120 : 100,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                focusable: true,
                child: Text(
                  'SIGA CIDADES',
                  style: TextStyle(
                    color: const Color(0xFF080808),
                    fontSize: isTablet ? 28 : 24,
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Semantics(
                label: 'Selecione a cidade para explorar',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCityOption(
                        context, 'Bauru', isTablet, currentCity == 'Bauru'),
                    const SizedBox(height: 24),
                    _buildCityOption(
                        context, 'Marília', isTablet, currentCity == 'Marília'),
                    const SizedBox(height: 24),
                    _buildCityOption(context, 'Botucatu', isTablet,
                        currentCity == 'Botucatu'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityOption(
      BuildContext context, String cityName, bool isTablet, bool isSelected) {
    return Semantics(
      label:
          'Cidade $cityName. ${isSelected ? 'Selecionada' : 'Toque para selecionar'}',
      button: true,
      child: GestureDetector(
        onTap: () {
          // usa uma cópia do valor para evitar problema de referência
          final selectedCityName = cityName;

          // atualiza o BLoC primeiro
          final bloc = context.read<CategoryBloc>();
          bloc.add(SelectCityEvent(selectedCityName));

          // chama o callback que notifica o MainScreen
          // que por sua vez vai redirecionar para a HomePage
          onCitySelected(selectedCityName);
        },
        child: Text(
          cityName,
          style: TextStyle(
            color: const Color(0xFF131313),
            fontSize: isTablet ? 20 : 18,
            fontFamily: 'Sora',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
