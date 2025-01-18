/* video player widget. To use in a page,
 * import this file, then
 * 
 *    VideoPlayerScreen(
 *      uri: "https://my_pc_ip_address:port/videos/sample_sign.mp4"
 *    )
 * 
 * HTTP servers are better than FTP, it seems.
 * -AST
 */

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class VideoPlayerScreen extends StatefulWidget {
  Uri videoLocation = Uri.parse("");
  VideoPlayerScreen({super.key, String? uri}) {
    videoLocation = Uri.parse(uri.toString());
  }

  @override
  State<VideoPlayerScreen> createState() =>
      _VideoPlayerScreenState(videoLocation);
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  Uri video = Uri.parse("");

  _VideoPlayerScreenState(Uri uri) {
    video = uri;
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(video);

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
            // pause/play as per state
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
        body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                // video if loaded
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              // spinner if unloaded
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
