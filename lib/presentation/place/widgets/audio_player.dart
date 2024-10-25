import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:sigacidades/presentation/place/widgets/control_buttons.dart';
import 'package:audio_session/audio_session.dart';
import 'package:uuid/uuid.dart';

/// Widget responsável por reproduzir áudio
/// Utiliza as bibliotecas just_audio, audio_session e rxdart.
class SongPlayerWidget extends StatefulWidget {
  final String audioUrl; // URL do áudio que será reproduzido
  final String audioTitle; // Título do áudio
  final Function(AudioPlayer) onPlayerInit; // Callback para retornar o player

  const SongPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.audioTitle,
    required this.onPlayerInit,
  }) : super(key: key);

  @override
  _SongPlayerWidgetState createState() => _SongPlayerWidgetState();
}

class _SongPlayerWidgetState extends State<SongPlayerWidget> {
  late AudioPlayer _player; // Instância do player de áudio
  late LockCachingAudioSource _audioSource;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    var uuid = Uuid();

    // Inicializa a fonte de áudio com suporte a cache e define um identificador único
    _audioSource = LockCachingAudioSource(
      Uri.parse(widget.audioUrl),
      tag: MediaItem(
        id: uuid.v5(Namespace.url.value, widget.audioUrl),
        title: widget.audioTitle,
      ),
    );

    // Passa o player instanciado via callback
    widget.onPlayerInit(_player);
    _initPlayer();
  }

  /// Inicializa o player e configura o audio_session para lidar com interrupções
  Future<void> _initPlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    try {
      // Listener para os eventos de interrupção de áudio (chamadas, navegação, etc.)
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Outro app começou a reproduzir áudio, reduzimos o volume.
              _player.setVolume(0.3);
              break;
            // fall-through de cases
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // Outro app pede que pausemos o áudio (ex: chamada recebida | obs: dois cases seguidos compartilham o mesmo _player.pause()).
              _player.pause();
              break;
          }
        } else {
          // Interrupção terminou
          switch (event.type) {
            case AudioInterruptionType.duck:
              // O app que gerou interrupção terminou; restauramos o volume.
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              // Retoma a reprodução depois de uma chamada ou outra interrupção.
              _player.play();
              break;
            case AudioInterruptionType.unknown:
              // Sem ação adicional.
              break;
          }
        }
      });

      // Listener para desconexão de fones de ouvido
      session.becomingNoisyEventStream.listen((_) {
        _player.pause(); // Pausa ao desconectar fones de ouvido
      });

      // Configuração da fonte de áudio e inicialização do player
      await _player.setAudioSource(_audioSource);
    } catch (e) {
      print("Erro ao carregar o áudio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ControlButtons(_player),
        StreamBuilder<PositionData>(
          stream: _positionDataStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return ProgressBar(
              progress: positionData?.position ?? Duration.zero,
              buffered: positionData?.bufferedPosition ?? Duration.zero,
              total: positionData?.duration ?? Duration.zero,
              onSeek: _player.seek,
            );
          },
        ),
      ],
    );
  }

  /// Combina as streams de posição, buffer e duração do player para
  /// atualização em tempo real da barra de progresso.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );
}

/// Classe responsável por encapsular dados de posição, buffer e duração do player,
/// facilitando a atualização da barra de progresso.
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
