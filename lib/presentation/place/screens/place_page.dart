import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/common/widgets/app_search_bar.dart';
import 'package:sigacidades/common/widgets/drawer_menu.dart';
import 'package:sigacidades/data/repositories/place_repository_impl.dart';

class PlacePage extends StatelessWidget {
  final Place place; // Recebe o local selecionado

  const PlacePage({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeRepository =
        PlaceRepositoryImpl(); // Repositório para a barra de pesquisa

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name), // Nome do local no app bar
      ),
      drawer: DrawerMenu(
        onCitySelected: (city) {
          // Atualiza a cidade no menu lateral
          Navigator.pop(context); // Fecha o Drawer após selecionar a cidade
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibe a imagem do local
            Image.network(
              place.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cidade: ${place.city}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Outros detalhes do local podem ser adicionados aqui futuramente
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
