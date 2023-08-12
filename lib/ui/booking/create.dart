import 'package:Project_Prism/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateSeminarHallBookingUi extends StatefulWidget {
  @override
  State<CreateSeminarHallBookingUi> createState() =>
      _CreateSeminarHallBookingUiState();
}

class _CreateSeminarHallBookingUiState
    extends State<CreateSeminarHallBookingUi> {
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _seatCountController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();

  String selectedBlock = 'A'; // Default value for block name
  String hallType = "Seminar Hall"; // Default value for hall type

  dynamic infoData;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      global.Database!.addCollection("permissionLevel", "/permissionLevel");

      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.doc('/permissionLevel/info').get();
      infoData = docSnapshot.data();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return infoData == null
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
            appBar: AppBar(
              title: global.textWidgetWithHeavyFont('Add New Hall/Room'),
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).textSelectionTheme.selectionColor),
                onPressed: () {
                  global.switchToPrimaryUi();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0, left: 16, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        global.textWidget("Block: "),
                        DropdownButton(
                          dropdownColor:
                              Theme.of(context).focusColor.withOpacity(1),
                          value: selectedBlock,
                          onChanged: (value) {
                            setState(() {
                              selectedBlock = value as String;
                            });
                          },
                          items: [
                            'A',
                            'B',
                            'C',
                            'D',
                            'E',
                            'F',
                            'G'
                          ].map<DropdownMenuItem<String>>((String blockName) {
                            return DropdownMenuItem<String>(
                              value: blockName,
                              child: global.textWidget(blockName),
                            );
                          }).toList(),
                        ),
                        global.textWidget("Hall/Room type: "),
                        DropdownButton(
                          dropdownColor:
                              Theme.of(context).focusColor.withOpacity(1),
                          value: hallType,
                          onChanged: (value) {
                            setState(() {
                              hallType = value as String;
                            });
                          },
                          items: [
                            "Seminar Hall",
                            "Computer Lab",
                            "Engineering Graphics Lab",
                            "Civil Lab",
                            "Other lab",
                          ].map<DropdownMenuItem<String>>((String blockName) {
                            return DropdownMenuItem<String>(
                              value: blockName,
                              child: global.textWidget(blockName),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    global.textField(
                      'Floor Number',
                      controller: _floorController,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    global.textField(
                      'Seat Count (Approx)',
                      controller: _seatCountController,
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    global.textField(
                      'Room Number',
                      controller: _roomNumberController,
                      maxLength: 5,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        shadowColor: Colors.transparent,
                        backgroundColor: Theme.of(context).focusColor,
                        surfaceTintColor: Colors.transparent,
                      ),
                      onPressed: () {
                        if (_floorController.text.isEmpty ||
                            _seatCountController.text.isEmpty ||
                            _roomNumberController.text.isEmpty) {
                          global.alert.quickAlert(
                              context,
                              global.textWidget(
                                  "Please fill the form properly."));
                        } else {
                          CollectionReference<Object?> collection =
                              global.Database!.addCollection("halls", "/halls");

                          Future.delayed(Duration.zero, () async {
                            var data = {
                              "status": "Free",
                              'floor': int.tryParse(_floorController.text),
                              'block': selectedBlock,
                              'type': hallType,
                              'seat_count':
                                  int.tryParse(_seatCountController.text),
                              'room_number': _roomNumberController.text,
                            };

                            var fetch = await global.Database!.get(collection,
                                "$selectedBlock${_floorController.text}-${_roomNumberController.text}");

                            if (fetch.status != db_fetch_status.nodata) {
                              global.snackbarText(
                                  "⚠️ WARNING : There is already an existing room for the given floor and room number data. Please use modify");
                              return;
                            }

                            var get = await global.Database!.create(
                              collection,
                              "$selectedBlock${_floorController.text}-${_roomNumberController.text}",
                              data,
                            );

                            if (get.status == db_fetch_status.success) {
                              global.snackbarText(
                                  "Successfully added the hall/room to the list.");
                              global.switchToPrimaryUi();
                            } else {
                              global.alert.quickAlert(
                                  global.rootCTX!,
                                  global.textWidget(
                                      "Failed to add the hall/room info to database | ${get.status} | ${get.data}"));
                            }
                          });
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
