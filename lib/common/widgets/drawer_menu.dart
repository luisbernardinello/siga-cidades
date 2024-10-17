import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final Function(String)
      onCitySelected; // função que vai ser chamada ao selecionar cidade

  const DrawerMenu({Key? key, required this.onCitySelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
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
          ListTile(
            title: const Text('Bauru'),
            onTap: () {
              onCitySelected('Bauru'); // chama função e seleciona cidade
              Navigator.pop(context); // fecha o drawer
            },
          ),
          ListTile(
            title: const Text('Botucatu'),
            onTap: () {
              onCitySelected('Botucatu');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Presidente Prudente'),
            onTap: () {
              onCitySelected('Presidente Prudente');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
