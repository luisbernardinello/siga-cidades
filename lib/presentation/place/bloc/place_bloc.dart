import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'place_event.dart';
import 'place_state.dart';
import 'dart:async';

class SongPlayerBloc extends Bloc<SongPlayerEvent, SongPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isBuffering = false;
  Timer? _bufferingTimer;
  Timer? _timeoutTimer;

  SongPlayerBloc() : super(SongPlayerInitial()) {
    // Event handlers
    on<LoadSongEvent>(_onLoadSong);
    on<PlayPauseSongEvent>(_onPlayPauseSong);
    on<ChangePlaybackSpeedEvent>(_onChangePlaybackSpeed);
    on<SeekPositionEvent>(_onSeekPosition);
    on<BufferingEvent>(_onBuffering);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<ResetPlayerEvent>(_onResetPlayer);

    // Escuta mudanças no estado de processamento do áudio
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        add(ResetPlayerEvent());
      } else if (state == ProcessingState.loading ||
          state == ProcessingState.buffering) {
        _isBuffering = true;
        _startBufferingTimer(); // Inicia o timer de buffering
      } else if (state == ProcessingState.ready) {
        _isBuffering = false;
        _cancelTimers(); // Cancela timers se estiver pronto
        add(UpdatePositionEvent(
          _audioPlayer.position,
          _audioPlayer.bufferedPosition,
          _audioPlayer.duration ?? Duration.zero,
        ));
      }
    });

    // Atualiza a posição do áudio
    _audioPlayer.positionStream.listen((position) {
      add(UpdatePositionEvent(position, _audioPlayer.bufferedPosition,
          _audioPlayer.duration ?? Duration.zero));
    });
  }

  Future<void> _onLoadSong(
      LoadSongEvent event, Emitter<SongPlayerState> emit) async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(event.url)),
          preload: true);
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

  void _onPlayPauseSong(
      PlayPauseSongEvent event, Emitter<SongPlayerState> emit) async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
      _startBufferingTimer(); // Inicia o timer se o áudio não tocar imediatamente
    }
  }

  void _onChangePlaybackSpeed(
      ChangePlaybackSpeedEvent event, Emitter<SongPlayerState> emit) async {
    double newSpeed = _audioPlayer.speed == 1.0
        ? 1.5
        : (_audioPlayer.speed == 1.5 ? 2.0 : 1.0);
    await _audioPlayer.setSpeed(newSpeed);
  }

  void _onSeekPosition(
      SeekPositionEvent event, Emitter<SongPlayerState> emit) async {
    await _audioPlayer.seek(event.newPosition);
  }

  void _onBuffering(BufferingEvent event, Emitter<SongPlayerState> emit) {
    emit(SongPlayerBuffering()); // Exibe estado de buffering
    _startTimeoutTimer(); // Inicia o timer de timeout
  }

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

  void _onResetPlayer(ResetPlayerEvent event, Emitter<SongPlayerState> emit) {
    _audioPlayer.stop();
    _audioPlayer.seek(Duration.zero);
    emit(SongPlayerLoaded(
      isPlaying: false,
      position: Duration.zero,
      duration: _audioPlayer.duration ?? Duration.zero,
      playbackSpeed: 1.0,
      isBuffering: false,
    ));
  }

  // Timer para iniciar o estado de buffering após 5 segundos
  void _startBufferingTimer() {
    _bufferingTimer?.cancel(); // Cancela qualquer timer anterior
    _bufferingTimer = Timer(const Duration(seconds: 5), () {
      if (_isBuffering) {
        add(BufferingEvent());
      }
    });
  }

  // Timer para exibir timeout após 10 segundos de buffering
  void _startTimeoutTimer() {
    _timeoutTimer?.cancel(); // Cancela qualquer timer anterior
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (_isBuffering) {
        add(TimeoutEvent());
      }
    });
  }

  // Cancela os timers de buffering e timeout
  void _cancelTimers() {
    _bufferingTimer?.cancel();
    _timeoutTimer?.cancel();
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    _cancelTimers();
    return super.close();
  }
}
