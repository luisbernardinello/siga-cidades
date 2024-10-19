import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';

class DrawerMenu extends StatelessWidget {
  final Function(String) onCitySelected;

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
              context.read<CategoryBloc>().add(SelectCityEvent('Bauru'));
              Navigator.pop(context); // Fecha o Drawer
            },
          ),
          ListTile(
            title: const Text('Botucatu'),
            onTap: () {
              context.read<CategoryBloc>().add(SelectCityEvent('Botucatu'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Presidente Prudente'),
            onTap: () {
              context
                  .read<CategoryBloc>()
                  .add(SelectCityEvent('Presidente Prudente'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
