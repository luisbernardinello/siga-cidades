import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

/// Classe responsável pelos botões de controle de reprodução de áudio.
/// Possui funcionalidades de Play/Pause e ajuste de velocidade de reprodução.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ====================================
        // Botão de Play/Pause
        // ====================================
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            // ====================================
            // Ícone de "Replay" se o áudio terminou.
            // ====================================
            if (processingState == ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.replay), // Ícone de replay
                iconSize: 54.0,
                onPressed: () async {
                  player.seek(Duration.zero); // Volta ao início do áudio
                  await _playAudio(); // Ativa e inicia a reprodução
                },
                tooltip: 'Reiniciar áudio', // Tooltip para acessibilidade
              );
            }

            // ====================================
            // Indicador de carregamento/buffering.
            // ====================================
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

            // ====================================
            // Exibe o botão de play se o áudio estiver pausado.
            // ====================================
            if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow), // Ícone de play
                iconSize: 54.0,
                onPressed: () async {
                  await _playAudio();
                },
                tooltip: 'Reproduzir', // Tooltip para acessibilidade
              );
            }

            // ====================================
            // Exibe o botão de pause se o áudio estiver tocando.
            // ====================================
            return IconButton(
              icon: const Icon(Icons.pause), // Ícone de pause
              iconSize: 54.0,
              onPressed: () async {
                await _pauseAudio();
              },
              tooltip: 'Pausar', // Tooltip para acessibilidade
            );
          },
        ),

        // ====================================
        // Botão para alterar a velocidade.
        // ====================================
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) {
            final speed = snapshot.data ?? 1.0;
            return IconButton(
              icon: Text(
                "${speed.toStringAsFixed(1)}x", // Exibe a velocidade atual
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _changePlaybackSpeed(context, player, speed);
              },
              tooltip: 'Velocidade de reprodução ${speed.toStringAsFixed(1)}x',
            );
          },
        ),
      ],
    );
  }

  // ====================================
  // Função para reproduzir o áudio e ativar a audio session
  // ====================================
  Future<void> _playAudio() async {
    final session = await AudioSession.instance;
    await session.setActive(true); // Ativa a audio session
    await player.play();
  }

  // ====================================
  // Função para pausar o áudio e desativar a audio session
  // ====================================
  Future<void> _pauseAudio() async {
    await player.pause();
    final session = await AudioSession.instance;
    await session.setActive(false); // Desativa a audio session
  }

  // ====================================
  // Função para alterar a velocidade do áudio.
  // ====================================
  void _changePlaybackSpeed(
      BuildContext context, AudioPlayer player, double currentSpeed) {
    double newSpeed;

    if (currentSpeed == 1.0) {
      newSpeed = 1.5;
    } else if (currentSpeed == 1.5) {
      newSpeed = 2.0;
    } else if (currentSpeed == 2.0) {
      newSpeed = 2.5;
    } else {
      newSpeed = 1.0; // Retorna para a velocidade normal
    }

    player.setSpeed(newSpeed); // Passa a nova velocidade para o player

    // Faz o feedback através do Snackbar para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Velocidade ${newSpeed.toStringAsFixed(1)}x'),
      ),
    );
  }
}
