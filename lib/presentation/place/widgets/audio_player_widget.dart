import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/bloc/place_bloc.dart';
import 'package:sigacidades/presentation/place/bloc/place_event.dart';
import 'package:sigacidades/presentation/place/bloc/place_state.dart';

class AudioPlayerWidget extends StatelessWidget {
  final Place place;

  const AudioPlayerWidget({super.key, required this.place});

  String formatDuration(Duration duration) {
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SongPlayerBloc()..add(LoadSongEvent(place.linkAD)),
      child: BlocBuilder<SongPlayerBloc, SongPlayerState>(
        builder: (context, state) {
          if (state is SongPlayerLoading) {
            return const CircularProgressIndicator();
          } else if (state is SongPlayerLoaded) {
            return Column(
              children: [
                Row(
                  children: [
                    // Botão de Play/Pause
                    IconButton(
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 36,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        context
                            .read<SongPlayerBloc>()
                            .add(PlayPauseSongEvent());
                      },
                    ),
                    // Slider para progresso
                    Expanded(
                      child: Slider(
                        value: state.position.inSeconds.toDouble(),
                        min: 0.0,
                        max: state.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          context.read<SongPlayerBloc>().add(
                                SeekPositionEvent(
                                  Duration(seconds: value.toInt()),
                                ),
                              );
                        },
                      ),
                    ),
                    // Botão de Velocidade
                    TextButton(
                      onPressed: () {
                        context
                            .read<SongPlayerBloc>()
                            .add(ChangePlaybackSpeedEvent());
                      },
                      child: Text(
                        'x${state.playbackSpeed.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(state.position)),
                    Text(formatDuration(state.duration)),
                  ],
                ),
              ],
            );
          } else if (state is SongPlayerFailure) {
            return const Text("Erro ao carregar o áudio");
          }

          return const SizedBox();
        },
      ),
    );
  }
}
