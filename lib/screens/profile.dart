import 'dart:typed_data';

import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/face_detection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

List<Object> face = [];

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
  }

  @override
  Widget build(BuildContext context) {
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
                global.cameraShotFn = (dynamic listOfFace) async {
                  var attempt = listOfFace as List<Object>;

                  if (attempt.length != 1) {
                    global.snackbarText("Only one face is allowed.");
                  } else {
                    global.switchToPrimaryUi();
                    face = attempt[0] as List<Object>;
                    try {
                      String href = await uploadImageToFirestore(
                          face[0] as Uint8List, global.account!.email!);
                      global.accObj!.facePhoto = href;
                      facePhotoUrl = href;
                      global.Database!.update(
                          global.Database!.addCollection("acc", "/acc"),
                          global.account!.email!,
                          global.accObj!.toJson());
                      global.snackbarText("Successfully updated the account!");
                      setState(() {});
                    } catch (e) {
                      global.snackbarText("Failed to update, check logs");
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
