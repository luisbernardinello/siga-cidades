import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigacidades/core/debouncer.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;
  final String audioUrl;
  final Debouncer _snackbarDebouncer = Debouncer(
      milliseconds:
          500); // Debouncer para trabalhar com as mensagens atrasadas que podem ser geradas pelo botão de velocidade

  ControlButtons(this.player, {required this.audioUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão de Play/Pause
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 54.0,
                onPressed: () async {
                  player.seek(Duration.zero);
                  await _playAudio();
                },
                tooltip: 'Reiniciar áudio',
              );
            }

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Semantics(
                label: 'Carregando áudio',
                child: Container(
                  width: 54.0,
                  height: 54.0,
                  margin: const EdgeInsets.all(8.0),
                  child: const CircularProgressIndicator(),
                ),
              );
            }

            if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 54.0,
                onPressed: () async {
                  await _playAudio();
                },
                tooltip: 'Reproduzir',
              );
            }

            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 54.0,
              onPressed: () async {
                await _pauseAudio();
              },
              tooltip: 'Pausar',
            );
          },
        ),

        // Botão para alterar a velocidade
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) {
            final speed = snapshot.data ?? 1.0;
            return Semantics(
              value:
                  "Botão Velocidade de Reprodução. Velocidade Atual: ${speed.toStringAsFixed(1)}",
              hint: "Toque para alterar",
              excludeSemantics: true,
              child: IconButton(
                icon: Text(
                  "${speed.toStringAsFixed(1)}x",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                iconSize: 24.0,
                onPressed: () {
                  _changePlaybackSpeed(context, player, speed);
                },
              ),
            );
          },
        ),

        // Botão para fazer download
        Semantics(
          label: 'Botão para download do áudio selecionado.',
          child: IconButton(
            icon: const Icon(Icons.download),
            iconSize: 25.0,
            onPressed: () {
              SemanticsService.announce(
                'Download selecionado, baixando o arquivo.',
                TextDirection.ltr,
              );
              _downloadAudio(context, audioUrl);
            },
            tooltip: 'Download do áudio atual',
          ),
        ),
      ],
    );
  }

  Future<void> _playAudio() async {
    final session = await AudioSession.instance;
    await session.setActive(true);
    await player.play();
  }

  Future<void> _pauseAudio() async {
    await player.pause();
    final session = await AudioSession.instance;
    await session.setActive(false);
  }

  // Função para alterar a velocidade do áudio
  void _changePlaybackSpeed(
      BuildContext context, AudioPlayer player, double currentSpeed) {
    double newSpeed;
    if (currentSpeed == 1.0) {
      newSpeed = 1.5;
    } else if (currentSpeed == 1.5) {
      newSpeed = 2.0;
    } else if (currentSpeed == 2.0) {
      newSpeed = 2.5;
    } else if (currentSpeed == 2.5) {
      newSpeed = 3.0;
    } else {
      newSpeed = 1.0;
    }

    player.setSpeed(newSpeed);

    // Exibe a notificação no SnackBar com debounce
    _snackbarDebouncer.run(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            label: 'Velocidade ${newSpeed.toStringAsFixed(1)}',
            excludeSemantics: true,
            child: Text('Velocidade ${newSpeed.toStringAsFixed(1)}x'),
          ),
        ),
      );
    });
  }

  // Função para baixar o áudio
  Future<void> _downloadAudio(BuildContext context, String url) async {
    final Dio dio = Dio();
    if (await _requestStoragePermission()) {
      final downloadsDir = await getExternalStorageDirectory();
      final fileName = url.split('/').last;
      final filePath = '${downloadsDir?.path}/$fileName';

      try {
        await dio.download(url, filePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Áudio baixado com sucesso.")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao baixar o áudio.")),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Permissão de armazenamento necessária.")),
        );
      }
    }
  }

  /// Solicita a permissão de armazenamento
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Solicita permissões específicas conforme a API do Android
      if (await Permission.audio.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      }
      return false;
    }
    // iOS não precisa de permissão para downloads de audio
    return true;
  }
}
