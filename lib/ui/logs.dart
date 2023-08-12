import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:flutter_html/flutter_html.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textSelectionTheme.selectionColor),
          onPressed: () {
            global.switchToPrimaryUi();
          },
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        // foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: global.textWidgetWithHeavyFont('Log Screen'),
      ),
      body: ShaderMask(
          shaderCallback: (Rect rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.transparent,
                Colors.transparent,
                Colors.black
              ],
              stops: [0.001, 0.1, 0.95, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: LogList()),
    );
  }
}

class LogList extends StatefulWidget {
  @override
  _LogListState createState() => _LogListState();
}

class _LogListState extends State<LogList> {
  StreamController<String> _logStreamController = StreamController<String>();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listenForLogs();
  }

  void _listenForLogs() {
    // Listen to log updates and add them to the stream
    global.logs.forEach((logMessage) {
      _logStreamController.add(logMessage);
    });
  }

  @override
  void dispose() {
    _logStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: _logStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Automatically scroll to the latest log message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: global.logs.length,
          itemBuilder: (context, index) {
            return LogTile(logMessage: global.logs[index]);
          },
        );
      },
    );
  }
}

class LogTile extends StatefulWidget {
  final String logMessage;

  const LogTile({required this.logMessage});

  @override
  _LogTileState createState() => _LogTileState();
}

class _LogTileState extends State<LogTile> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController!.drive(CurveTween(curve: Curves.easeOut)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Html(
              data: widget.logMessage,
              style: {
                "body": Style(
                  fontSize: FontSize.medium,
                  color: Theme.of(context).textSelectionTheme.selectionColor,
                  fontFamily: "IBM Plex Mono",
                ),
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
