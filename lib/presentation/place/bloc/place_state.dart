import 'package:equatable/equatable.dart';

// Estado abstrato para o player de música
abstract class SongPlayerState extends Equatable {
  const SongPlayerState();

  @override
  List<Object?> get props => [];
}

class SongPlayerInitial extends SongPlayerState {}

// Estado inicial enquanto o áudio está carregando
class SongPlayerLoading extends SongPlayerState {}

// Estado inicial enquanto o áudio está carregando
class SongPlayerBuffering extends SongPlayerState {}

// Estado quando o áudio foi carregado e está pronto para tocar
class SongPlayerLoaded extends SongPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final bool isBuffering;

  const SongPlayerLoaded({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.isBuffering,
  });

  @override
  List<Object> get props => [
        isPlaying,
        position,
        duration,
        playbackSpeed,
        isBuffering,
      ];
}

// Estado de falha ao carregar o áudio
class SongPlayerFailure extends SongPlayerState {
  final String message;

  const SongPlayerFailure({required this.message});

  @override
  List<Object> get props => [message];
}
