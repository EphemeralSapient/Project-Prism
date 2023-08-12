import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:ota_update/ota_update.dart';

class update_ui extends StatefulWidget {
  @override
  State<update_ui> createState() => _update_uiState();
}

class _update_uiState extends State<update_ui> {
  OtaEvent? currentEvent;
  String? error;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
    tryOtaUpdate();
  }

  Future<void> getPackageInfo() async {
    setState(() {});
  }

  Future<void> tryOtaUpdate() async {
    try {
      OtaUpdate()
          .execute(
        'https://github.com/EphemeralSapient/Project-Prism/raw/main/install/android/app-arm64-v8a-release.apk',
        destinationFilename: 'app-release.apk',
      )
          .listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
    } catch (e) {
      error = e.toString();
      debugPrint('Failed to make OTA update. Details: $e');
      //Navigator.pop(context);
    }
  }

  bool trigger = false;
  @override
  Widget build(BuildContext context) {
    if (currentEvent != null &&
        (currentEvent?.status != OtaStatus.DOWNLOADING &&
            currentEvent?.status != OtaStatus.INSTALLING)) {
      trigger = true;
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pop(context);
      });
    }
    return WillPopScope(
      onWillPop: () async =>
          currentEvent?.status == OtaStatus.INSTALLING ? true : false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDualRing(
              color: Colors.lightBlue,
              lineWidth: 2,
              size: 160,
            ),
            global.padHeight(80),
            global.textWidget(
                "OTA Status : ${currentEvent?.status.toString() ?? 'NULL'}"),
            global.padHeight(20),
            global.textWidget(trigger == false
                ? "Percentage completed : ${currentEvent?.value ?? 'NULL'}"
                : "${currentEvent?.value ?? 'NULL'} | Auto closing in 5 seconds")
          ],
        )),
      ),
    );
  }
}
