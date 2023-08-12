import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/radioButton.dart';
import 'package:Project_Prism/ui/searchButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

Widget? cacheOfSecondPage;
Widget? cacheOfThirdPage;

class hallInfoUi extends StatefulWidget {
  @override
  State<hallInfoUi> createState() => _hallInfoUiState();
}

PageController pg = PageController();

class _hallInfoUiState extends State<hallInfoUi> {
  TextEditingController _text = TextEditingController();

  String _selectedBlock = "All";

  String _selectedFloor = "All";

  List<DocumentSnapshot>? hallData;

  List<String> getBlock() {
    if (hallData == null) return [];

    Map<String, bool> map = {};
    for (DocumentSnapshot x in hallData!) {
      map[x.get("block").toString()] = true;
    }
    return map.keys.toList();
  }

  List<String> getFloor() {
    if (hallData == null) return [];

    Map<String, bool> map = {};
    for (DocumentSnapshot x in hallData!) {
      map[x.get("floor").toString()] = true;
    }
    return map.keys.toList();
  }

  List<Map<String, dynamic>> hallDataProcess() {
    List<Map<String, dynamic>> output = [];

    for (DocumentSnapshot<Object?> x in hallData!) {
      if (x.id.endsWith("_raw") == false)
        output.add(x.data() as Map<String, dynamic>);
    }
    return output;
  }

  Future<void> refresh() async {
    global.Database!.addCollection("halls", "/halls");

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("/halls").get();
    hallData = querySnapshot.docs;
    debugPrint("${hallData.toString()} ");
    setState(() {});
  }

  @override
  void initState() {
    pg = PageController();
    super.initState();
    refresh();
  }

  LinearGradient _getGradientForStatus(String status) {
    switch (status.toLowerCase()) {
      case "free":
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 171, 226, 148),
            Color.fromARGB(255, 21, 231, 21)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "planned":
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 243, 211, 122),
            Color.fromARGB(255, 255, 140, 0)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "ongoing":
        return const LinearGradient(
          colors: [Color(0xFF6DA9D2), Color.fromARGB(255, 5, 123, 219)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        // If status doesn't match any of the above, use a default gradient
        return const LinearGradient(
          colors: [Colors.grey, Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return hallData == null
        ? const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SpinKitThreeBounce(
                color: Colors.blue, // set the color of the spinner
                size: 50.0, // set the size of the spinner
              ),
            ))
        : Scaffold(
            backgroundColor: Colors.transparent,
            body: PageView(
              controller: pg,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, right: 15, left: 15, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Adjust border radius as needed
                                          ),
                                          shadowColor: Colors.transparent,
                                          backgroundColor:
                                              Theme.of(context).focusColor,
                                          surfaceTintColor: Colors.transparent),
                                      onPressed: () {
                                        global.alert.quickAlert(
                                            context,
                                            GreenRadio(
                                              stringList: [
                                                "All",
                                                for (var x in getBlock()) x
                                              ],
                                              callback: (val) {
                                                debugPrint(
                                                    "Initial : $_selectedBlock | Changing to : $val");
                                                setState(() {
                                                  _selectedBlock = val;
                                                });
                                              },
                                              initalValue: _selectedBlock,
                                            ),
                                            action: null);
                                      },
                                      icon: Icon(Icons.business),
                                      label: Text(
                                        "Block or Building",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textSelectionTheme
                                                .selectionColor,
                                            fontSize: 12),
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Adjust border radius as needed
                                          ),
                                          shadowColor: Colors.transparent,
                                          backgroundColor:
                                              Theme.of(context).focusColor,
                                          surfaceTintColor: Colors.transparent),
                                      onPressed: () {
                                        global.alert.quickAlert(
                                            context,
                                            GreenRadio(
                                              stringList: [
                                                "All",
                                                for (String x in getFloor()) x
                                              ],
                                              callback: (val) {
                                                setState(() {
                                                  _selectedFloor = val;
                                                });
                                              },
                                              initalValue: _selectedFloor,
                                            ),
                                            action: null);
                                      },
                                      icon: Icon(Icons.layers_rounded),
                                      label: Text(
                                        "Floor",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textSelectionTheme
                                                .selectionColor,
                                            fontSize: 12),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 10,
                            child: AnimSearchBar(
                                color: Theme.of(context).focusColor,
                                closeSearchOnSuffixTap: true,
                                style: TextStyle(
                                    //fontSize: 12
                                    color: Theme.of(context)
                                        .textSelectionTheme
                                        .selectionColor,
                                    fontFamily: "Metropolis",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17),
                                rtl: true,
                                width: MediaQuery.of(context).size.width - 10,
                                textController: _text,
                                onSuffixTap: () {}),
                          )
                        ],
                      ),
                      ShaderMask(
                        shaderCallback: (Rect rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black
                            ],
                            stops: [0.001, 0.05, 0.8, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstOut,
                        child: SingleChildScrollView(
                          child: Column(
                              children: AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 300),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: widget,
                                        ),
                                      ),
                                  children: [
                                for (Map<String, dynamic> entry
                                    in hallDataProcess())
                                  if ((_selectedBlock == entry["block"] ||
                                          _selectedBlock == "All") &&
                                      (entry["floor"].toString() ==
                                              _selectedFloor ||
                                          _selectedFloor == "All"))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10,
                                          left: 10,
                                          top: 8.0,
                                          bottom: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            gradient: _getGradientForStatus(
                                                entry["status"]),
                                          ),
                                          child: ElevatedButton(
                                            clipBehavior: Clip.hardEdge,
                                            onPressed: () {
                                              setState(() {
                                                cacheOfSecondPage =
                                                    DisplayHallData(
                                                  hallData: entry,
                                                  fn: refresh,
                                                  callback: () {
                                                    pg.animateToPage(0,
                                                        duration: Duration(
                                                            milliseconds: 650),
                                                        curve:
                                                            Curves.easeOutExpo);
                                                  },
                                                );
                                              });
                                              pg.animateToPage(1,
                                                  duration: Duration(
                                                      milliseconds: 650),
                                                  curve: Curves.easeOutExpo);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Adjust border radius as needed
                                                ),
                                                shadowColor: Colors.transparent,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .focusColor,
                                                surfaceTintColor:
                                                    Colors.transparent),
                                            child: SizedBox(
                                              width: double.maxFinite,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0,
                                                    left: 8,
                                                    top: 10,
                                                    bottom: 10),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        global.textWidgetWithHeavyFont(
                                                            "${entry["status"]} - ${entry["block"]}" +
                                                                entry[
                                                                    "room_number"]),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          "Block ${entry["block"]} | Floor ${entry["floor"].toString()}",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "roboto",
                                                              color: Theme.of(
                                                                      context)
                                                                  .textSelectionTheme
                                                                  .selectionHandleColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              fontSize: 12),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            entry["type"]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "montserrat",
                                                                color: Theme.of(
                                                                        context)
                                                                    .textSelectionTheme
                                                                    .selectionHandleColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontSize: 12),
                                                          ),
                                                          SizedBox(
                                                            width: 60,
                                                            height: 30,
                                                            // child: FacePile(
                                                            //   faces: [
                                                            //     for (int x in [
                                                            //       1,
                                                            //       2,
                                                            //       3,
                                                            //       4
                                                            //     ])
                                                            //       FaceHolder(
                                                            //           avatar: NetworkImage(
                                                            //               "https://i.pravatar.cc/300?img=${x.toString()}"),
                                                            //           name:
                                                            //               "idk",
                                                            //           id: x
                                                            //               .toString())
                                                            //   ],
                                                            //   faceSize: 30,
                                                            //   facePercentOverlap:
                                                            //       .2,
                                                            //   borderColor: Colors
                                                            //       .transparent,
                                                            // ),
                                                          ),
                                                        ])
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                SizedBox(
                                  height: 30,
                                )
                              ])),
                        ),
                      ),
                    ],
                  ),
                ),
                cacheOfSecondPage ??
                    ElevatedButton(
                        onPressed: () {
                          pg.animateToPage(0,
                              duration: Duration(seconds: 1),
                              curve: Curves.easeOutExpo);
                        },
                        child: Text("click me")),
                cacheOfThirdPage ??
                    ElevatedButton(
                        onPressed: () {
                          pg.animateToPage(0,
                              duration: Duration(seconds: 1),
                              curve: Curves.easeOutExpo);
                        },
                        child: Text("click me")),
              ],
            ),
          );
  }
}

class DisplayHallData extends StatefulWidget {
  final Map<Object, dynamic> hallData;
  final Function fn;
  final Function()? callback;

  DisplayHallData(
      {Key? key, required this.hallData, this.callback, required this.fn})
      : super(key: key);

  @override
  State<DisplayHallData> createState() => _DisplayHallDataState();
}

class _DisplayHallDataState extends State<DisplayHallData> {
  @override
  Widget build(BuildContext context) {
    debugPrint(widget.hallData.toString());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(
            builder: (BuildContext context) {
              return Material(
                  color: Theme.of(context).focusColor.withOpacity(1),
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  child: FunctionRequirementForm(
                      hallData: widget.hallData,
                      existingShed: null,
                      fn: setState));
            },
          ));
        },
        child: Icon(
          Icons.event_note,
          color: Theme.of(context).textSelectionTheme.selectionColor,
        ),
        backgroundColor: Theme.of(context).focusColor.withOpacity(1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: global.textWidgetWithHeavyFont("Hall Details"),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textSelectionTheme.selectionColor),
          onPressed: () {
            widget.callback!();
            widget.fn();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 1200, // Set your desired maximum height here
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HallInfoCard(
                  roomNumber: widget.hallData['room_number'],
                  block: widget.hallData['block'],
                  floor: widget.hallData['floor'].toString(),
                  status: widget.hallData['status'],
                  seatCount: widget.hallData['seat_count'],
                  hallType: widget.hallData['type'],
                ),
                SizedBox(height: 24),
                Text(
                  'Schedules :',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .textSelectionTheme
                          .selectionHandleColor),
                ),
                SizedBox(height: 16),
                widget.hallData['status'] != "Free"
                    ? HallScheduleTimeline(
                        scheduleData: widget.hallData["schedule"],
                        hallData: widget.hallData,
                        fn: (Function f) {
                          setState(() {});
                          widget.fn();
                        })
                    : global.textWidgetWithHeavyFont("No Schedules So Far"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HallInfoCard extends StatelessWidget {
  final String roomNumber;
  final String block;
  final String floor;
  final String status;
  final int seatCount;
  final String hallType;

  HallInfoCard({
    required this.roomNumber,
    required this.block,
    required this.floor,
    required this.status,
    required this.seatCount,
    required this.hallType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).focusColor,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.room,
                  size: 30,
                  color: Colors.indigo,
                ),
                SizedBox(width: 8),
                Text(
                  'Room Number: $roomNumber',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textSelectionTheme.cursorColor),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.apartment,
                  size: 24,
                  color: Colors.grey,
                ),
                SizedBox(width: 8),
                global.textWidgetWithHeavyFont(
                  'Block: $block',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.layers,
                  size: 24,
                  color: Colors.grey,
                ),
                SizedBox(width: 8),
                global.textWidgetWithHeavyFont(
                  'Floor: $floor',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  status == 'Free'
                      ? Icons.check_circle
                      : (status == 'Planned' ? Icons.event : Icons.timer),
                  size: 24,
                  color: status == 'Free'
                      ? Colors.green
                      : (status == 'Planned' ? Colors.blue : Colors.orange),
                ),
                SizedBox(width: 8),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontSize: 18,
                    color: status == 'Free'
                        ? Colors.green
                        : (status == 'Planned' ? Colors.blue : Colors.orange),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.event_seat,
                  size: 24,
                  color: Colors.grey,
                ),
                SizedBox(width: 8),
                global.textWidgetWithHeavyFont(
                  'Seat Count: $seatCount',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.meeting_room,
                  size: 24,
                  color: Colors.grey,
                ),
                SizedBox(width: 8),
                global.textWidgetWithHeavyFont(
                  'Hall Type: $hallType',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HallScheduleTimeline extends StatefulWidget {
  final dynamic hallData;
  final List<dynamic> scheduleData;
  final Function fn;

  const HallScheduleTimeline(
      {Key? key,
      required this.hallData,
      required this.scheduleData,
      required this.fn})
      : super(key: key);

  @override
  State<HallScheduleTimeline> createState() => _HallScheduleTimelineState();
}

class _HallScheduleTimelineState extends State<HallScheduleTimeline> {
  DateTime parseDateTime(String input) {
    try {
      DateTime dateTime = DateTime.parse(input);
      return dateTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  String formatDateTime(DateTime dateTime) {
    String day = '${dateTime.day}'.padLeft(2, '0');
    String month = '${dateTime.month}'.padLeft(2, '0');
    String year = '${dateTime.year}';
    String hour = '${dateTime.hour}'.padLeft(2, '0');
    String minute = '${dateTime.minute}'.padLeft(2, '0');
    String period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$day/$month/$year $hour:$minute $period';
  }

  String formatTimeRemaining(int val) {
    Duration duration = Duration(milliseconds: val);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    return '$hours h $minutes m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < widget.scheduleData.length; index++)
          buildEventTile(index, context),
      ],
    );
  }

  Widget buildEventTile(int index, BuildContext context) {
    final data = widget.scheduleData[index];
    final initByPfp = data["initByPfp"] as String?;
    final initBy = data["initBy"] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Theme.of(context).focusColor,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: ExpansionTile(
            title: global.textWidgetWithHeavyFont(
                '${data["info"]["functionName"] ?? "NO REASON PROVIDED"}'),
            subtitle: global.textWidget_ns(
                'Starts : ${formatDateTime(parseDateTime(data["info"]["startingDate"]))} \nDuration : ${formatTimeRemaining(data["info"]["timeDuration"])}'),
            trailing: CircleAvatar(
              backgroundImage:
                  initByPfp != null ? NetworkImage(initByPfp) : null,
            ),
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 18, color: Colors.grey),
                            SizedBox(width: 8),
                            global.textDoubleSpanWiget(
                                'Initiated by: ', '${initBy ?? "Unknown"}'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 18, color: Colors.grey),
                            SizedBox(width: 8),
                            global.textDoubleSpanWiget('Chief Guest: ',
                                '${data["info"]["chiefGuestName"] ?? "None"}'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 18, color: Colors.grey),
                            SizedBox(width: 8),
                            global.textDoubleSpanWiget('Type of Training: ',
                                '${data["info"]["typeOfTraining"] ?? "None"}'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.people, size: 18, color: Colors.grey),
                            SizedBox(width: 8),
                            global.textDoubleSpanWiget('Number of Students: ',
                                '${data["info"]["numberOfStudents"] ?? "0"}'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).focusColor),
                            onPressed: () {
                              Navigator.push(context, CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return Material(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(1),
                                    surfaceTintColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    child: FunctionRequirementForm(
                                        hallData: widget.hallData,
                                        existingShed:
                                            widget.scheduleData[index],
                                        fn: widget.fn),
                                  );
                                },
                              ));
                            },
                            icon: Icon(Icons.edit),
                            label: global.textWidget_ns('Edit'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              dynamic backup = data;
                              (widget.hallData["schedule"] as List<dynamic>)
                                  .remove(data);
                              if (widget.hallData["schedule"].length == 0) {
                                widget.hallData["status"] = "Free";
                              }
                              var update = (await global.Database!.update(
                                  global.collectionMap["halls"]!,
                                  "${widget.hallData["block"]}${widget.hallData["floor"]}-${widget.hallData["room_number"]}",
                                  widget.hallData));

                              if (update.status == db_fetch_status.success) {
                                widget.fn(() {
                                  global.snackbarText(
                                      "Successfully deleted the event.");
                                });
                              } else {
                                (widget.hallData["schedule"] as List<dynamic>)
                                    .add(backup);
                                widget.hallData["status"] = "Planned";

                                global.snackbarText("Failed to delete");
                                debugPrint(update.data.toString());
                              }
                            },
                            icon: Icon(Icons.delete,
                                color: Theme.of(context)
                                    .textSelectionTheme
                                    .cursorColor),
                            label: Text(
                              'Delete',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textSelectionTheme
                                      .cursorColor),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors
                                  .redAccent, // Use red color for delete button
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class createShed extends StatefulWidget {
  final Map<Object, dynamic> hallData;
  final dynamic existingShed;
  final Function fn;

  const createShed(
      {super.key, required this.hallData, this.existingShed, required this.fn});

  @override
  State<createShed> createState() => _createShedState();
}

class _createShedState extends State<createShed> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now().add(const Duration(hours: 1));
  String reason = "";
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    if (widget.existingShed != null) {
      fromDate = ((widget.existingShed as Map<dynamic, dynamic>)["fromDate"]
              as Timestamp)
          .toDate();
      toDate = ((widget.existingShed as Map<dynamic, dynamic>)["toDate"]
              as Timestamp)
          .toDate();
      reason = widget.existingShed["reason"] ?? "NO REASON PROVIDED";
      _controller = TextEditingController(text: reason);
    }
    setState(() {});
    super.initState();
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fromDate),
    );

    if (picked != null) {
      setState(() {
        fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day,
            picked.hour, picked.minute);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate, // Set the first selectable date to fromDate
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(toDate),
    );

    if (picked != null) {
      DateTime selectedDateTime = DateTime(
        toDate.year,
        toDate.month,
        toDate.day,
        picked.hour,
        picked.minute,
      );

      if (selectedDateTime.isAfter(fromDate)) {
        // Check if selectedDateTime is after fromDate
        setState(() {
          toDate = selectedDateTime;
        });
      } else {
        global.snackbarText('Invalid time selection. [To time < From time]');
      }
    }
  }

  String formatTime(DateTime dateTime) {
    String hour = '${dateTime.hour}'.padLeft(2, '0');
    String minute = '${dateTime.minute}'.padLeft(2, '0');
    String period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  String formatDate(DateTime dateTime) {
    String day = '${dateTime.day}'.padLeft(2, '0');
    String month = '${dateTime.month}'.padLeft(2, '0');
    String year = '${dateTime.year}';

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<dynamic, dynamic> data = {};
          List<dynamic> list = widget.hallData["schedule"] ?? [];
          data["fromDate"] = Timestamp.fromDate(fromDate);
          data["toDate"] = Timestamp.fromDate(toDate);
          data["reason"] = _controller.text;
          data["initBy"] = global.account?.displayName;
          data["initByEmail"] = global.account?.email;
          data["initByPfp"] = global.account?.photoURL;
          if (widget.existingShed == null) {
            // Add a new plan to the hall data
            list.add(data);
          } else {
            // Update the existing hall data
            list.remove(widget.existingShed);
            list.add(data);
          }

          List<dynamic> prevList = widget.hallData["schedule"] ?? [];
          widget.hallData["schedule"] = list;
          widget.hallData["status"] = "Planned";
          // Update the hallData document.
          var update = (await global.Database!.update(
              global.collectionMap["halls"]!,
              "${widget.hallData["block"]}${widget.hallData["floor"]}-${widget.hallData["room_number"]}",
              widget.hallData));

          if (update.status == db_fetch_status.success) {
            Navigator.pop(context);
            global.snackbarText("Successfully updated the hall schedule list.");
            widget.fn(() {});
          } else {
            widget.hallData["schedule"] = prevList;
            global.snackbarText("Failed to update");
            debugPrint(update.data.toString());
          }
        },
        child: Icon(
          Icons.done,
          color: Theme.of(context).textSelectionTheme.selectionColor,
        ),
        backgroundColor: Theme.of(context).focusColor.withOpacity(1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: global.textWidgetWithHeavyFont('Schedule Management'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textSelectionTheme.selectionColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor),
                      SizedBox(width: 8),
                      global.textWidgetWithHeavyFont('From'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor),
                      SizedBox(width: 8),
                      global.textWidgetWithHeavyFont('To'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Card(
                      elevation: 0,
                      color: Theme.of(context).focusColor,
                      child: InkWell(
                        onTap: () => _selectFromDate(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: global.textWidgetWithHeavyFont(
                            formatDate(fromDate.toLocal()),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).focusColor,
                      child: InkWell(
                        onTap: () => _selectToDate(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: global.textWidgetWithHeavyFont(
                            formatDate(toDate.toLocal()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor),
                      SizedBox(width: 8),
                      global.textWidgetWithHeavyFont('From'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor),
                      SizedBox(width: 8),
                      global.textWidgetWithHeavyFont('To'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Card(
                      elevation: 0,
                      color: Theme.of(context).focusColor,
                      child: InkWell(
                        onTap: () => _selectFromTime(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: global.textWidgetWithHeavyFont(
                            formatTime(fromDate.toLocal()),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).focusColor,
                      child: InkWell(
                        onTap: () => _selectToTime(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: global.textWidgetWithHeavyFont(
                            formatTime(toDate.toLocal()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Reason for Scheduling',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                      color: Theme.of(context)
                          .textSelectionTheme
                          .selectionHandleColor),
                ),
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textSelectionTheme.selectionColor),
                onSubmitted: (a) {},
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class FunctionRequirementData {
  TextEditingController functionNameController = TextEditingController();
  DateTime startingDate = DateTime.now();
  Duration timeDuration = Duration(hours: 1);
  TextEditingController venueController = TextEditingController();
  TextEditingController typeOfTrainingController = TextEditingController();
  TextEditingController numberOfStudentsController = TextEditingController();
  TextEditingController chiefGuestNameController = TextEditingController();

  TextEditingController refreshmentForGuestController = TextEditingController();
  DateTime refreshmentTimeForGuest = DateTime.now();
  TextEditingController refreshmentForStudentsController =
      TextEditingController();
  DateTime refreshmentTimeForStudents = DateTime.now();
  TextEditingController paymentThroughController = TextEditingController();

  TextEditingController micRequiredController = TextEditingController();
  TextEditingController acRequiredController = TextEditingController();
  TextEditingController lcdProjectorRequiredController =
      TextEditingController();
  TextEditingController laptopRequiredController = TextEditingController();
  TextEditingController photographFacilityController = TextEditingController();

  TextEditingController mementoQuantityWorthController =
      TextEditingController();
  TextEditingController seatingArrangementController = TextEditingController();
  TextEditingController tableClothsController = TextEditingController();
  TextEditingController receptionItemController = TextEditingController();
  TextEditingController functionFormDateAndTimeController =
      TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      'functionName': functionNameController.text,
      'startingDate': startingDate.toIso8601String(),
      'timeDuration': timeDuration.inMilliseconds,
      'venue': venueController.text,
      'typeOfTraining': typeOfTrainingController.text,
      'numberOfStudents': numberOfStudentsController.text,
      'chiefGuestName': chiefGuestNameController.text,
      'refreshmentForGuest': refreshmentForGuestController.text,
      'refreshmentTimeForGuest': refreshmentTimeForGuest.toIso8601String(),
      'refreshmentForStudents': refreshmentForStudentsController.text,
      'refreshmentTimeForStudents':
          refreshmentTimeForStudents.toIso8601String(),
      'paymentThrough': paymentThroughController.text,
      'micRequired': micRequiredController.text,
      'acRequired': acRequiredController.text,
      'lcdProjectorRequired': lcdProjectorRequiredController.text,
      'laptopRequired': laptopRequiredController.text,
      'photographFacility': photographFacilityController.text,
      'mementoQuantityWorth': mementoQuantityWorthController.text,
      'seatingArrangement': seatingArrangementController.text,
      'tableCloths': tableClothsController.text,
      'receptionItem': receptionItemController.text,
      'functionFormDateAndTime': functionFormDateAndTimeController.text,
    };
  }

  static FunctionRequirementData fromJson(Map<String, dynamic> json) {
    var data = FunctionRequirementData();
    data.functionNameController.text = json['functionName'];
    data.startingDate = DateTime.parse(json['startingDate']);
    data.timeDuration = Duration(milliseconds: json['timeDuration']);
    data.venueController.text = json['venue'];
    data.typeOfTrainingController.text = json['typeOfTraining'];
    data.numberOfStudentsController.text = json['numberOfStudents'];
    data.chiefGuestNameController.text = json['chiefGuestName'];
    data.refreshmentForGuestController.text = json['refreshmentForGuest'];
    data.refreshmentTimeForGuest =
        DateTime.parse(json['refreshmentTimeForGuest']);
    data.refreshmentForStudentsController.text = json['refreshmentForStudents'];
    data.refreshmentTimeForStudents =
        DateTime.parse(json['refreshmentTimeForStudents']);
    data.paymentThroughController.text = json['paymentThrough'];
    data.micRequiredController.text = json['micRequired'];
    data.acRequiredController.text = json['acRequired'];
    data.lcdProjectorRequiredController.text = json['lcdProjectorRequired'];
    data.laptopRequiredController.text = json['laptopRequired'];
    data.photographFacilityController.text = json['photographFacility'];
    data.mementoQuantityWorthController.text = json['mementoQuantityWorth'];
    data.seatingArrangementController.text = json['seatingArrangement'];
    data.tableClothsController.text = json['tableCloths'];
    data.receptionItemController.text = json['receptionItem'];
    data.functionFormDateAndTimeController.text =
        json['functionFormDateAndTime'];
    return data;
  }
}

class FunctionRequirementForm extends StatefulWidget {
  final Map<Object, dynamic> hallData;
  final dynamic existingShed;
  final Function fn;

  const FunctionRequirementForm(
      {super.key, required this.hallData, this.existingShed, required this.fn});
  _FunctionRequirementFormState createState() =>
      _FunctionRequirementFormState();
}

class _FunctionRequirementFormState extends State<FunctionRequirementForm> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  FunctionRequirementData formData = FunctionRequirementData();

  @override
  void initState() {
    if (widget.existingShed != null) {
      formData = FunctionRequirementData.fromJson(widget.existingShed["info"]);
    }
    super.initState();
  }

  void nextPage() {
    if (_currentPage < 4 - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Handle submit action here
      // For example, you can call a function to submit the form data
      submitFormData();
    }
  }

  void submitFormData() async {
    Map<dynamic, dynamic> data = {};
    List<dynamic> list = widget.hallData["schedule"] ?? [];
    data["initBy"] = global.account?.displayName;
    data["initByEmail"] = global.account?.email;
    data["initByPfp"] = global.account?.photoURL;
    data["info"] = formData.toJson();
    if (widget.existingShed == null) {
      // Add a new plan to the hall data
      list.add(data);
    } else {
      // Update the existing hall data
      list.remove(widget.existingShed);
      list.add(data);
    }

    List<dynamic> prevList = widget.hallData["schedule"] ?? [];
    widget.hallData["schedule"] = list;
    widget.hallData["status"] = "Planned";
    // Update the hallData document.
    var update = (await global.Database!.update(
        global.collectionMap["halls"]!,
        "${widget.hallData["block"]}${widget.hallData["floor"]}-${widget.hallData["room_number"]}",
        widget.hallData));

    if (update.status == db_fetch_status.success) {
      Navigator.pop(context);
      global.snackbarText("Successfully updated the hall schedule list.");
      widget.fn(() {});
    } else {
      widget.hallData["schedule"] = prevList;
      global.snackbarText("Failed to update");
      debugPrint(update.data.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Function Requirement Form'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    DepartmentPage(
                      formData: formData,
                      onDataChanged: (data) {
                        setState(() {
                          formData = data;
                        });
                      },
                    ),
                    FacilitiesRequirementPage(
                      formData: formData,
                      onDataChanged: (data) {
                        setState(() {
                          formData = data;
                        });
                      },
                    ),
                    PowerSystemCameraPage(
                      formData: formData,
                      onDataChanged: (data) {
                        setState(() {
                          formData = data;
                        });
                      },
                    ),
                    MementoSeatingReceptionPage(
                      formData: formData,
                      onDataChanged: (data) {
                        setState(() {
                          formData = data;
                        });
                      },
                    )
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    color: Colors.grey[100],
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.business, 'Department', 0),
                        _buildNavItem(Icons.dining_outlined, 'Refreshments', 1),
                        _buildNavItem(Icons.power, 'Power / Camera', 2),
                        _buildNavItem(
                            Icons.card_giftcard, 'Memento / Seating', 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: nextPage,
        label: Text(
          _currentPage < 4 - 1 ? 'Next' : 'Submit',
          style: TextStyle(fontSize: 16),
        ),
        icon: Icon(
          _currentPage < 4 - 1 ? Icons.arrow_forward : Icons.check,
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentPage == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.5,
        duration: Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.black,
              ),
              if (isActive) SizedBox(width: 8),
              if (isActive)
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DepartmentPage extends StatefulWidget {
  final FunctionRequirementData formData;
  final ValueChanged<FunctionRequirementData> onDataChanged;
  DepartmentPage({required this.formData, required this.onDataChanged});
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  // Color picker state
  Color currentColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.0),
          ListTile(
            leading: Icon(Icons.check_circle),
            title: TextFormField(
              controller: widget.formData.functionNameController,
              decoration: InputDecoration(
                labelText: 'Name of the Function',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ListTile(
                  leading: Icon(Icons.calendar_today),
                  subtitle: global.textWidget("Starting date"),
                  title: InkWell(
                    onTap: () => _selectFromDate(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: global.textWidgetWithHeavyFont(
                        formatDate(widget.formData.startingDate.toLocal()),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.access_time),
                  subtitle: global.textWidget("Starting time"),
                  title: InkWell(
                    onTap: () => _selectFromTime(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: global.textWidgetWithHeavyFont(
                        formatTime(widget.formData.startingDate.toLocal()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            subtitle: global.textWidget("Time duration"),
            title: InkWell(
              onTap: () {
                _showTimePicker(context);
              },
              child: Text(
                formatDuration(widget.formData.timeDuration),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.location_on),
          //   title: TextFormField(
          //     controller: widget.formData.venueController,
          //     decoration: InputDecoration(
          //       labelText: 'Venue',
          //       border: OutlineInputBorder(),
          //     ),
          //   ),
          // ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.school),
            title: TextFormField(
              controller: widget.formData.typeOfTrainingController,
              decoration: InputDecoration(
                labelText: 'Type of Training',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the type of training';
                }
                return null;
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: TextFormField(
              controller: widget.formData.numberOfStudentsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Students',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of students';
                }
                // Add additional validation for numeric values if needed
                return null;
              },
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.person),
            title: TextFormField(
              controller: widget.formData.chiefGuestNameController,
              decoration: InputDecoration(
                labelText: 'Name of Chief Guest with designation',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    Duration? pickedDuration = await showCupertinoModalPopup<Duration>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm, // Hours and Minutes mode
            onTimerDurationChanged: (Duration duration) {
              setState(() {
                widget.formData.timeDuration = duration;
              });
            },
          ),
        );
      },
    );
    if (pickedDuration != null) {
      setState(() {
        widget.formData.timeDuration = pickedDuration;
      });
    }
  }

  String formatDuration(Duration duration) {
    String hours = '${duration.inHours}';
    String minutes = '${duration.inMinutes.remainder(60)}';

    return '$hours hours $minutes minutes';
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.formData.startingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != widget.formData.startingDate) {
      setState(() {
        widget.formData.startingDate = picked;
      });
    }
  }

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.formData.startingDate),
    );

    if (picked != null) {
      setState(() {
        widget.formData.startingDate = DateTime(
            widget.formData.startingDate.year,
            widget.formData.startingDate.month,
            widget.formData.startingDate.day,
            picked.hour,
            picked.minute);
      });
    }
  }

  String formatTime(DateTime dateTime) {
    String hour = '${dateTime.hour}'.padLeft(2, '0');
    String minute = '${dateTime.minute}'.padLeft(2, '0');
    String period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  String formatDate(DateTime dateTime) {
    String day = '${dateTime.day}'.padLeft(2, '0');
    String month = '${dateTime.month}'.padLeft(2, '0');
    String year = '${dateTime.year % 100}';

    return '$day/$month/$year';
  }
}

class FacilitiesRequirementPage extends StatefulWidget {
  final FunctionRequirementData formData;
  final ValueChanged<FunctionRequirementData> onDataChanged;
  FacilitiesRequirementPage(
      {required this.formData, required this.onDataChanged});
  State<FacilitiesRequirementPage> createState() =>
      _FacilitiesRequirementPageState();
}

class _FacilitiesRequirementPageState extends State<FacilitiesRequirementPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.0),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildFormField(
                  controller: widget.formData.refreshmentForGuestController,
                  label: 'Guest',
                  subtitle: "Example : Tea 2, coffee 1",
                  icon: Icons.person,
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.access_time),
                  subtitle: global.textWidget("Refreshment time"),
                  title: InkWell(
                    onTap: () => _selectFromTime(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: global.textWidgetWithHeavyFont(
                        formatTime(
                            widget.formData.refreshmentTimeForGuest.toLocal()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildFormField(
                  controller: widget.formData.refreshmentForStudentsController,
                  label: 'Students',
                  subtitle: "Example : Tea 2, coffee 1",
                  icon: Icons.class_,
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.access_time),
                  subtitle: global.textWidget("Refreshment time"),
                  title: InkWell(
                    onTap: () => _selectFromStudentTime(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: global.textWidgetWithHeavyFont(
                        formatTime(widget.formData.refreshmentTimeForStudents
                            .toLocal()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildFormField(
            controller: widget.formData.paymentThroughController,
            label: 'Payment Through',
            icon: Icons.payment,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      {TextEditingController? controller,
      String? label,
      IconData? icon,
      String subtitle = ""}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
      subtitle: subtitle != "" ? global.textWidget(subtitle) : null,
      title: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
      leading: Icon(icon),
    );
  }

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(widget.formData.refreshmentTimeForGuest),
    );

    if (picked != null) {
      setState(() {
        widget.formData.refreshmentTimeForGuest = DateTime(
            widget.formData.refreshmentTimeForGuest.year,
            widget.formData.refreshmentTimeForGuest.month,
            widget.formData.refreshmentTimeForGuest.day,
            picked.hour,
            picked.minute);
      });
    }
  }

  Future<void> _selectFromStudentTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(widget.formData.refreshmentTimeForStudents),
    );

    if (picked != null) {
      setState(() {
        widget.formData.refreshmentTimeForStudents = DateTime(
            widget.formData.refreshmentTimeForStudents.year,
            widget.formData.refreshmentTimeForStudents.month,
            widget.formData.refreshmentTimeForStudents.day,
            picked.hour,
            picked.minute);
      });
    }
  }

  String formatTime(DateTime dateTime) {
    String hour = '${dateTime.hour}'.padLeft(2, '0');
    String minute = '${dateTime.minute}'.padLeft(2, '0');
    String period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }
}

class PowerSystemCameraPage extends StatelessWidget {
  final FunctionRequirementData formData;
  final ValueChanged<FunctionRequirementData> onDataChanged;
  PowerSystemCameraPage({required this.formData, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.0),
          _buildFormField(
            controller: formData.micRequiredController,
            label: 'Microphone',
            icon: Icons.mic,
          ),
          _buildFormField(
            controller: formData.acRequiredController,
            label: 'A/C requirement',
            icon: Icons.ac_unit,
          ),
          _buildFormField(
            controller: formData.lcdProjectorRequiredController,
            label: 'LCD projector required number',
            icon: Icons.tv,
          ),
          _buildFormField(
            controller: formData.laptopRequiredController,
            label: 'Laptop',
            icon: Icons.laptop,
          ),
          _buildFormField(
            controller: formData.photographFacilityController,
            label: 'Photograph Facility',
            icon: Icons.camera_alt,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      {TextEditingController? controller,
      String? label,
      IconData? icon,
      String subtitle = ""}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
      subtitle: subtitle != "" ? global.textWidget(subtitle) : null,
      title: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
      leading: Icon(icon),
    );
  }
}

class MementoSeatingReceptionPage extends StatelessWidget {
  final FunctionRequirementData formData;
  final ValueChanged<FunctionRequirementData> onDataChanged;
  MementoSeatingReceptionPage(
      {required this.formData, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.0),
          _buildFormField(
            controller: formData.mementoQuantityWorthController,
            label: 'Memento / Honorarium for Chief Guest [quantity and worth]',
            icon: Icons.star,
          ),
          _buildFormField(
            controller: formData.seatingArrangementController,
            label: 'No of seating arrangement [dias, audience]',
            icon: Icons.event_seat,
          ),
          _buildFormField(
            controller: formData.tableClothsController,
            label: 'No. of table cloths',
            icon: Icons.table_chart,
          ),
          _buildFormField(
            controller: formData.receptionItemController,
            label: 'Reception item required',
            icon: Icons.receipt,
          ),
          _buildFormField(
            controller: formData.functionFormDateAndTimeController,
            label: 'Function Form Submitted Date and Time',
            icon: Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      {TextEditingController? controller,
      String? label,
      IconData? icon,
      String subtitle = ""}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
      subtitle: subtitle != "" ? global.textWidget(subtitle) : null,
      title: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
      leading: Icon(icon),
    );
  }
}



  //   return Scaffold(
  //     backgroundColor: Colors.transparent,
  //     appBar: AppBar(
  //       backgroundColor: Colors.transparent,
  //       leading: IconButton(
  //         icon: Icon(Icons.arrow_back,
  //             color: Theme.of(context).textSelectionTheme.selectionColor),
  //         onPressed: () => (widget.callback ?? () {})(),
  //       ),
  //       title: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             widget.hallData["code"],
  //             style: TextStyle(
  //                 fontFamily: "montserrat",
  //                 color:
  //                     Theme.of(context).textSelectionTheme.selectionHandleColor,
  //                 fontWeight: FontWeight.w800,
  //                 fontSize: 14),
  //           ),
  //           SizedBox(width: 5),
  //           Text(
  //             widget.hallData["title"],
  //             style: TextStyle(
  //                 fontFamily: "montserrat",
  //                 color:
  //                     Theme.of(context).textSelectionTheme.selectionHandleColor,
  //                 fontWeight: FontWeight.w400,
  //                 fontSize: 12),
  //           )
  //         ],
  //       ),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(12.0),
  //       child: SingleChildScrollView(
  //         child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: AnimationConfiguration.toStaggeredList(
  //               duration: const Duration(milliseconds: 200),
  //               childAnimationBuilder: (widget) => SlideAnimation(
  //                 verticalOffset: 50.0,
  //                 child: FadeInAnimation(
  //                   child: widget,
  //                 ),
  //               ),
  //               children: [
  //                 Row(
  //                   mainAxisSize: MainAxisSize.max,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.push(context, HeroDialogRoute(
  //                           builder: (BuildContext context) {
  //                             return Center(
  //                                 child: promptHallDesc(
  //                                     widget.hallData, context));
  //                           },
  //                         ));
  //                       },
  //                       child: Hero(
  //                         tag: "HallDesc",
  //                         child: Material(
  //                             color: Theme.of(context).focusColor,
  //                             shadowColor: Colors.transparent,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius:
  //                                   BorderRadius.all(Radius.circular(15)),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(10.0),
  //                               child: Text(
  //                                 "About hall",
  //                                 style: TextStyle(
  //                                     color: Theme.of(context)
  //                                         .textSelectionTheme
  //                                         .selectionHandleColor,
  //                                     fontFamily: "lato"),
  //                               ),
  //                             )),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       width: 120,
  //                       child: FacePile(
  //                         faces: [
  //                           for (int x in [1, 2, 3, 4])
  //                             FaceHolder(
  //                                 avatar: NetworkImage(
  //                                     "https://i.pravatar.cc/300?img=${x.toString()}"),
  //                                 name: "idk",
  //                                 id: x.toString())
  //                         ],
  //                         faceSize: 30,
  //                         facePercentOverlap: .2,
  //                         borderColor: Colors.transparent,
  //                       ),
  //                     ),
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.push(context, HeroDialogRoute(
  //                           builder: (BuildContext context) {
  //                             return Center(
  //                                 child: promptLTPC(
  //                                     widget.hallData["LTPC"], context));
  //                           },
  //                         ));
  //                       },
  //                       child: Hero(
  //                         tag: "LTPC",
  //                         child: Material(
  //                             color: Theme.of(context).focusColor,
  //                             shadowColor: Colors.transparent,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius:
  //                                   BorderRadius.all(Radius.circular(8)),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(10.0),
  //                               child: Text(
  //                                 "L \tT \tP \tC\n${widget.hallData["LTPC"].join(" \t")}",
  //                                 style: TextStyle(
  //                                     color: Theme.of(context)
  //                                         .textSelectionTheme
  //                                         .selectionHandleColor,
  //                                     fontFamily: "lato"),
  //                               ),
  //                             )),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //                 SizedBox(height: 30),
  //                 CustomExpansionWidget(
  //                     header: "Hall objectives",
  //                     body: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         for (String x in widget.hallData["objectives"])
  //                           global.textWidget(x + "\n")
  //                       ],
  //                     )),
  //                 CustomExpansionWidget(
  //                     header: "Hall outcomes",
  //                     body: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         for (String x in widget.hallData["outcomes"])
  //                           global.textWidget(x + "\n")
  //                       ],
  //                     )),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 for (int x in List.generate(
  //                     widget.hallData["syllabus_topic"].length,
  //                     (index) => index))
  //                   CustomExpansionWidget(
  //                       header: widget.hallData["syllabus_topic"][x] +
  //                           "\t\t( ${widget.hallData["syllabus_credits"][x].toString()} )",
  //                       body: BulletPoints(
  //                         widget.hallData["syllabus_subtopic"][x].split(";"),
  //                         TextStyle(
  //                             color: Theme.of(context)
  //                                 .textSelectionTheme
  //                                 .selectionColor,
  //                             fontSize: 12),
  //                       )),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 CustomExpansionWidget(
  //                     header: "Textbook",
  //                     body: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         for (String x in widget.hallData["textbook"])
  //                           global.textWidget(x + "\n")
  //                       ],
  //                     )),
  //                 CustomExpansionWidget(
  //                     header: "Reference book",
  //                     body: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         for (String x in widget.hallData["reference"])
  //                           global.textWidget(x + "\n")
  //                       ],
  //                     )),
  //                 SizedBox(height: 30),
  //                 CustomExpansionWidget(
  //                     header: "Materials",
  //                     body: global.textWidget("None so far.")),
  //                 SizedBox(
  //                   height: 50,
  //                 )
  //               ],
  //             )),
  //       ),
  //     ),
  //   );
  // }
// }

// Widget promptLTPC(List<dynamic> list, BuildContext context) {
//   return BackdropFilter(
//     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//     child: Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//       ),
//       clipBehavior: Clip.antiAlias,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       child: SizedBox(
//         width: double.infinity,
//         height: 650,
//         child: Hero(
//             tag: "LTPC",
//             child: Material(
//                 clipBehavior: Clip.hardEdge,
//                 color: Theme.of(context).focusColor,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: BulletPoints(
//                       const [
//                         "Lecture Tutorial Practical Credit [Period]\n",
//                         "Lecture: It is something what you get in your classroom. Mostly comprised of theory and might have relevancy with the real world. The scenario can be hypothetical(Imaginary) or may be real sometimes. When you attain a lecture, you com to know the concept only and have to relate by yourself with the reality or imagination.\n",
//                         "Tutorial: These are the experimentation of the Lectures. Whatever is taught to your in your lectures, the tutorial comprised of its implementation. You will like the tutorial always over lectures, as they will tell you what the real implementation is.\n",
//                         "Practical: This is something complicated. Many a times what you learn through Lectures or Tutorials are helpful in your practicals. But most o the times, your experience earned through your lectures or tutorials is what required as the scenario can be way far different from the reality and you can come across many obstructions which you never had seen during your lectures or tutorials.\n",
//                         "Credit: The points that you earned out of the everything you do, if there is any scoring. These are just points that help you in proving your credibility and excellence in a particular stream.\n"
//                       ],
//                       TextStyle(
//                           color: Theme.of(context)
//                               .textSelectionTheme
//                               .selectionColor,
//                           fontFamily: "Open Sans")),
//                 ))),
//       ),
//     ),
//   );
// }

// Widget promptHallDesc(var hallData, BuildContext context) {
//   return BackdropFilter(
//     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//     child: Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//       ),
//       clipBehavior: Clip.antiAlias,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       child: Hero(
//           tag: "HallDesc",
//           child: Material(
//               clipBehavior: Clip.hardEdge,
//               color: Theme.of(context).focusColor,
//               shadowColor: Colors.transparent,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(12)),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Text(hallData["description"],
//                     style: TextStyle(
//                         color:
//                             Theme.of(context).textSelectionTheme.selectionColor,
//                         fontFamily: "Open Sans")),
//               ))),
//     ),
//   );
// }
