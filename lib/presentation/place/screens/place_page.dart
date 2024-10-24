import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/widgets/audio_player.dart';

class PlacePage extends StatelessWidget {
  final Place place;

  const PlacePage({Key? key, required this.place}) : super(key: key);

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
                      map.icon,
                      height: 30,
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
                Image.network(
                  place.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
                    place.adress,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Player de áudio
                  SongPlayerWidget(
                      audioUrl: place.linkHist,
                      audioTitle: 'Informações Gerais'),

                  const SizedBox(height: 14),

                  SongPlayerWidget(
                      audioUrl: place.linkAD, audioTitle: 'Audiodescrição'),

                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openInMapLauncher(context),
                      icon: const Icon(Icons.map),
                      label: const Text('Abrir localização'),
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
