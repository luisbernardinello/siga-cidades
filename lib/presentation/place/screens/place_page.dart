import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/widgets/audio_player.dart';

/// Página responsável por exibir informações de um local específico e permitir
/// ao usuário alternar entre dois players de áudio: "Informações Gerais" e "Audiodescrição".
class PlacePage extends StatefulWidget {
  final Place place; // Entidade que contém as informações do local

  const PlacePage({Key? key, required this.place}) : super(key: key);

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  AudioPlayerType _selectedPlayer =
      AudioPlayerType.informacoesGerais; // Player inicial
  AudioPlayer? _activePlayer; // Player ativo para controle

  /// Função responsável por alternar entre os dois players de áudio, garantindo
  /// que o player anterior seja pausado e liberado antes de inicializar o novo.
  void _onAudioChanged(bool isGeneralInfo) {
    setState(() {
      // Alterna entre "Informações Gerais" e "Audiodescrição"
      _selectedPlayer = isGeneralInfo
          ? AudioPlayerType.informacoesGerais
          : AudioPlayerType.audiodescricao;

      // Pausar e liberar o player anterior
      if (_activePlayer != null) {
        _activePlayer!.stop(); // Pausa o áudio atual
        _activePlayer!.dispose(); // Libera o recurso do player
        _activePlayer = null; // Reseta o player ativo
      }
    });
  }

  /// Função que permite ao usuário abrir a localização no aplicativo de mapas de sua escolha.
  /// O MapLauncher lista os aplicativos de mapa disponíveis no dispositivo.
  Future<void> _openInMapLauncher(BuildContext context) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                // Lista todos os aplicativos de mapas instalados no dispositivo
                children: availableMaps.map((map) {
                  return ListTile(
                    onTap: () {
                      // Abre o marcador no app de mapa escolhido
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
                      map.icon, // Ícone do app de mapa
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
      // Exibe mensagem se nenhum aplicativo de mapas for encontrado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum aplicativo de mapas encontrado.'),
        ),
      );
    }
  }

  /// Build da interface da página. Exibe as informações do local, controla
  /// a alternância entre os players de áudio e oferece um botão para abrir a localização no mapa.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibe a imagem do local com um botão para voltar
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
                      Navigator.pop(context); // Botão para voltar
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
                    widget.place.name, // Nome do local
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.place.adress, // Endereço do local
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.place.description, // Descrição do local
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Alternador para escolher entre "Informações Gerais" e "Audiodescrição"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Informações Gerais"),
                      Switch(
                        value:
                            _selectedPlayer == AudioPlayerType.audiodescricao,
                        onChanged: (value) {
                          _onAudioChanged(!value); // Alterna entre os players
                        },
                      ),
                      const Text("Audiodescrição"),
                    ],
                  ),

                  // Exibe o player de áudio correspondente à seleção
                  if (_selectedPlayer == AudioPlayerType.informacoesGerais)
                    SongPlayerWidget(
                      audioUrl: widget.place.linkHist,
                      audioTitle: 'Informações Gerais',
                      onPlayerInit: (player) {
                        _activePlayer = player; // Registra o player ativo
                      },
                      key: const Key('InformacoesGerais'), // Força rebuild
                    )
                  else
                    SongPlayerWidget(
                      audioUrl: widget.place.linkAD,
                      audioTitle: 'Audiodescrição',
                      onPlayerInit: (player) {
                        _activePlayer = player; // Registra o player ativo
                      },
                      key: const Key('Audiodescricao'), // Força rebuild
                    ),

                  const SizedBox(height: 24),

                  // Botão para abrir a localização no mapa
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

/// Enum para definir os diferentes tipos de players disponíveis.
enum AudioPlayerType {
  informacoesGerais, // Player de Informações Gerais
  audiodescricao, // Player de Audiodescrição
}
