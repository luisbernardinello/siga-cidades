import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/widgets/audio_player_2.dart';

class PlacePage extends StatefulWidget {
  final Place place;

  const PlacePage({Key? key, required this.place}) : super(key: key);

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  AudioPlayerType _selectedPlayer = AudioPlayerType.informacoesGerais;
  AudioPlayer? _activePlayer; // Referência ao player ativo para controle

  // ====================================
  // Função para alternar o player
  // ====================================
  void _onAudioChanged(bool isGeneralInfo) {
    setState(() {
      _selectedPlayer = isGeneralInfo
          ? AudioPlayerType.informacoesGerais
          : AudioPlayerType.audiodescricao;

      // Pausar e liberar o player anterior
      if (_activePlayer != null) {
        _activePlayer!.stop(); // Pausa o player
        _activePlayer!.dispose(); // Libera o player
        _activePlayer = null; // Reseta o player ativo
      }
    });
  }

  // ====================================
  // Função para abrir o mapa
  // ====================================
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
                          widget.place.coordinates.latitude,
                          widget.place.coordinates.longitude,
                        ),
                        title: widget.place.name,
                        description: widget.place.adress,
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

  // ====================================
  // Build da interface
  // ====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================================
            // Imagem do local e botão de voltar
            // ====================================
            Stack(
              children: [
                Image.network(
                  widget.place.imageUrl,
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
                    widget.place.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.place.adress,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.place.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ====================================
                  // Alternador para escolher o player
                  // ====================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Informações Gerais"),
                      Switch(
                        value:
                            _selectedPlayer == AudioPlayerType.audiodescricao,
                        onChanged: (value) {
                          _onAudioChanged(!value);
                        },
                      ),
                      const Text("Audiodescrição"),
                    ],
                  ),

                  // ====================================
                  // Player de áudio correspondente
                  // ====================================
                  if (_selectedPlayer == AudioPlayerType.informacoesGerais)
                    SongPlayerWidget(
                      audioUrl: widget.place.linkHist,
                      audioTitle: 'Informações Gerais',
                      onPlayerInit: (player) {
                        _activePlayer = player;
                      },
                      key: const Key('InformacoesGerais'), // Força rebuild
                    )
                  else
                    SongPlayerWidget(
                      audioUrl: widget.place.linkAD,
                      audioTitle: 'Audiodescrição',
                      onPlayerInit: (player) {
                        _activePlayer = player;
                      },
                      key: const Key('Audiodescricao'), // Força rebuild
                    ),

                  const SizedBox(height: 24),

                  // ====================================
                  // Botão de Mapa
                  // ====================================
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

// ====================================
// Enum para definir os diferentes tipos de players
// ====================================
enum AudioPlayerType {
  informacoesGerais,
  audiodescricao,
}
