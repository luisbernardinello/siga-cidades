import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

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

            // Se o áudio terminar (estado "completed"), reseta para o início e volta o ícone para "play"
            if (processingState == ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons
                    .replay), // Ícone de "replay" para indicar que terminou
                iconSize: 54.0,
                onPressed: () {
                  player.seek(Duration.zero); // Volta para o início
                  player.play(); // Coloca player em reprodução
                },
                tooltip: 'Reiniciar áudio',
              );
            }

            // Se estiver carregando ou em buffering
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

            // Se o áudio estiver pausado, exibe o botão de Play
            if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 54.0,
                onPressed: player.play,
                tooltip: 'Reproduzir', // Tooltip para acessibilidade
              );
            }

            // Se o áudio estiver tocando, exibe o botão de Pause
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 54.0,
              onPressed: player.pause,
              tooltip: 'Pausar', // Tooltip para acessibilidade
            );
          },
        ),

        // Velocidade de reprodução com acessibilidade
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) {
            final speed = snapshot.data ?? 1.0;
            return IconButton(
              icon: Text(
                "${speed.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _changePlaybackSpeed(context, player, speed);
              },
              tooltip:
                  'Velocidade de reprodução ${speed.toStringAsFixed(1)}x', // Tooltip para acessibilidade
            );
          },
        ),
      ],
    );
  }

  // Função para alterar a velocidade sem exibir um modal
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
      newSpeed = 0.5;
    } else {
      newSpeed = 1.0; // Retorna para a velocidade normal
    }

    player.setSpeed(newSpeed);

    // Fornece feedback sonoro ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Velocidade de reprodução: ${newSpeed.toStringAsFixed(1)}x')),
    );
  }
}
