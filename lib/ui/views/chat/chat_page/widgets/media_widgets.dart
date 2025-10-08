import 'package:flutter/material.dart';
import 'package:flutter_chat_types/src/messages/video_message.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoMessage message;
  final VoidCallback? onPlayPressed;

  VideoPlayerWidget(this.message, this.onPlayPressed, {super.key});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.message.uri))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    widget.onPlayPressed!();
    // setState(() {
    //   if (_controller.value.isPlaying) {
    //     _controller.pause();
    //     _isPlaying = false;
    //   } else {
    //     _controller.play();
    //     _isPlaying = true;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : CircularProgressIndicator(),
        if (!_isPlaying)
          GestureDetector(
            onTap: _togglePlayPause,
            child: Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white,
            ),
          ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Row(
            children: [
              Icon(Icons.videocam, color: Colors.white),
              SizedBox(width: 4),
              Text(
                _formatDuration(_controller.value.duration),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Text(
            _formatDateTime(DateFormat('yyyy-MM-dd hh:mm:ss aaa')
                .parse(widget.message.metadata!['timestamp'])),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate = DateFormat('dd, MMM').add_jm().format(dateTime);
    return formattedDate;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }



  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    //_formatDateTime(DateFormat('yyyy-MM-dd hh:mm:ss aaa')
    //                     .parse(recentTransaction.modifiedAt!))
    return DateFormat('yyyy-MM-dd hh:mm:ss aaa').format(dateTime);
  }
}


class AudioPlayerWidget extends StatefulWidget {
  final String url;

  const AudioPlayerWidget({required this.url});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.url);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            _audioPlayer.play();
          },
        ),
        IconButton(
          icon: Icon(Icons.pause),
          onPressed: () {
            _audioPlayer.pause();
          },
        ),
        Expanded(
          child: StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return Slider(
                value: position.inSeconds.toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
                min: 0.0,
                max: (_audioPlayer.duration?.inSeconds ?? 0).toDouble(),
              );
            },
          ),
        ),
      ],
    );
  }
}