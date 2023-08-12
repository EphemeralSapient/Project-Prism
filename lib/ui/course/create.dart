import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class courseCreateUi extends StatefulWidget {
  @override
  _courseCreateUiState createState() => _courseCreateUiState();
}

class _courseCreateUiState extends State<courseCreateUi> {
  TextEditingController _courseDataController = TextEditingController();

  String? year;
  int? sem;
  List<String> departments = [];
  Map<String, bool> chosen = {};
  bool loaded = false;

  var paddingEdgeVar = EdgeInsets.all(8.0);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      var list =
          await global.Database!.firestore.collection("/department").get();
      var departList = list.docs.toList();
      for (var x in departList) {
        chosen[x.id] = false;
      }
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: global.textWidgetWithHeavyFont('Course Form'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).textSelectionTheme.selectionColor),
            onPressed: () {
              global.switchToPrimaryUi();
            },
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 16.0, left: 16, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              global.textWidget(
                  "[!] Note : Currently course addition supports standard format for colleges only."),
              SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: DropdownButton(
                        dropdownColor:
                            Theme.of(context).focusColor.withOpacity(0.8),
                        hint: global.textWidget("Select the year"),
                        isExpanded: true,
                        value: year,
                        items: [
                          for (int i in List.generate(4, (index) => index + 1))
                            DropdownMenuItem(
                              value: global
                                  .convertToRoman(i.toString())
                                  .toLowerCase(),
                              child: global.textWidget(global.n2w_year[global
                                      .convertToRoman(i.toString())
                                      .toLowerCase()] ??
                                  "NULL"),
                            )
                        ],
                        onChanged: (val) {
                          setState(() => year = val.toString());
                        }),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: DropdownButton(
                        hint: global.textWidget("Select the semester"),
                        dropdownColor:
                            Theme.of(context).focusColor.withOpacity(0.8),
                        isExpanded: true,
                        value: sem,
                        items: [
                          for (int i in List.generate(8, (index) => index + 1))
                            DropdownMenuItem(
                              value: i,
                              child: global.textWidget("Semester $i"),
                            )
                        ],
                        onChanged: (val) {
                          setState(() => sem = val as int);
                        }),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              if (loaded == true)
                Wrap(
                  spacing: 10,
                  children: [
                    for (MapEntry<String, bool> x in chosen.entries)
                      ChoiceChip(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        disabledColor: Colors.transparent,
                        backgroundColor:
                            Theme.of(context).backgroundColor.withOpacity(0.9),
                        selectedColor: Colors.blueAccent,
                        label: global.textWidget_ns(x.key),
                        selected: x.value,
                        onSelected: (value) {
                          setState(() {
                            chosen[x.key] = value;
                          });
                        },
                      ),
                  ],
                ),
              SizedBox(height: 20),
              global.textWidget(
                  "Copy the course data from title to end of course outcome from the pdf/website and paste it directly here."),
              SizedBox(height: 15),
              global.textField("Paste the data here",
                  controller: _courseDataController, maxLines: 200),
              SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  shadowColor: Colors.transparent,
                  backgroundColor: Theme.of(context).focusColor,
                  surfaceTintColor: Colors.transparent,
                ),
                onPressed: () async {
                  if (year == null || sem == null) {
                    global.alert.quickAlert(
                        context,
                        global.textWidgetWithHeavyFont(
                            "Please fill the assiocated year and semester for the course."));
                    return;
                  }

                  int cancel = 0;
                  global.alert.quickAlert(
                      context,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SpinKitCircle(
                              size: 50,
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .cursorColor,
                            ),
                            SizedBox(height: 20),
                            global.textWidgetWithHeavyFont(
                                "Processing the information"),
                            SizedBox(height: 10),
                            global.textWidget(
                                "Due to cheap servers, might take longer than 2 minutes.")
                          ],
                        ),
                      ),
                      dismissible: false,
                      action: [
                        FloatingActionButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              cancel = 1;
                              Navigator.of(context).pop();
                            })
                      ]);

                  // alr lets get post the data
                  var url =
                      Uri.parse("https://discord-bot-js.sempit.repl.co/course");
                  var request = await HttpClient().postUrl(url);
                  request.headers.contentType = ContentType.json;
                  request.write(_courseDataController.text);

                  var response = await request.close();
                  var responseBody =
                      await response.transform(utf8.decoder).join();

                  if (cancel == 1) return;

                  Map<String, dynamic> jsonObject = json.decode(responseBody);
                  jsonObject["semester"] = sem;
                  jsonObject["year"] = global.n2w_year[year];
                  var chosenDepart = [];
                  for (var x in chosen.entries) {
                    if (x.value == true) {
                      chosenDepart.add(x.key);
                    }
                  }
                  jsonObject["department"] = chosenDepart;

                  jsonObject["description"] =
                      """${jsonObject["code"]} - ${jsonObject["title"]} is an ${year!.toUpperCase()} year course for $sem semester.""";

                  await global.Database!.create(
                      global.Database!.addCollection("courses", "/courses"),
                      jsonObject["code"],
                      jsonObject);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  global.switchToPrimaryUi();

                  if (response.statusCode == HttpStatus.ok) {
                    if (responseBody == "fail") {
                      global.alert.quickAlert(
                          global.rootCTX!,
                          global.textWidget(
                              "Failed to process the data, server returned FAIL."));
                      return;
                    }
                    global.snackbarText("Successfully added the course");
                  } else {
                    global.alert.quickAlert(global.rootCTX!,
                        global.textWidget("Error occurred on HTTP connection"));
                  }
                },
                icon: Icon(Icons.done),
                label: global.textWidgetWithHeavyFont("Submit"),
              ),
              SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
