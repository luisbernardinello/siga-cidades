import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:sigacidades/presentation/place/widgets/control_buttons.dart';
import 'package:audio_session/audio_session.dart';

class SongPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String audioTitle;

  const SongPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.audioTitle,
  }) : super(key: key);

  @override
  _SongPlayerWidgetState createState() => _SongPlayerWidgetState();
}

class _SongPlayerWidgetState extends State<SongPlayerWidget> {
  late AudioPlayer _player;
  late LockCachingAudioSource _audioSource;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _audioSource = LockCachingAudioSource(Uri.parse(widget.audioUrl));
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // Iniciando a sessão de áudio
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    try {
      // Lidar com interrupções de áudio
      session.becomingNoisyEventStream.listen((_) {
        _player.pause(); // Pausa o player se os fones forem desconectados
      });

      await _player.setAudioSource(_audioSource);
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // Combina streams de posição, buffer e duração usando o Rx.combineLatest3 com tipagem correta
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (Duration position, Duration bufferedPosition, Duration? duration) {
          return PositionData(
            position,
            bufferedPosition,
            duration ?? Duration.zero,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinhar título à esquerda
      children: [
        // Exibe o título do áudio
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
        // Botões de controle (play, pause, etc.)
        ControlButtons(_player),

        // Barra de progresso com StreamBuilder
        StreamBuilder<PositionData>(
          stream: _positionDataStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return ProgressBar(
              progress: positionData?.position ?? Duration.zero,
              buffered: positionData?.bufferedPosition ?? Duration.zero,
              total: positionData?.duration ?? Duration.zero,
              onSeek: _player.seek,
              bufferedBarColor: Color.fromARGB(255, 237, 10, 10),
              progressBarColor: Color.fromARGB(255, 86, 175, 159),
            );
          },
        ),
        // ElevatedButton(
        //   onPressed: _audioSource.clearCache,
        //   child: const Text('Limpar cache'),
        // ),
      ],
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
