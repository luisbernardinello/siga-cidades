import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';

// ====================================
// DrawerMenu: Menu lateral de seleção de cidade
// ====================================
// O DrawerMenu permite ao usuário selecionar uma cidade da lista.
// Quando uma cidade é selecionada, a aplicação vai filtrar os dados
// com base na cidade escolhida.
// O CategoryBloc armazena a cidade selecionada.
class DrawerMenu extends StatelessWidget {
  final Function(String)
      onCitySelected; // Callback que recebe a cidade selecionada.

  const DrawerMenu({
    super.key,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // ====================================
      // Container que define o layout do Drawer
      // ====================================
      child: Container(
        padding: const EdgeInsets.only(
          top: 100, // Espaço para o título.
          left: 16,
          right: 16,
          bottom: 24,
        ),
        decoration:
            const BoxDecoration(color: Colors.white), // Cor de fundo do Drawer.
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinha o conteúdo na esquerda.
          children: [
            // ====================================
            // Título do Drawer
            // ====================================
            const Text(
              'SIGA CIDADES',
              style: TextStyle(
                color: Color(0xFF080808),
                fontSize: 24,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 40), // Espaço entre o titulo e as cidades.

            // ====================================
            // Opções de cidades
            // ====================================
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                // Exibe as cidades como opções no Drawer.
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

  // ====================================
  // _buildCityOption: Opção de cidade no Drawer.
  // (Não usamos Semantic aqui, o callback envia a cidade para a main screen que globalmente notifica o usuário sonoramente)
  // ====================================
  // Cada cidade ao ser clicada envia um evento para o CategoryBloc e atualiza o estado da cidade selecionada.
  Widget _buildCityOption(BuildContext context, String cityName) {
    return GestureDetector(
      onTap: () {
        // Envia o evento para atualizar a cidade selecionada no CategoryBloc.
        context.read<CategoryBloc>().add(SelectCityEvent(cityName));
        onCitySelected(
            cityName); // Notifica o widget pai sobre a cidade selecionada.
        Navigator.pop(context); // Fecha o Drawer depois da seleção.
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
