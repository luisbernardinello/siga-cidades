import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Classe responsável pelos botões de controle de reprodução de áudio.
/// Possui funcionalidades de Play/Pause e ajuste de velocidade de reprodução
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
        // Aqui trabalhamos com o StreamBuilder para receber o Stream gerado pela interação do usuário com os botões
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            // ====================================
            // Se o áudio terminar (estado "completed"),
            // volta para o início e mostra o ícone de replay
            // ====================================
            if (processingState == ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.replay), // Ícone de replay
                iconSize: 54.0,
                onPressed: () {
                  player.seek(Duration.zero); // Volta para o início do áudio
                  player.play(); // Reinicia a reprodução do áudio
                },
                tooltip: 'Reiniciar áudio', // Tooltip para acessibilidade
              );
            }

            // ====================================
            // Indicador de carregamento/buffering
            // ====================================
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Semantics(
                label: 'Carregando áudio',
                child: Container(
                  width: 54.0,
                  height: 54.0,
                  margin: const EdgeInsets.all(8.0),
                  child:
                      const CircularProgressIndicator(), // Mostra o carregamento com o mesmo tamanho do botão para consistência do design.
                ),
              );
            }

            // ====================================
            // Se o áudio estiver pausado, mostra o botão de play
            // ====================================
            if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow), // Ícone de play
                iconSize: 54.0,
                onPressed: player.play, // Faz a reprodução do áudio
                tooltip: 'Reproduzir', // Tooltip para acessibilidade
              );
            }

            // ====================================
            // Se o áudio estiver tocando, mostra o botão de Pause
            // ====================================
            return IconButton(
              icon: const Icon(Icons.pause), // Ícone de pause
              iconSize: 54.0,
              onPressed: player.pause, // Pausa a reprodução
              tooltip: 'Pausar', // Tooltip para acessibilidade
            );
          },
        ),

        // ====================================
        // Botão para alterar a velocidade
        // ====================================
        // Aqui trabalhamos com o StreamBuilder para receber o Stream gerado pela interação do usuário com os botões
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
                _changePlaybackSpeed(
                    context, player, speed); // Muda a velocidade
              },
              tooltip:
                  'Velocidade de reprodução ${speed.toStringAsFixed(1)}x', // Tooltip para acessibilidade
            );
          },
        ),
      ],
    );
  }

  // ====================================
  // Função para alterar a velocidade (referente ao botão para alterar a velocidade)
  // ====================================
  // Alterar a velocidade de reprodução do áudio entre 0.5x, 1.0x, 1.5x, 2.0x, 2.5x.
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

    player.setSpeed(newSpeed); // Nova velocidade no player

    // ====================================
    // Feedback sonoro com Snackbar com a velocidade atualizada
    // ====================================
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Velocidade ${newSpeed.toStringAsFixed(1)}x'),
      ),
    );
  }
}
