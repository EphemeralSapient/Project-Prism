import 'dart:typed_data';

import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/face_detection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

List<Object> face = [];

Function? SetState;
BuildContext? ctx;

Future<String> uploadImageToFirestore(
    Uint8List imageBytes, String imageName) async {
  final Reference storageReference =
      FirebaseStorage.instance.ref().child('faces/$imageName');

  final UploadTask uploadTask = storageReference.putData(imageBytes);

  final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() => null);

  final String downloadUrl = await uploadSnapshot.ref.getDownloadURL();

  return downloadUrl;
}

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  String email = "";
  String? facePhotoUrl;

  @override
  void initState() {
    email = global.account!.email!;
    super.initState();
    facePhotoUrl = global.accObj!.facePhoto;
    SetState = setState;
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      backgroundColor: Theme.of(context).focusColor, // Updated background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: facePhotoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(facePhotoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: facePhotoUrl == null
                  ? Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.grey[600],
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            if (facePhotoUrl == null)
              global.textWidgetWithHeavyFont(
                "No profile image available",
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                bool isAllowed = true;
                bool backButtonPressed = false;
                global.cameraShotFn = (dynamic listOfFace) async {
                  var attempt = listOfFace as List<Object>;

                  if (attempt.length != 1) {
                    global.snackbarText("Only one face is allowed.");
                  } else {
                    if (!isAllowed) return;
                    isAllowed = false;
                    global.alert.customAlertNoActionWithoutPopScope(
                        global.rootCTX!,
                        Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SpinKitCircle(
                                  color: Colors.blue, // Customize the color
                                  size: 50, // Customize the size
                                ),
                                const SizedBox(height: 10),
                                global.textWidgetWithHeavyFont(
                                  'Updating...',
                                ),
                              ],
                            )),
                        null, () {
                      backButtonPressed = true;
                    }, () {});

                    face = attempt[0] as List<Object>;
                    try {
                      String url = "https://id.sempit.repl.co/verify";
                      List<http.MultipartFile> imageFiles = [];

                      for (dynamic image in [face[0]]) {
                        Uint8List compressedData = await compressImage(image);
                        imageFiles.add(
                          http.MultipartFile.fromBytes(
                            'file',
                            compressedData,
                            filename: 'image_verification.jpeg',
                          ),
                        );
                      }

                      try {
                        final request =
                            http.MultipartRequest('GET', Uri.parse(url));
                        request.files.addAll(imageFiles);

                        final response = await request.send();

                        if (response.statusCode == 200) {
                          // Successful response handling
                          debugPrint('Images uploaded successfully');
                          final responseString =
                              await response.stream.bytesToString();

                          if (responseString != "Face found") {
                            global.snackbarText(
                                "FAILED | Backend failed to detect the face");
                            if (!backButtonPressed) {
                              Navigator.pop(global.rootCTX!);
                            }

                            debugPrint(responseString);
                            isAllowed = true;

                            return;
                          }
                        } else {
                          // Handle error
                          global.snackbarText('Image upload failed');
                          if (!backButtonPressed) {
                            Navigator.pop(global.rootCTX!);
                          }

                          isAllowed = true;

                          return;
                        }
                      } catch (e) {
                        // Handle network error
                        global.snackbarText('Network error: $e');
                        isAllowed = true;
                        if (!backButtonPressed) {
                          Navigator.pop(global.rootCTX!);
                        }

                        return;
                      }
                      String href = await uploadImageToFirestore(
                          face[0] as Uint8List, global.account!.email!);
                      global.accObj!.facePhoto = href;
                      facePhotoUrl = href;
                      global.Database!.update(
                          global.Database!.addCollection("acc", "/acc"),
                          global.account!.email!,
                          global.accObj!.toJson());
                      isAllowed = true;
                      if (!backButtonPressed) {
                        Navigator.pop(global.rootCTX!);
                      }

                      global.switchToPrimaryUi();
                      Future.delayed(Duration.zero, () async {
                        await http
                            .get(Uri.parse('https://id.sempit.repl.co/update'));
                        global.snackbarText("Database has been updated");
                      });
                      global.snackbarText(
                          "Successfully updated the account, wait for backend to update");
                      await Future.delayed(const Duration(seconds: 1),
                          () async {
                        global.rootRefresh!();
                      });
                    } catch (e) {
                      global.snackbarText("Failed to update, ${e.toString()}");
                      debugPrint(e.toString());
                    }
                  }
                };

                global.switchToSecondaryUi(const FaceDetection());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).focusColor, // Button color
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: global.textWidget_ns("Create profile"),
            ),
          ],
        ),
      ),
    );
  }
}
