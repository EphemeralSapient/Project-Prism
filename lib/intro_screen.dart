import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

class IntroPage extends StatefulWidget {
  IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _meeduPlayerController = MeeduPlayerController(
      controlsStyle: ControlsStyle.primary,
      controlsEnabled: false,
      colorTheme: Colors.transparent);
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _meeduPlayerController.setDataSource(
        DataSource(
          type: DataSourceType.asset,
          source: "asset/video/intro_anim.mp4",
        ),
        autoplay: true,
      );
      Future.delayed(const Duration(seconds: 7, milliseconds: 0), () {
        _visible = false;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _meeduPlayerController.dispose(); // release the video player
    super.dispose();
  }

  _getVideoBackground() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: MeeduVideoPlayer(
            controller: _meeduPlayerController,
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
              color: _visible ? Color.fromRGBO(233, 238, 230, 1) : Colors.white,
            ),
            _getVideoBackground(),
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
