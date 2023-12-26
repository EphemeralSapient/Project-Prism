import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video]

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  // controlsStyle: ControlsStyle.primary,
  // controlsEnabled: false,
  // colorTheme: Colors.transparent);
  late final player = Player();
  late final _controller = VideoController(player,
      configuration: const VideoControllerConfiguration());
  bool _visible = true;

  @override
  void initState() {
    debugPrint("Intro is being played");

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.open(Media(
          "https://cdn.discordapp.com/attachments/304905418306486284/1188707171668598865/intro_anim.mp4?ex=659b80d2&is=65890bd2&hm=c33cd8ec37aa3fd0c5a9c8779d48f207544264eafe6487eb8d3813c8bb81204d&"));

      Future.delayed(const Duration(seconds: 7, milliseconds: 400), () {
        debugPrint("Yes!");
        _visible = false;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    player.dispose(); // release the video player
    super.dispose();
  }

  _getVideoBackground() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: Video(
            controller: _controller,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              color: _visible
                  ? const Color.fromRGBO(233, 238, 230, 1)
                  : Colors.white,
            ),
            IgnorePointer(child: _getVideoBackground())
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class introPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _introPageState();
// }

// class _introPageState extends State<introPage> {
//   final VideoPlayerController _controller =
//       VideoPlayerController.asset("asset/video/intro_anim.mp4");
//   bool _visible = false;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration(seconds: 7, milliseconds: 250), () {
//       _visible = false;
//       setState(() {});
//     });
//     _controller.initialize().then((_) {
//       _controller.setLooping(false);
//       Timer(const Duration(milliseconds: 100), () {
//         setState(() {
//           _controller.play();
//           _visible = true;
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }

//   _getVideoBackground() {
//     return Center(
//       child: AspectRatio(
//         aspectRatio: 1.0,
//         child: AnimatedOpacity(
//           opacity: _visible ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 1000),
//           child: VideoPlayer(_controller),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Stack(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 800),
//               color: _visible ? Color.fromRGBO(233, 238, 230, 1) : Colors.white,
//             ),
//             _getVideoBackground(),
//           ],
//         ),
//       ),
//     );
//   }
// }
