import 'dart:math';

import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timetable/timetable.dart';

Map<String, dynamic> ttData = {
  // TimeTable data
  "name": "",
  "timings": [],
  "breaks": 0,
  "periods": 0,
}; // Loaded and updated, meant for 2nd page usage.
List<dynamic> periods =
    []; // Period refers to schedule data such as name, index, timing
dynamic c; // Null if period is not being dragging on TT panel
dynamic panelSetState = () {};
bool isDragging = false;
final TimeController tc = TimeController(
    initialRange:
        TimeRange(const Duration(hours: 7), const Duration(hours: 20)));
final DateController dc = DateController(
    visibleRange: VisibleDateRange.fixed(DateTimeTimetable.today(), 1));
final List<BasicEvent> _events = [];
final _draggedEvents = <BasicEvent>[];

class TimetableModify extends StatefulWidget {
  const TimetableModify({super.key});

  @override
  State<TimetableModify> createState() => _TimetableModifyState();
}

class _TimetableModifyState extends State<TimetableModify> {
  final PageController _pg = PageController();

  dynamic timetableData; // Obtained data from database
  var nameController = TextEditingController();

  void switchPages(int? page) {
    setState(() {});
    _pg.animateToPage(page ?? (_pg.page == 1.0 ? 0 : 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutExpo);
  }

  String formatTime(DateTime dateTime) {
    String hour = '${dateTime.hour}'.padLeft(2, '0');
    String minute = '${dateTime.minute}'.padLeft(2, '0');
    // String period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute';
  }

  Widget page1(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ttData = {
            "name": " ",
            "timings": [],
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
                        // ttData["timing"] = [];
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
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Flexible(
                    child: global.classicTextField(
                      "Schedule",
                      "Class Name",
                      nameController,
                      const Icon(
                        Icons.event_note,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Flexible(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      subtitle: global.textWidget("Starting time"),
                      title: InkWell(
                        onTap: () async {
                          final DateTime curr =
                              DateTime.fromMillisecondsSinceEpoch(
                                  ttData["startingTime"] ??
                                      DateTime(2000, 1, 1, 8)
                                          .millisecondsSinceEpoch);
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(curr),
                            helpText: "Set initial timing of this schedule",
                          );

                          if (picked != null) {
                            if (!(picked.hour > 6 && picked.hour < 12 + 9)) {
                              global.snackbarText(
                                  "Please select timing within 7 am to 8 pm");
                              return;
                            }
                            panelSetState(() {
                              ttData["startingTime"] =
                                  DateTime(2000, 1, 1, picked.hour)
                                      .millisecondsSinceEpoch;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: global.textWidgetWithHeavyFont(
                            formatTime(DateTime.fromMillisecondsSinceEpoch(
                                ttData["startingTime"] ??
                                    DateTime(2000, 1, 1, 8)
                                        .millisecondsSinceEpoch)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black,
                      ],
                      stops: [0.0, 0.1, 0.9, 1.0],
                    ).createShader(Offset.zero & rect.size);
                  },
                  blendMode: BlendMode.dstOut,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 30),
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
                                            width: 100,
                                            child: global.classicTextField(
                                                "Name",
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
                                                global
                                                    .quickAlertGlobalVar(() {});
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            height: 40,
                                            width: 80,
                                            child: global.classicTextField(
                                                "Duration",
                                                "in mins",
                                                x[2],
                                                null,
                                                keyboardType:
                                                    TextInputType.phone),
                                          ),
                                          Expanded(
                                            child: IconButton(
                                                onPressed: () {
                                                  controls.remove(x[0].text);
                                                  debugPrint(
                                                      controls.keys.toString());
                                                  global.quickAlertGlobalVar(
                                                      () {});
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
                            padding: const EdgeInsets.all(1.0),
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
                            spacing: 15,
                            // mainAxisSize: MainAxisSize.max,
                            children: [
                              for (var names in ttData["events"] ?? [])
                                DraggableWidget(label: names["name"]),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30)
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Time table UI

            Flexible(
              child: Stack(
                children: [
                  // const SizedBox.expand(child: TimetablePanel()),
                  DragTarget(onAccept: (data) {
                    int i = 0;
                    for (var x in ttData["events"]) {
                      if (x["name"] == data.toString()) {
                        break;
                      }
                      i += 1;
                    }

                    debugPrint("$i | ${ttData["events"].length}");

                    // In case such entity doesn't exist within given _events
                    if (i == (ttData["events"] as List).length) {
                      _accepted = false;
                      return;
                    }
                    ttData["timing"].add(i);
                    _accepted = true;
                    panelSetState(() {});
                    debugPrint("Added the given value!");
                    global.snackbarText(
                        "Added ${data.toString()} to the timetable!");
                  }, onWillAccept: (data) {
                    debugPrint(ttData.toString());
                    debugPrint("Entered");

                    int i = 0;
                    for (var x in ttData["events"]) {
                      if (x["name"] == data.toString()) {
                        break;
                      }
                      i += 1;
                    }

                    debugPrint("$i | ${ttData["events"].length}");

                    // In case such entity doesn't exist within given _events
                    if (i == (ttData["events"] as List).length) {
                      _accepted = false;
                      return false;
                    }
                    _accepted = true;
                    return true;
                  }, onLeave: (data) {
                    if (!_accepted) {
                      return;
                    }
                    ttData["timing"].remove(
                        (ttData["events"] as List<dynamic>).indexOf(data));
                    debugPrint("Left");
                  }, builder: ((context, candidateData, rejectedData) {
                    c = candidateData;
                    debugPrint("building the builder");
                    return const SizedBox.expand(child: TimetablePanel());
                  })),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _accepted = false;

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

class _DemoEvent extends BasicEvent {
  _DemoEvent(
    int demoId,
    int eventId,
    Duration start,
    Duration end, {
    int endDateOffset = 0,
  }) : super(
          id: '$demoId-$eventId',
          title: "",
          backgroundColor: Colors.transparent,
          start: DateTimeTimetable.today().add(start),
          end: DateTimeTimetable.today().add(end),
        );
}

// class _DemoEvent extends BasicEvent {
//   _DemoEvent(
//     int demoId,
//     int eventId,
//     Duration start,
//     Duration end, {
//     int endDateOffset = 0,
//   }) : super(
//           id: '$demoId-$eventId',
//           title: '$demoId-$eventId',
//           backgroundColor: _getColor('$demoId-$eventId'),
//           start: DateTimeTimetable.today() + demoId.days + start,
//           end: DateTimeTimetable.today() + (demoId + endDateOffset).days + end,
//         );

//   _DemoEvent.allDay(int id, int startOffset, int length)
//       : super(
//           id: 'a-$id',
//           title: 'a-$id',
//           backgroundColor: _getColor('a-$id'),
//           start: DateTimeTimetable.today() + startOffset.days,
//           end: DateTimeTimetable.today() + (startOffset + length).days,
//         );

//   static Color _getColor(String id) {
//     return Random(id.hashCode)
//         .nextColorHsv(saturation: 0.6, value: 0.8, alpha: 1)
//         .toColor();
//   }
// }

class DraggableWidget extends StatelessWidget {
  final String label;
  Color color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);

  DraggableWidget({
    required this.label,
    super.key,
  });

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

class TimetablePanel extends StatefulWidget {
  const TimetablePanel({super.key});

  @override
  State<TimetablePanel> createState() => _TimetablePanelState();
}

class _TimetablePanelState extends State<TimetablePanel> {
  @override
  void dispose() {
    debugPrint("Panel getting disposed!");
    super.dispose();
  }

  Widget _buildPartDayEvent(BasicEvent event, BuildContext buildContext) {
    var showSnackBar = global.snackbarText;
    const roundedTo = Duration(minutes: 10);

    return PartDayDraggableEvent(
      onDragStart: () {
        panelSetState(() => _draggedEvents.add(event));
      },
      onDragUpdate: (dateTime) {
        panelSetState(() {
          isDragging = true;
          dateTime = dateTime.roundTimeToMultipleOf(roundedTo);
          final index = _draggedEvents.indexWhere((it) => it.id == event.id);
          final oldEvent = _draggedEvents[index];
          _draggedEvents[index] = oldEvent.copyWith(
            start: dateTime,
            end: dateTime.add(oldEvent.duration),
          );
        });
      },
      onDragEnd: (dateTime) {
        isDragging = false;
        dateTime = (dateTime ?? event.start).roundTimeToMultipleOf(roundedTo);
        var info = event.id
            .toString()
            .split("-"); // 0 => Position, 1 => Event position

        debugPrint(ttData.toString());
        panelSetState(
            () => _draggedEvents.removeWhere((it) => it.id == event.id));

        if (dateTime.hour < 7 || dateTime.hour > 12 + 7) {
          // Delete it
          (ttData["timing"] as List).removeAt(int.tryParse(info[0])!);
          showSnackBar("Deleted");
        } else {
          // Move it to given order

          int initalIndex = int.tryParse(info[0])!;
          int movingIndex = 0;
          Duration startingHour =
              DateTime.fromMillisecondsSinceEpoch(ttData["startingTime"])
                  .timeOfDay;

          for (BasicEvent x in _events) {
            if (startingHour > dateTime.timeOfDay) {
              break;
            } else {
              movingIndex += 1;
              debugPrint("no");
            }
            startingHour += x.duration;
          }

          debugPrint("Moving from $initalIndex to $movingIndex");

          // Move intialIndex to movingIndex in ttData["timing"]
          (ttData["timing"] as List).insert(movingIndex, int.tryParse(info[1]));
          (ttData["timing"] as List)
              .removeAt(initalIndex + (initalIndex > movingIndex ? 1 : 0));
          showSnackBar(
              "Moved ${initalIndex + 1} position => ${movingIndex + 1} position");
        }
        setState(() {});
        //showSnackBar('Dragged event to $dateTime. ');
      },
      onDragCanceled: (isMoved) => debugPrint('Your finger moved: $isMoved'),
      child: BasicEventWidget(
        event,
        onTap: () => showSnackBar('Part-day event $event tapped'),
      ),
    );
  }

  @override
  void initState() {
    panelSetState = setState;
    super.initState();
    debugPrint("Time table panel has been init");
    debugPrint(ttData.toString());
  }

  @override
  Widget build(BuildContext context) {
    Duration startingHour = DateTime.fromMillisecondsSinceEpoch(
            ttData["startingTime"] ??
                DateTime(2000, 1, 1, 8).millisecondsSinceEpoch)
        .timeOfDay;
    // Build the list of schedules overlays
    List<TimeOverlay> plans = [];
    var durations = startingHour;
    if (ttData["timing"] == "") {
      ttData["timing"] = [];
    }
    int i = 0;

    //_events.clear(); // Resets the event to null so that it doesn't duplicate
    // However this causes issue, making time table undraggable [unmount]

    List<BasicEvent> eventsCopy = [];
    for (int index in ttData["timing"] ?? []) {
      var sched = ttData["events"]?[index]; // LIKELY THIS WHERE BUG COULD OCCUR
      if (sched == null) {
        continue;
      }
      i += 1;
      int t = int.tryParse(sched["duration"].toString()) ?? 0;
      Duration dur = Duration(hours: t ~/ 60, minutes: t % 60);
      eventsCopy.add(_DemoEvent(i - 1, index, durations, durations + dur));
      plans.add(
        TimeOverlay(
          start: durations,
          end: durations + dur,
          widget: Padding(
            padding: const EdgeInsets.all(1.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlueAccent.withOpacity(0.4),
                      Colors.lightBlue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    sched["name"].toString(),
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      durations += dur;
    }

    // Check if _events is same as _eventsCopy
    bool same = _events.length == eventsCopy.length;

    if (same) {
      for (int i = 0; i < eventsCopy.length; i++) {
        if (_events[i].id.toString() != eventsCopy[i].id.toString()) {
          same = false;
          debugPrint(
              "$i-${_events[i].toString()} IS NOT SAME !!!!!! AS ${eventsCopy[i].toString()}");
        }
      }
    } else {
      debugPrint(">>>>> _events is not as same length as eventsCopy");
    }
    if (!same) {
      _events.clear();
      for (BasicEvent x in eventsCopy) {
        _events.add(x);
      }
      debugPrint(">>> _events is not same, refreshing!");
    }

    overlays(context, date) => <TimeOverlay>[
          TimeOverlay(
            start: const Duration(hours: 0),
            end: const Duration(hours: 7),
            widget: const ColoredBox(color: Colors.black12),
            position: TimeOverlayPosition.inFrontOfEvents,
          ),
          for (var x in plans) x,
          TimeOverlay(
            start: const Duration(hours: 20),
            end: const Duration(hours: 24),
            widget: const ColoredBox(color: Colors.black12),
          ),
        ];

    bool isHovering = c.toString() != "[]";
    debugPrint("Is hovering on panel? $isHovering");

    return TimetableConfig<BasicEvent>(
      //key: Key(DateTime.now().toIso8601String()),
      timeController: tc,
      dateController: dc,

      eventBuilder: (context, event) => _buildPartDayEvent(event, context),
      eventProvider: eventProviderFromFixedList(
          _events), // THIS CAUSES THE UNMOUNT AND UNDRAGGABLE ISSUE WHEN CHANGED
      timeOverlayProvider: mergeTimeOverlayProviders([
        overlays,
        (context, date) => _draggedEvents
            .map(
              (it) =>
                  it.toTimeOverlay(
                      date: date,
                      widget: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent.withOpacity(0.4),
                                  Colors.red
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Moving - ${ttData["events"][int.tryParse(it.id.toString().split("-")[1])]["name"]}",
                                softWrap: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )) ??
                  TimeOverlay(
                      start: const Duration(),
                      end: const Duration(),
                      widget: const SizedBox()),
            )
            .toList()
      ]),
      callbacks: TimetableCallbacks(
        onDateTimeBackgroundTap: (dateTime) {
          debugPrint(_draggedEvents.toString());
          debugPrint(dateTime.toString());
        },
        // onWeekTap, onDateTap, onDateBackgroundTap, onDateTimeBackgroundTap, and
        // onMultiDateHeaderOverflowTap
      ),

      child: RecurringMultiDateTimetable<BasicEvent>(),
    );
  }
}
