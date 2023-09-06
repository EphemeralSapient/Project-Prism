import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TimetableModify extends StatefulWidget {
  const TimetableModify({super.key});

  @override
  State<TimetableModify> createState() => _TimetableModifyState();
}

class _TimetableModifyState extends State<TimetableModify> {
  final PageController _pg = PageController();

  Map<String, dynamic> ttData = {
    "name": "",
    "timings": "",
    "breaks": 0,
    "periods": 0,
  }; // Loaded and updated, meant for 2nd page usage.

  dynamic timetableData; // Obtained data from database
  var nameController = TextEditingController();

  void switchPages(int? page) {
    setState(() {});
    _pg.animateToPage(page ?? (_pg.page == 1.0 ? 0 : 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutExpo);
  }

  Widget page1(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ttData = {
            "name": " ",
            "timings": "",
            "breaks": 0,
            "periods": 0,
          };
          ttData["new"] = true;
          nameController.clear();
          switchPages(1);
        },
        backgroundColor: Theme.of(context).focusColor.withOpacity(1),
        child: Icon(
          Icons.add,
          color: Theme.of(context).textSelectionTheme.selectionColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var x in timetableData)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  surfaceTintColor: Colors.transparent,
                  color: Theme.of(context).focusColor,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  child: Slidable(
                    endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (a) {
                            global.alert.quickAlert(
                                context,
                                global.textWidgetWithHeavyFont(
                                    "Are you sure that you want to REMOVE this time table plan?"),
                                action: [
                                  FloatingActionButton(
                                      onPressed: () async {
                                        try {
                                          await global.Database!.firestore
                                              .collection(
                                                  "/timetable/timing/types")
                                              .doc("${x.data()["name"]}")
                                              .delete();
                                          timetableData.remove(x);
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          global.snackbarText(
                                              "Failed to delete | ${e.toString()}");
                                          debugPrint(e.toString());
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      backgroundColor: Colors.green,
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )),
                                  FloatingActionButton(
                                      backgroundColor: Colors.red,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Icon(Icons.close,
                                          color: Colors.white)),
                                ]);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.remove,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        ttData = x.data();
                        ttData["new"] = false;
                        nameController =
                            TextEditingController(text: ttData["name"]);
                        switchPages(1);
                      },
                      child: SizedBox(
                        height: 75,
                        width: double.infinity,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.center,
                              children: [
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    global.textDoubleSpanWiget(
                                        "${x.data()["name"]}   ", "8 periods"),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    global.textWidget("9:00 AM -> 5:00 PM")
                                  ],
                                )
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget page2(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            ttData["name"] = nameController.text;
            await global.Database!.firestore
                .collection("/timetable/timing/types")
                .doc("${ttData["name"]}")
                .set(ttData);
            timetableData = (await global.Database!.firestore
                    .collection("/timetable/timing/types")
                    .get())
                .docs;
            global.snackbarText("Updated the plans");
            switchPages(0);
          } catch (e) {
            global.snackbarText("Failed to update | ${e.toString()}");
            debugPrint(e.toString());
          }
        },
        backgroundColor: Theme.of(context).focusColor.withOpacity(1),
        child: Icon(
          Icons.done,
          color: Theme.of(context).textSelectionTheme.selectionColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                controller: nameController,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).textSelectionTheme.cursorColor),
                decoration: InputDecoration(
                  labelText: "Schedule Name",
                  hintText: "(e.g., Special class, Generic class)",
                  prefixIcon: const Icon(
                    Icons.event_note,
                    color: Colors.blue,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textSelectionTheme
                        .selectionHandleColor, // Hint text color
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      timetableData = (await global.Database!.firestore
              .collection("/timetable/timing/types")
              .get())
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
                  if (_pg.page == 0.0) {
                    global.switchToPrimaryUi();
                  } else {
                    switchPages(0);
                  }
                },
              ),
            ),
            backgroundColor: Colors.transparent,
            body: PageView(
              clipBehavior: Clip.antiAlias,
              controller: _pg,
              physics: const NeverScrollableScrollPhysics(),
              children: [page1(context), page2(context)],
            ),
          );
  }
}
