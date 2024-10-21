import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';

class DrawerMenu extends StatelessWidget {
  final Function(String) onCitySelected;

  const DrawerMenu({
    Key? key,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: const EdgeInsets.only(
          top: 100,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título "SIGA CIDADES"
            const Text(
              'SIGA CIDADES',
              style: TextStyle(
                color: Color(0xFF080808),
                fontSize: 24,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 40), // Espaço maior antes das cidades

            // Seção de cidades
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                // Cidades que podem ser selecionadas
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCityOption(context, 'Bauru'),
                    const SizedBox(height: 24),
                    _buildCityOption(context, 'Botucatu'),
                    const SizedBox(height: 24),
                    _buildCityOption(context, 'Presidente Prudente'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Método para cada opção de cidade no Drawer
  Widget _buildCityOption(BuildContext context, String cityName) {
    return GestureDetector(
      onTap: () {
        // lógica do Bloc para selecionar a cidade
        context.read<CategoryBloc>().add(SelectCityEvent(cityName));
        onCitySelected(cityName); // Chama a função de callback
        Navigator.pop(context); // Fecha o Drawer ao selecionar a cidade
      },
      child: Text(
        cityName,
        style: const TextStyle(
          color: Color(0xFF131313),
          fontSize: 18,
          fontFamily: 'Sora',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
