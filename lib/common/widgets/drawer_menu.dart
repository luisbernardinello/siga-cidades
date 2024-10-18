import 'package:flutter/material.dart';

// Widget que representa o menu lateral (Drawer) colapsado.
// Somente envia uma função para a camada de apresentação quando uma cidade é selecionada.
class DrawerMenu extends StatelessWidget {
  // Função de callback que será chamada ao selecionar uma cidade.
  // envia a seleção da cidade para o widget pai (BLoC).
  final Function(String) onCitySelected;

  const DrawerMenu({Key? key, required this.onCitySelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // ====================================
          // Seção: Cabeçalho do Drawer
          // ====================================
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Selecionar Cidade',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // ====================================
          // Seção: Lista de cidades
          // ====================================
          // Cada ListTile é uma cidade.
          ListTile(
            title: const Text('Bauru'),
            onTap: () {
              onCitySelected(
                  'Bauru'); // Dispara o callback com a cidade selecionada.
              Navigator.pop(context); // Fecha o Drawer ao selecionar a cidade.
            },
          ),
          ListTile(
            title: const Text('Botucatu'),
            onTap: () {
              onCitySelected('Botucatu'); // Seleciona 'Botucatu'.
              Navigator.pop(context); // Fecha o Drawer.
            },
          ),
          ListTile(
            title: const Text('Presidente Prudente'),
            onTap: () {
              onCitySelected(
                  'Presidente Prudente'); // Seleciona 'Presidente Prudente'.
              Navigator.pop(context); // Fecha o Drawer.
            },
          ),
        ],
      ),
    );
  }
}
