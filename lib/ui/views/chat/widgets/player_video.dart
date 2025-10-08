// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lipa_quick/core/services/blocs/chat_bloc.dart';
import 'package:lipa_quick/core/services/events/chat_events.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:video_player/video_player.dart';

class RemoteVideoPlayer extends StatefulWidget {
  final String remoteVideoUrl;
  final VoidCallback? onPressed;

  RemoteVideoPlayer(this.remoteVideoUrl, this.onPressed);

  @override
  _RemoteVideoPlayerState createState() => _RemoteVideoPlayerState();
}

class _RemoteVideoPlayerState extends State<RemoteVideoPlayer> {
  late VideoPlayerController _controller;
  late CountdownController _countdownController;
  Duration duration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _countdownController = CountdownController(autoStart: false);

    if (widget.remoteVideoUrl.contains('https')
        || widget.remoteVideoUrl.contains('http')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.remoteVideoUrl),
        //closedCaptionFile: _loadCaptions(),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      _controller = VideoPlayerController.file(
        File(widget.remoteVideoUrl),
        //closedCaptionFile: _loadCaptions(),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }

    _controller.addListener(() {
      setState(() {
        duration = _controller.value.duration;
      });
    });
    _controller.setLooping(false);
    _controller.initialize().then((value) => {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height -
                  (MediaQuery.of(context).size.height / 3),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    _ControlsOverlayView(
                      controller: _controller,
                      countdownController: _countdownController,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: FloatingActionButton.small(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          backgroundColor: appGreen400,
                        ))
                  ],
                ),
              ),
            ),
            Container(
              height: (MediaQuery.of(context).size.height / 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w200)),
                        Countdown(
                          controller: _countdownController,
                          seconds: duration.inSeconds,
                          build: (_, double time) {
                            var duration = Duration(seconds: time.toInt());
                            return Text(
                              '${duration.inMinutes}:${duration.inSeconds} secs',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200),
                            );
                          },
                          interval: Duration(seconds: 1),
                          onFinished: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Timer is done!'),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton.small(
                    onPressed: () {
                      widget.onPressed!();
                    },
                    backgroundColor: appGreen400,
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlayView extends StatelessWidget {
  const _ControlsOverlayView(
      {required this.controller, required this.countdownController});

  final VideoPlayerController controller;
  final CountdownController countdownController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? GestureDetector(
                  child: Container(
                    child: const Center(
                      child: Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 50.0,
                        semanticLabel: 'Pause',
                      ),
                    ),
                  ),
                  onTap: () {
                    controller.pause();
                    print('Pause Countdown');
                    countdownController.pause();
                  },
                )
              : GestureDetector(
                  child: Container(
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 50.0,
                        semanticLabel: 'Play',
                      ),
                    ),
                  ),
                  onTap: () {
                    controller.play();
                    if (controller.value.position.inSeconds > 1) {
                      print('OnResume Countdown');
                      countdownController.resume();
                    } else {
                      print('Start Countdown');
                      countdownController.start();
                    }
                  },
                ),
        ),
        // GestureDetector(
        //   onTap: () {
        //     controller.value.isPlaying ? controller.pause() : controller.play();
        //   },
        // )
      ],
    );
  }
}
