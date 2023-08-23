import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TimetableModify extends StatefulWidget {
  const TimetableModify({super.key});

  @override
  State<TimetableModify> createState() => _TimetableModifyState();
}

class _TimetableModifyState extends State<TimetableModify> {
  final PageController _pg = PageController();
  dynamic timetableData;

  Widget? _page2;

  Widget page1(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [global.textWidget(timetableData.toString())],
      ),
    );
  }

  Widget page2(BuildContext context) {
    return _page2 ?? const Text("page2");
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      timetableData =
          (await global.Database!.firestore.collection("/timetable").get())
              .docs;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return timetableData == null
        ? Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 50.0,
                ),
                const SizedBox(
                  height: 30,
                ),
                global.textWidgetWithHeavyFont("Loading timetable data...")
              ],
            ))
        : Scaffold(
            appBar: AppBar(
              title: global
                  .textWidgetWithHeavyFont('Timetable Modification Panel'),
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).textSelectionTheme.selectionColor),
                onPressed: () {
                  global.switchToPrimaryUi();
                },
              ),
            ),
            backgroundColor: Colors.transparent,
            body: PageView(
              clipBehavior: Clip.antiAlias,
              controller: _pg,
              // physics: const NeverScrollableScrollPhysics(),
              children: [page1(context), page2(context)],
            ),
          );
  }
}
