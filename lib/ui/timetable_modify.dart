import 'dart:math';

import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timetable/timetable.dart';

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

  final _draggedEvents = <BasicEvent>[];

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
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: global.classicTextField(
                "Schedule Name",
                "(e.g., Special class, Generic class)",
                nameController,
                const Icon(
                  Icons.event_note,
                  color: Colors.blue,
                ),
              ),
            ),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          // Controllers
                          Map<String, dynamic> controls = {};

                          for (var x in ttData["events"] ?? []) {
                            controls[x["name"]] = [
                              TextEditingController(text: x["name"]),
                              x["type"],
                              TextEditingController(text: x["duration"]),
                            ];
                          }

                          global.alert.quickAlert(context, const Text("wut"),
                              bodyFn: () {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var x in controls.values ?? [])
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 90,
                                          child: global.classicTextField(
                                              "Event Name",
                                              "e.g Lunch",
                                              x[0],
                                              null),
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: DropdownButton(
                                            elevation: 0,
                                            iconSize: 0,
                                            items: [
                                              for (var x in [
                                                ["Break", "Break"],
                                                ["Class", "Class"],
                                                ["Others", "Others"],
                                              ])
                                                DropdownMenuItem(
                                                  value: x[1],
                                                  child: global
                                                      .textWidget_ns(x[1]),
                                                ),
                                            ],
                                            value: x[1],
                                            dropdownColor: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.75),
                                            onChanged: (value) {
                                              x[1] = value.toString();
                                              global.quickAlertGlobalVar(() {});
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 40,
                                          width: 80,
                                          child: global.classicTextField(
                                              "Duration", "in mins", x[2], null,
                                              keyboardType:
                                                  TextInputType.phone),
                                        ),
                                        Expanded(
                                          child: IconButton(
                                              onPressed: () {
                                                controls.remove(x[0].text);
                                                debugPrint(
                                                    controls.keys.toString());
                                                global
                                                    .quickAlertGlobalVar(() {});
                                              },
                                              icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.redAccent,
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.create,
                                    color: Colors.lightBlueAccent,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.9)),
                                  onPressed: () {
                                    String eventName =
                                        "R${Random.secure().nextInt(1000)}";
                                    controls[eventName] = [
                                      TextEditingController(text: eventName),
                                      "Class",
                                      TextEditingController(text: "30")
                                    ];
                                    global.quickAlertGlobalVar(() {});
                                  },
                                  label: global.textWidgetWithHeavyFont(
                                      "Create new event"),
                                )
                              ],
                            );
                          }, action: [
                            FloatingActionButton(
                              backgroundColor: Colors.redAccent,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.cancel),
                            ),
                            FloatingActionButton(
                              backgroundColor: Colors.blueAccent,
                              onPressed: () {
                                ttData["events"] = [
                                  for (var x in controls.values)
                                    {
                                      "name": x[0].text,
                                      "type": x[1],
                                      "duration": x[2].text
                                    }
                                ];
                                setState(() {});
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.done),
                            )
                          ]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: global.textWidget_ns("Drag n' Drop "),
                              ),
                              const Icon(Icons.edit,
                                  size: 20, color: Colors.blue)
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8, top: 5, bottom: 5),
                        child: Wrap(
                          spacing: 10,
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            for (var names in ttData["events"] ?? [])
                              DraggableWidget(label: names["name"]),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Time table UI

            Flexible(
              child: TimetableConfig<BasicEvent>(
                key: Key(DateTime.now().toIso8601String()),

                timeController: TimeController(
                    initialRange: TimeRange(
                        const Duration(hours: 7), const Duration(hours: 20))),
                dateController: DateController(
                    visibleRange:
                        VisibleDateRange.fixed(DateTimeTimetable.today(), 1)),
                eventBuilder: (context, event) => BasicEventWidget(event),
                timeOverlayProvider: (context, date) => <TimeOverlay>[
                  TimeOverlay(
                    start: const Duration(hours: 0),
                    end: const Duration(hours: 7),
                    widget: const ColoredBox(color: Colors.black12),
                    position: TimeOverlayPosition
                        .behindEvents, // the default, alternatively `inFrontOfEvents`
                  ),
                  TimeOverlay(
                    start: const Duration(hours: 20),
                    end: const Duration(hours: 24),
                    widget: const ColoredBox(color: Colors.black12),
                  ),
                ],
                // Optional:
                // eventProvider: (date) => someListOfEvents,
                allDayEventBuilder: (context, event, info) =>
                    BasicAllDayEventWidget(event, info: info),
                // allDayOverflowBuilder: (date, overflowedEvents) => /* … */,
                callbacks: TimetableCallbacks(
                  onDateTimeBackgroundTap: (dateTime) {
                    debugPrint(dateTime.toString());
                  },
                  // onWeekTap, onDateTap, onDateBackgroundTap, onDateTimeBackgroundTap, and
                  // onMultiDateHeaderOverflowTap
                ),
                theme: TimetableThemeData(
                  context,
                  // startOfWeek: DateTime.monday,
                  // See the "Theming" section below for more options.
                ),
                child: RecurringMultiDateTimetable<BasicEvent>(),
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

class DraggableWidget extends StatelessWidget {
  final String label;
  Color color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);

  DraggableWidget({
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: color,
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: global.textWidget_ns(
                label,
              ),
            ),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: color,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          child: Center(
            child: global.textWidget_ns(
              label,
            ),
          ),
        ),
      ),
    );
  }
}
