import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:sigacidades/presentation/place/widgets/control_buttons.dart';
import 'package:audio_session/audio_session.dart';

/// Widget responsável por reproduzir áudio
/// Utiliza as bibliotecas just_audio, audio_session e rxdart.
class SongPlayerWidget extends StatefulWidget {
  final String audioUrl; // URL do áudio que será reproduzido
  final String audioTitle; // Título do áudio

  const SongPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.audioTitle,
  }) : super(key: key);

  @override
  _SongPlayerWidgetState createState() => _SongPlayerWidgetState();
}

class _SongPlayerWidgetState extends State<SongPlayerWidget> {
  late AudioPlayer _player; // Instância do player de áudio da just_audio
  late LockCachingAudioSource
      _audioSource; // Instância do método da just_audio com suporte a cache

  // ====================================
  // Método initState
  // ====================================
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer(); // Inicializa o player de áudio
    // Faz a inicialização da fonte de áudio (passando a url) com suporte a cache, assim temos pré-carregamento com o caching do áudio para aceleramento.
    _audioSource = LockCachingAudioSource(Uri.parse(widget.audioUrl));

    // Inicializa a reprodução de áudio
    _initPlayer();
  }

  // ====================================
  // Função para iniciar o player e configurar o audio_session
  // ====================================
  Future<void> _initPlayer() async {
    // Configura o audio_session, importante para gerenciar comportamentos do áudio em segundo plano
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    try {
      // Lida com eventos de interrupção de áudio do audio_session, aqui lidamos com a desconexão de fones de ouvido
      session.becomingNoisyEventStream.listen((_) {
        _player.pause(); // Pausa o áudio no caso dos fones serem desconectados
      });

      // Configura a fonte de áudio que vai para o player e gera erro no caso de não ser possível.
      await _player.setAudioSource(_audioSource);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
        ),
      );
      print("Erro ao carregar fonte de áudio: $e");
    }
  }

  // ====================================
  // Função dispose
  // ====================================
  // Libera os recursos do player ao acabar o widget
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ====================================
  // Stream de dados para exibir a posição, buffer e duração do áudio
  // ====================================
  // Aqui temos RxDart para combinar múltiplas streams (posição atual do player, posição do buffer do player e duração total).
  // Assim podemos exibir todos esses dados eficientemente e em tempo real na barra de progresso.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream, // Stream de posição atual do player
        _player.bufferedPositionStream, // Stream de progresso de buffer
        _player.durationStream, // Stream de duração total do áudio
        (Duration position, Duration bufferedPosition, Duration? duration) {
          return PositionData(
            position, // Retorna o objeto PositionData com a posição atual do áudio
            bufferedPosition, // Posição atual do buffer
            duration ??
                Duration.zero, // Duração total (0 se não estiver carregada)
          );
        },
      );

  // faz o build da interface do player, incluindo os botões de controle do arquivo control_buttons e a barra de progresso do plugin audio_video_progress_bar.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Alinha o título na esquerda
      children: [
        // ====================================
        // Exibe o título do áudio
        // ====================================
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            widget.audioTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ====================================
        // Botões de controle (play, pause, etc.)
        // ====================================
        ControlButtons(
            _player), // Utiliza o widget ControlButtons para controlar a reprodução

        // ====================================
        // Barra de progresso
        // ====================================
        StreamBuilder<PositionData>(
          stream:
              _positionDataStream, // Stream para exibir posição, buffer e duração
          builder: (context, snapshot) {
            final positionData = snapshot.data;

            // Barra de progresso do áudio, utilizando o plugin audio_video_progress_bar
            return ProgressBar(
              progress: positionData?.position ??
                  Duration.zero, // Posição atual do áudio
              buffered: positionData?.bufferedPosition ??
                  Duration.zero, // Posição do buffer
              total: positionData?.duration ??
                  Duration.zero, // Duração total do áudio
              onSeek: _player.seek, // Função para mover a posição do áudio
              bufferedBarColor:
                  const Color.fromARGB(255, 237, 10, 10), // Cor do buffer
              progressBarColor: const Color.fromARGB(
                  255, 86, 175, 159), // Cor da barra de progresso
            );
          },
        ),
      ],
    );
  }
}

// ====================================
// Classe PositionData
// ====================================
// Armazena os dados de posição, buffer e duração para exibir na barra do player
class PositionData {
  final Duration position; // Posição atual do áudio
  final Duration bufferedPosition; // Posição do buffer do áudio
  final Duration duration; // Duração total do áudio

  PositionData(this.position, this.bufferedPosition, this.duration);
}
