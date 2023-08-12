import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/radioButton.dart';
import 'package:Project_Prism/ui/searchButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HallRemoveUi extends StatefulWidget {
  const HallRemoveUi({super.key});

  @override
  State<HallRemoveUi> createState() => _HallRemoveUiState();
}

class _HallRemoveUiState extends State<HallRemoveUi> {
  final TextEditingController _text = TextEditingController();

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
      if (x.id.endsWith("_raw") == false) {
        output.add(x.data() as Map<String, dynamic>);
      }
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
        return const LinearGradient(
          colors: [Colors.grey, Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  void ask(String id) async {
    global.alert.quickAlert(
        context,
        global
            .textWidget("Are you sure that you want to remove this hall data?"),
        action: [
          FloatingActionButton(
              child: Text("Yes"),
              mini: true,
              onPressed: () async {
                debugPrint("Deleting $id hall.");
                db_fetch_return a = await global.Database!.remove(
                    global.Database!.addCollection("halls", "/halls"), id);

                await refresh();

                if (a.status == db_fetch_status.success) {
                  global.snackbarText("Successfully removed");
                } else {
                  global.snackbarText("Failed to remove");
                  debugPrint(a.data.toString());
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }),
          FloatingActionButton(
              child: Text("No"),
              mini: true,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return hallData == null
        ? const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SpinKitThreeBounce(
                color: Colors.blue,
                size: 50.0,
              ),
            ))
        : Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
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
                                  icon: const Icon(Icons.business),
                                  label: Text(
                                    "Block or Building",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textSelectionTheme
                                            .selectionColor,
                                        fontSize: 12),
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                  icon: const Icon(Icons.layers_rounded),
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
                              childAnimationBuilder: (widget) => SlideAnimation(
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
                                      right: 10, left: 10, top: 8.0, bottom: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: _getGradientForStatus(
                                            entry["status"]),
                                      ),
                                      child: ElevatedButton(
                                        clipBehavior: Clip.hardEdge,
                                        onPressed: () {
                                          setState(() {
                                            ask("${entry["block"]}${entry["floor"]}-${entry["room_number"]}");
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            shadowColor: Colors.transparent,
                                            backgroundColor:
                                                Theme.of(context).focusColor,
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
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    global.textWidgetWithHeavyFont(
                                                        "${entry["status"]} - ${entry["block"]}${entry["room_number"]}"),
                                                    const SizedBox(width: 15),
                                                    Text(
                                                      "Block ${entry["block"]} | Floor ${entry["floor"].toString()}",
                                                      style: TextStyle(
                                                          fontFamily: "roboto",
                                                          color: Theme.of(
                                                                  context)
                                                              .textSelectionTheme
                                                              .selectionHandleColor,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 12),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
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
                                                                FontWeight.w300,
                                                            fontSize: 12),
                                                      ),
                                                      const SizedBox(
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
                            const SizedBox(
                              height: 30,
                            )
                          ])),
                    ),
                  ),
                ],
              ),
            ));
  }
}
