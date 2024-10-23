import 'package:equatable/equatable.dart';

// Definição abstrata dos eventos do SongPlayerBloc
abstract class SongPlayerEvent extends Equatable {
  const SongPlayerEvent();

  @override
  List<Object?> get props => [];
}

// Evento para carregar a música a partir da URL
class LoadSongEvent extends SongPlayerEvent {
  final String url;

  const LoadSongEvent(this.url);

  @override
  List<Object> get props => [url];
}

// Evento para tocar/pausar a música
class PlayPauseSongEvent extends SongPlayerEvent {}

// Evento para mudar a velocidade de reprodução
class ChangePlaybackSpeedEvent extends SongPlayerEvent {}

// Evento para buscar uma nova posição no áudio (seek)
class SeekPositionEvent extends SongPlayerEvent {
  final Duration newPosition;

  const SeekPositionEvent(this.newPosition);

  @override
  List<Object> get props => [newPosition];
}

// Evento para atualizar a posição atual do áudio
class UpdatePositionEvent extends SongPlayerEvent {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const UpdatePositionEvent(
    this.position,
    this.bufferedPosition,
    this.duration,
  );

  @override
  List<Object> get props => [position, bufferedPosition, duration];
}

// Evento para indicar que o áudio está em buffering
class BufferingEvent extends SongPlayerEvent {}

// Evento para indicar que o áudio está pronto para tocar
class ReadyEvent extends SongPlayerEvent {}
