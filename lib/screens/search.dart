import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/sub_screen/profileInfo.dart';
import 'package:Project_Prism/ui/dragUi.dart';
import 'package:Project_Prism/ui/searchButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:url_launcher/url_launcher.dart';

Color bgColor = Colors.transparent;
bool initialRefresh = false;
TextEditingController textController = TextEditingController();

class search extends StatefulWidget {
  const search({super.key});

  @override
  State<search> createState() => _searchState();
}

List<Map<String, dynamic>> acc = [];
List<Map<String, dynamic>> searchSorted = [];
bool started = false;

class _searchState extends State<search> {
  Future<int> refresh() async {
    debugPrint("refreshing...");
    var entries = await global.Database!.firestore.collection("/acc").get();
    Map<String, dynamic> entryOfAcc = {};
    for (var i in entries.docs) {
      var data = i.data();
      entryOfAcc[data["email"].toString()] = data;
    }
    global.accountsInDatabase = entryOfAcc;
    acc = [];
    for (var x in entryOfAcc.entries) {
      if (x.value["phoneNo"] != null) {
        if (x.value["isStudent"] == true) {
          acc.add({
            "avatar": x.value["avatar"],
            "name":
                "${x.value["firstName"]} ${x.value["lastName"]}${x.key == global.account!.email ? " (You)" : ""}",
            "nextToName": "Student",
            "email": x.key,
            "title":
                "${x.value["branchCode"].toString().toUpperCase()}-${x.value["section"].toString().toUpperCase()} ${x.value["year"].toString().toUpperCase()} Year",
            "isStudent": true
          });
        } else {
          debugPrint(x.key.toString());
          acc.add({
            "avatar": x.value["avatar"],
            "name":
                "${x.value["title"]} ${x.value["firstName"]} ${x.value["lastName"]}${x.key == global.account!.email ? " (You)" : ""}",
            "nextToName": x.value["position"],
            "email": x.key,
            "title":
                "${x.value["designation"]}     [${x.value["departmentStaff"]}]",
            "isStudent": false,
          });
        }
      }
    }

    List<Map<String, dynamic>> accounts = [];
    for (var x in acc) {
      if (accounts.contains(x) == false) {
        accounts.add(x);
      }
    }

    accounts = List.from(accounts);
    searchSorted = accounts;
    setState(() {
      started = true;
    });
    initialRefresh = true;
    debugPrint("Done refreshing /acc list for search route.");
    return 1;
  }

  @override
  void initState() {
    if (initialRefresh == false || global.accountsInDatabase.isEmpty) {
      refresh();
    }

    super.initState();
    bgColor = Theme.of(global.rootCTX!).focusColor;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building searchbar screen");
    Widget searchBar = Material(
      color: Colors.transparent,
      child: AnimSearchBar(
        width: 300,
        //rtl: global.dragUiPosition != null ? (global.dragUiPosition!.dx > MediaQuery.of(context).size.width/2 ? true : false) : false,
        rtl: true,
        textController: textController,
        onSuffixTap: () {
          textController.clear();
        },
        color: Theme.of(context).focusColor,
        closeSearchOnSuffixTap: true,
        style: TextStyle(
            //fontSize: 12
            color: Theme.of(context).textSelectionTheme.selectionColor,
            fontFamily: "Metropolis",
            fontWeight: FontWeight.normal,
            fontSize: 17),
        helpText: "Tap here to search!",
        onInputChanged: (value) {
          if (value == "" || value == null) {
            searchSorted = acc;
          } else {
            List newList = [];
            Map<int, List> matches = {};

            matches = {
              1: [],
              2: [],
              3: [],
              4: [],
              5: [],
              6: [],
              7: [],
              8: [],
              9: [],
              10: []
            };
            for (var x in acc) {
              double rating = StringSimilarity.compareTwoStrings(
                  value.toString().toLowerCase(),
                  x["name"].toString().toLowerCase());
              int matching = (rating * 10).toInt();

              if (matching >= 1) {
                matches[matching]?.add(x);
              }
            }
            for (int i = 10; i >= 1; i--) {
              for (var x in matches[i]!) {
                newList.add(x);
              }
            }

            matches = {
              1: [],
              2: [],
              3: [],
              4: [],
              5: [],
              6: [],
              7: [],
              8: [],
              9: [],
              10: []
            };
            for (var x in acc) {
              double rating = StringSimilarity.compareTwoStrings(
                  value.toString().toLowerCase(),
                  x["title"].toString().toLowerCase());
              int matching = (rating * 10).toInt();

              if (matching >= 1) {
                matches[matching]?.add(x);
              }
            }
            for (int i = 10; i >= 1; i--) {
              for (var x in matches[i]!) {
                if (newList.contains(x) == false) {
                  newList.add(x);
                }
              }
            }

            searchSorted = List.from(newList);
            newList.clear();
          }

          setState(() {});
        },
      ),
    );

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      color: searchSorted.isEmpty && started
          ? Colors.red.withOpacity(0.5)
          : bgColor,
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 60),
      child: Stack(
        children: [
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
                stops: [0.001, 0.1, 0.8, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: SingleChildScrollView(
              child: AnimationLimiter(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await refresh();
                  },
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          for (Map x in searchSorted)
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Card(
                                surfaceTintColor: Colors.transparent,
                                color: Theme.of(context).focusColor,
                                elevation: 0,
                                clipBehavior: Clip.antiAlias,
                                child: Slidable(
                                  startActionPane: ActionPane(
                                    extentRatio: 0.25,
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (a) {
                                          launchUrl(Uri(
                                              scheme: 'tel',
                                              path:
                                                  '+91${global.accountsInDatabase[x["email"]]["phoneNo"].toString()}'));
                                        },
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        icon: Icons.phone,
                                        label: 'Call',
                                      ),
                                    ],
                                  ),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 0.25,
                                    children: [
                                      SlidableAction(
                                        onPressed: (a) {
                                          launchUrl(Uri(
                                              scheme: 'tel',
                                              path:
                                                  '+91${global.accountsInDatabase[x["email"]]["phoneNo"].toString()}'));
                                        },
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        icon: Icons.phone,
                                        label: 'Call',
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      promptProfileInfo(global
                                          .accountsInDatabase[x["email"]]);
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
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                    width: 1.1,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                width: 50,
                                                height: 50,
                                                child: ClipOval(
                                                  child: x["avatar"] != null
                                                      ? FadeInImage.assetNetwork(
                                                          placeholder:
                                                              "asset/images/loading.gif",
                                                          image: x["avatar"])
                                                      : Icon(Icons.person,
                                                          color: Theme.of(
                                                                  context)
                                                              .textSelectionTheme
                                                              .selectionColor!),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  global.textDoubleSpanWiget(
                                                      "${x["name"]}   ",
                                                      x["nextToName"]),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  global.textWidget(
                                                      x["title"] ?? "")
                                                ],
                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 70,
                          ),
                        ],
                      )),
                ),
              ),
            ),
          ),
          StatefulDragArea(
            callback: () {
              searchSorted = acc;
              setState(() {});
            },
            child: searchBar,
          )
        ],
      ),
    );
  }
}
