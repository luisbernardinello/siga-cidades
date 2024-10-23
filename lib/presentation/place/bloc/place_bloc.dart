import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart'; // Importando rxdart
import 'place_event.dart';
import 'place_state.dart';

class SongPlayerBloc extends Bloc<SongPlayerEvent, SongPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isBuffering = false;

  SongPlayerBloc() : super(SongPlayerLoading()) {
    // Definindo event handlers
    on<LoadSongEvent>(_onLoadSong);
    on<PlayPauseSongEvent>(_onPlayPauseSong);
    on<ChangePlaybackSpeedEvent>(_onChangePlaybackSpeed);
    on<UpdatePositionEvent>(_onUpdatePosition);

    // Escuta mudanças no estado de processamento do áudio
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.loading ||
          state == ProcessingState.buffering) {
        _isBuffering = true;
        add(UpdatePositionEvent(
            _audioPlayer.position,
            _audioPlayer.bufferedPosition,
            _audioPlayer.duration ?? Duration.zero));
      } else if (state == ProcessingState.ready ||
          state == ProcessingState.completed) {
        _isBuffering = false;
        add(UpdatePositionEvent(
            _audioPlayer.position,
            _audioPlayer.bufferedPosition,
            _audioPlayer.duration ?? Duration.zero));
      }
    });

    // Escuta mudanças na posição do áudio e despacha eventos
    Rx.combineLatest3<Duration, Duration, Duration?,
        (Duration, Duration, Duration)>(
      _audioPlayer.positionStream,
      _audioPlayer.bufferedPositionStream,
      _audioPlayer.durationStream,
      (position, bufferedPosition, duration) =>
          (position, bufferedPosition, duration ?? Duration.zero),
    ).listen((data) {
      final (position, bufferedPosition, duration) = data;
      add(UpdatePositionEvent(position, bufferedPosition, duration));
    });
  }

  // Carrega a música
  Future<void> _onLoadSong(
      LoadSongEvent event, Emitter<SongPlayerState> emit) async {
    emit(SongPlayerLoading());
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Evita pré-carregar completamente o áudio.
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(event.url)),
        preload: false,
      );
      emit(SongPlayerLoaded(
        isPlaying: false,
        position: Duration.zero,
        duration: _audioPlayer.duration ?? Duration.zero,
        playbackSpeed: _audioPlayer.speed,
        isBuffering: false,
      ));
    } catch (e) {
      emit(SongPlayerFailure(
          message: "Erro ao carregar o áudio: ${e.toString()}"));
    }
  }

  // Alterna entre play e pause
  void _onPlayPauseSong(
      PlayPauseSongEvent event, Emitter<SongPlayerState> emit) async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    add(UpdatePositionEvent(_audioPlayer.position,
        _audioPlayer.bufferedPosition, _audioPlayer.duration ?? Duration.zero));
  }

  // Altera a velocidade de reprodução
  void _onChangePlaybackSpeed(
      ChangePlaybackSpeedEvent event, Emitter<SongPlayerState> emit) async {
    double newSpeed = _audioPlayer.speed == 1.0
        ? 1.5
        : (_audioPlayer.speed == 1.5 ? 2.0 : 1.0);
    await _audioPlayer.setSpeed(newSpeed);
    add(UpdatePositionEvent(_audioPlayer.position,
        _audioPlayer.bufferedPosition, _audioPlayer.duration ?? Duration.zero));
  }

  // Atualiza a posição atual do áudio
  void _onUpdatePosition(
      UpdatePositionEvent event, Emitter<SongPlayerState> emit) {
    emit(SongPlayerLoaded(
      isPlaying: _audioPlayer.playing,
      position: event.position,
      duration: event.duration,
      playbackSpeed: _audioPlayer.speed,
      isBuffering: _isBuffering,
    ));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}

// Define o evento para atualizar a posição
class UpdatePositionEvent extends SongPlayerEvent {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  UpdatePositionEvent(this.position, this.bufferedPosition, this.duration);
}
