import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/presentation/place/bloc/place_bloc.dart';
import 'package:sigacidades/presentation/place/bloc/place_event.dart';
import 'package:sigacidades/presentation/place/bloc/place_state.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Place place;

  const AudioPlayerWidget({super.key, required this.place});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isDownloading = false;

  // Formatação da duração do áudio
  String formatDuration(Duration duration) {
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Função para baixar o arquivo de áudio
  Future<void> _downloadFile(String url) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final Directory? directory = await getApplicationDocumentsDirectory();
      final String savedDir = directory!.path;

      await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        showNotification: true,
        openFileFromNotification: true,
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao tentar baixar o áudio')),
      );
    }
  }

  // Exibir diálogo de confirmação para download
  void _showDownloadConfirmationDialog(
      BuildContext context, String url, String audioTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Você quer baixar o áudio?')),
        content: Text('Quer baixar o áudio de $audioTitle?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Baixar'),
            onPressed: () {
              Navigator.of(context).pop();
              _downloadFile(url);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações Gerais',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _buildAudioPlayer(
          context,
          widget.place.linkHist, // O primeiro player carrega o linkHist
          BlocProvider(
            create: (_) =>
                SongPlayerBloc()..add(LoadSongEvent(widget.place.linkHist)),
            child: BlocBuilder<SongPlayerBloc, SongPlayerState>(
              builder: (context, state) {
                return _buildPlayerUI(context, state, widget.place.linkHist,
                    'Informações Gerais');
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Audiodescrição',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _buildAudioPlayer(
          context,
          widget.place.linkAD, // O segundo player carrega o linkAD
          BlocProvider(
            create: (_) =>
                SongPlayerBloc()..add(LoadSongEvent(widget.place.linkAD)),
            child: BlocBuilder<SongPlayerBloc, SongPlayerState>(
              builder: (context, state) {
                return _buildPlayerUI(
                    context, state, widget.place.linkAD, 'Audiodescrição');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayer(
    BuildContext context,
    String audioUrl,
    Widget player,
  ) {
    return player;
  }

  Widget _buildPlayerUI(BuildContext context, SongPlayerState state, String url,
      String audioTitle) {
    if (state is SongPlayerLoaded) {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: state.isPlaying
                    ? const Icon(Icons.pause, size: 36, color: Colors.blue)
                    : const Icon(Icons.play_arrow,
                        size: 36, color: Colors.blue),
                onPressed: () {
                  context.read<SongPlayerBloc>().add(PlayPauseSongEvent());
                },
                tooltip: state.isPlaying ? 'Pausar' : 'Tocar',
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

              // Botão de controle de velocidade
              IconButton(
                icon: const Icon(Icons.speed, size: 24, color: Colors.blue),
                onPressed: () {
                  context
                      .read<SongPlayerBloc>()
                      .add(ChangePlaybackSpeedEvent());
                },
                tooltip: 'Mudar velocidade de reprodução',
              ),

              Text(
                'x${state.playbackSpeed.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
          // Botão de download
          if (_isDownloading)
            const CircularProgressIndicator()
          else
            IconButton(
              icon: const Icon(Icons.download, size: 24, color: Colors.blue),
              onPressed: () {
                _showDownloadConfirmationDialog(context, url, audioTitle);
              },
              tooltip: 'Baixar áudio',
            ),
        ],
      );
    } else if (state is SongPlayerFailure) {
      return const Text("Erro ao carregar o áudio");
    } else {
      return Column(
        children: [
          Row(
            children: const [
              IconButton(
                icon: Icon(Icons.play_arrow, size: 36, color: Colors.grey),
                onPressed: null,
              ),
              Expanded(child: LinearProgressIndicator()),
            ],
          ),
        ],
      );
    }
  }
}
