import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:map_launcher/map_launcher.dart'; // Import map_launcher
import 'package:flutter_svg/flutter_svg.dart'; // Para usar ícones SVG do map_launcher

class PlacePage extends StatelessWidget {
  final Place place; // Instância do lugar que representa o lugar clicado

  const PlacePage({Key? key, required this.place}) : super(key: key);

  // Função para abrir o Map Launcher com os mapas disponíveis no dispositivo
  Future<void> _openInMapLauncher(BuildContext context) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                children: availableMaps.map((map) {
                  return ListTile(
                    onTap: () {
                      map.showMarker(
                        coords: Coords(
                          place.coordinates.latitude,
                          place.coordinates.longitude,
                        ),
                        title: place.name,
                        description: place.adress,
                      );
                      Navigator.pop(context);
                    },
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon, // Ícone do app de mapas
                      height: 30, // Tamanho do ícone
                      width: 30,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } else {
      // Se nenhum app de mapas for encontrado, exibe uma mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum aplicativo de mapas encontrado.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Exibe a imagem do local
                Image.network(
                  place.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                // Contém a lógica e o ícone de voltar para a página anterior
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Retorna para a página anterior
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
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
                  // Exibe o endereço do local
                  Text(
                    'Endereço: ${place.adress}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Exibe a descrição do local
                  Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botão para abrir no maps
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openInMapLauncher(context),
                      icon: const Icon(Icons.map),
                      label: const Text('Abrir no Maps'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
