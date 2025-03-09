import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/widgets/audio_player.dart';
import 'package:flutter/semantics.dart';

/// Página responsável por exibir informações de um local específico e permitir
/// ao usuário reproduzir o áudio de Informações Gerais e Audiodescrição mesmo com app minimizado.
class PlacePage extends StatefulWidget {
  final Place place; // Entidade que contém as informações do local

  const PlacePage({super.key, required this.place});

  @override
  PlacePageState createState() => PlacePageState();
}

class PlacePageState extends State<PlacePage> {
  AudioPlayerType _selectedPlayer =
      AudioPlayerType.audiodescricao; // Player inicial
  AudioPlayer? _activePlayer; // Player ativo para controle
  final FocusNode _modalFocusNode = FocusNode();

  @override
  void dispose() {
    _modalFocusNode.dispose();
    super.dispose();
  }

  // Adiciona este método para anunciar a mudança de áudio
  void _announceAudioChange(AudioPlayerType newType) {
    final String audioName = newType == AudioPlayerType.informacoesGerais
        ? 'Informações Gerais'
        : 'Audiodescrição';

    SemanticsService.announce(
        "Áudio alterado para $audioName", TextDirection.ltr);
  }

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
  Future<void> _openInMapLauncher() async {
    final availableMaps = await MapLauncher.installedMaps;

    if (!mounted) return; // Verifica se o widget está montado

    if (availableMaps.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FocusScope(
            autofocus: true,
            node: FocusScopeNode(),
            child: Builder(
              builder: (BuildContext innerContext) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _modalFocusNode.requestFocus();
                  SemanticsService.announce(
                    'Mostrando aplicativos de localização externos encontrados',
                    TextDirection.ltr,
                  );
                });

                return Container(
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(innerContext).size.height * 0.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Focus(
                            focusNode: _modalFocusNode,
                            child: Semantics(
                              label: 'Voltar',
                              hint:
                                  'Toque para fechar a janela de abrir localização externamente',
                              button: true,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(innerContext);
                                },
                                child: const Icon(Icons.close),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Título da modal
                          Expanded(
                            child: Semantics(
                              excludeSemantics: true,
                              child: const Text(
                                'Abrir localização externamente com',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Lista de aplicativos de mapas instalados
                      Expanded(
                        child: ListView.builder(
                          itemCount: availableMaps.length,
                          itemBuilder: (context, index) {
                            final map = availableMaps[index];
                            return Semantics(
                              label: 'Abrir localização com ${map.mapName}',
                              hint:
                                  'Toque para abrir a localização externamente.',
                              child: ListTile(
                                title: Text(
                                  map.mapName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                leading: SvgPicture.asset(
                                  map.icon,
                                  height: 30,
                                  width: 30,
                                ),
                                onTap: () {
                                  map.showMarker(
                                    coords: Coords(
                                      widget.place.coordinates.latitude,
                                      widget.place.coordinates.longitude,
                                    ),
                                    title: widget.place.name,
                                    description: widget.place.adress,
                                  );
                                  Navigator.pop(innerContext);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum aplicativo de mapas encontrado.'),
          ),
        );
      }
    }
  }

  /// Build da interface da página. Exibe as informações do local, controla
  /// a alternância entre os players de áudio e oferece um botão para abrir a localização no mapa.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 1024;
        bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        double padding = isDesktop ? 32.0 : 16.0;
        double imageHeight = isDesktop ? 400 : (isTablet ? 300 : 250);
        double titleFontSize = isDesktop ? 28 : (isTablet ? 30 : 28);
        double subtitleFontSize = isDesktop ? 20 : 18;
        double descriptionFontSize = isDesktop ? 18 : 16;
        double buttonPadding = isDesktop ? 18 : 16;
        double toggleTextFontSize = isDesktop ? 20 : 18;
        final double buttonFontSize = isDesktop ? 20 : 18;
        final double buttonWidth = isDesktop ? 200 : 180;

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
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: Semantics(
                        label: "Voltar",
                        hint: "Toque duas vezes para voltar à página anterior",
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
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
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: widget.place.name,
                        hint: widget.place.imageDescription,
                        child: Text(
                          widget.place.name, // Nome do local
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        widget.place.adress, // Endereço do local
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.place.description, // Descrição do local
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --------------- Início do Toggle button

                      // Toggle button para escolha entre "Audiodescrição" e "Informações Gerais"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Semantics para não deixar o foco texto "Audiodescrição"
                          Semantics(
                            excludeSemantics: true,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedPlayer =
                                    AudioPlayerType.audiodescricao;
                              }),
                              child: Text(
                                "Audiodescrição",
                                style: TextStyle(
                                  fontSize: toggleTextFontSize,
                                  fontWeight: _selectedPlayer ==
                                          AudioPlayerType.audiodescricao
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedPlayer ==
                                          AudioPlayerType.audiodescricao
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Container para o botão de alternância estilizado
                          MergeSemantics(
                            child: Semantics(
                              value:
                                  "Botão para Alternar Áudio. Áudio atualmente selecionado: ${_selectedPlayer == AudioPlayerType.informacoesGerais ? 'Informações Gerais' : 'Audiodescrição'}",
                              onTap: () {
                                setState(() {
                                  _selectedPlayer = _selectedPlayer ==
                                          AudioPlayerType.informacoesGerais
                                      ? AudioPlayerType.audiodescricao
                                      : AudioPlayerType.informacoesGerais;
                                });
                                _announceAudioChange(_selectedPlayer);
                              },
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPlayer = _selectedPlayer ==
                                            AudioPlayerType.informacoesGerais
                                        ? AudioPlayerType.audiodescricao
                                        : AudioPlayerType.informacoesGerais;
                                  });
                                  _announceAudioChange(_selectedPlayer);
                                },
                                child: Container(
                                  width: 80,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        left: _selectedPlayer ==
                                                AudioPlayerType.audiodescricao
                                            ? 4
                                            : 40,
                                        top: 2,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: _selectedPlayer ==
                                                    AudioPlayerType
                                                        .audiodescricao
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color(
                                                          0xFFFFDA59), // Seguindo WCAG
                                                      Color(0xFFFFE4AF)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : const LinearGradient(
                                                    colors: [
                                                      Color(
                                                          0xFF9C27B0), // Seguindo WCAG
                                                      Color(0xFFD05CE3),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.25),
                                                blurRadius: 6,
                                                offset: const Offset(2, 1),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _selectedPlayer ==
                                                    AudioPlayerType
                                                        .audiodescricao
                                                ? Icons.hearing
                                                : Icons.library_books,
                                            color: _selectedPlayer ==
                                                    AudioPlayerType
                                                        .audiodescricao
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Semantics para não deixar o foco no texto "Informações Gerais"
                          Semantics(
                            excludeSemantics: true,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedPlayer =
                                    AudioPlayerType.informacoesGerais;
                              }),
                              child: Text(
                                "Informações",
                                style: TextStyle(
                                  fontSize: toggleTextFontSize,
                                  fontWeight: _selectedPlayer ==
                                          AudioPlayerType.informacoesGerais
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedPlayer ==
                                          AudioPlayerType.informacoesGerais
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 22),
                        ],
                      ),

                      // --------------- Fim do botão de toggle

                      // const SizedBox(height: 24),

                      // Exibe o player de áudio correspondente ao que foi selecionado no Toggle Button
                      if (_selectedPlayer == AudioPlayerType.informacoesGerais)
                        SongPlayerWidget(
                          audioUrl: widget.place.audioPlaceInfoUrl,
                          audioTitle: 'Informações Gerais',
                          onPlayerInit: (player) {
                            _activePlayer =
                                player; // Passa o player que está ativo (lógica para termos o just_audio_background)
                          },
                          key: const Key('InformacoesGerais'), // Força rebuild
                        )
                      else
                        SongPlayerWidget(
                          audioUrl: widget.place.audioDescriptionUrl,
                          audioTitle: 'Audiodescrição',
                          onPlayerInit: (player) {
                            _activePlayer =
                                player; // Passa o player que está ativo
                          },
                          key: const Key('Audiodescricao'), // Força rebuild
                        ),

                      const SizedBox(height: 24),

                      // Botão para abrir a localização no mapa, visível apenas em dispositivos móveis
                      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                        Center(
                          child: SizedBox(
                            width: buttonWidth,
                            child: Semantics(
                              label: 'Abrir localização.',
                              excludeSemantics: true,
                              button: true,
                              child: ElevatedButton.icon(
                                onPressed: () => _openInMapLauncher(),
                                icon: const Icon(
                                  Icons.map,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Localização',
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: buttonFontSize,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                      0xFFae35c1), // Cor atualizada para #ae35c1 que segue o WCAG
                                  padding: EdgeInsets.symmetric(
                                    horizontal: buttonPadding,
                                    vertical: buttonPadding / 2,
                                  ),
                                ),
                              ),
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
      },
    );
  }
}

/// Enum para os diferentes tipos de players disponíveis.
enum AudioPlayerType {
  informacoesGerais, // Player de Informações Gerais
  audiodescricao, // Player de Audiodescrição
}
