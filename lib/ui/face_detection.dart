import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Project_Prism/global.dart' as global;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as imglib;

bool _backCam = false;

Future<void> uploadImages(List<Object> images) async {
  String url = "https://id.sempit.repl.co/upload";
  List<http.MultipartFile> imageFiles = [];

  for (dynamic image in images) {
    Uint8List compressedData = await compressImage(image[0]);
    imageFiles.add(
      http.MultipartFile.fromBytes(
        'file',
        compressedData,
        filename: 'image_${images.indexOf(image)}.jpeg',
      ),
    );
  }

  try {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.addAll(imageFiles);

    final response = await request.send();

    if (response.statusCode == 200) {
      // Successful response handling
      debugPrint('Images uploaded successfully');
      final responseString = await response.stream.bytesToString();
      List<dynamic> emailsDynamic = jsonDecode(responseString);
      List<dynamic> emails = [];
      var datalist =
          (await global.Database!.firestore.collection("/acc/").get()).docs;
      var dataList = {};
      for (var x in datalist) {
        if (x.data().containsKey("email") && x.data()["email"] != null) {
          dataList[x.data()["email"]] = x.data();
        }
      }
      for (var x in emailsDynamic) {
        String email = x.toString();
        if (email != "No face found" && dataList.containsKey(email)) {
          emails.add(dataList[email]);
        } else {}
      }

      if (emails.isNotEmpty) {
        global.alert.customAlertNoActionWithoutPopScope(
            global.rootCTX!,
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var x in emails)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(global.rootCTX!).focusColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {},
                          child: ListTile(
                            tileColor: Colors.transparent,
                            style: ListTileStyle.list,
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(global.rootCTX!).focusColor,
                              backgroundImage: NetworkImage(x["avatar"]),
                            ),
                            title: global.textWidgetWithHeavyFont(
                                '${x["firstName"]} ${x['lastName']}'),
                            subtitle: global.textWidget_ns(
                              "${x["rollNo"]} ${x["branchCode"]} ${x["year"].toString().toUpperCase()} ${x["section"].toString().toUpperCase()}",
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            null,
            () {},
            () {});
      } else {
        global.snackbarText("Unknown faces only found");
      }
    } else {
      // Handle error
      global.snackbarText('Image upload failed');
    }
  } catch (e) {
    // Handle network error
    debugPrint(
        "Failed on fetching and getting the face detected info from backend | $e");
    global.snackbarText('Network error: $e');
  }
}

Future<Uint8List> compressImage(Uint8List image) async {
  // var result = await FlutterImageCompress.compressWithList(
  //   image,
  //   quality: 70, // Adjust quality as needed
  // );
  //return Uint8List.fromList(result);
  return image;
}

Uint8List convertNV21ToJpeg(Uint8List nv21Data, int width, int height) {
  imglib.Image yuvImage = imglib.Image.fromBytes(
      width: width, height: height, bytes: nv21Data.buffer);

  final jpegData = imglib.encodeJpg(yuvImage);

  return jpegData;
}

// Uint8List flipImageXAxis(Uint8List imageData, int width, int height) {
//   imglib.Image imgData = imglib.decodeImage(imageData)!;

//   // Flip the image horizontally
//   imglib.Image flippedImg =
//       imglib.flip(imgData, direction: imglib.FlipDirection.horizontal);

//   // Encode the flipped image
//   return Uint8List.fromList(imglib.encodeJpg(flippedImg));
// }

Uint8List rotateImage(Uint8List imageData, int width, int height, int rotate) {
  imglib.Image imgData = imglib.decodeImage(imageData)!;
  imglib.Image rotatedImg =
      imglib.copyRotate(imgData, angle: rotate); // Rotate 90 degrees clockwise
  return Uint8List.fromList(imglib.encodeJpg(rotatedImg));
}

imglib.Image decodeYUV420SP(InputImage image) {
  final width = image.metadata!.size.width.toInt();
  final height = image.metadata!.size.height.toInt();

  Uint8List yuv420sp = image.bytes!;
  //int total = width * height;
  //Uint8List rgb = Uint8List(total);
  final outImg =
      imglib.Image(width: width, height: height); // default numChannels is 3

  final int frameSize = width * height;

  for (int j = 0, yp = 0; j < height; j++) {
    int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
    for (int i = 0; i < width; i++, yp++) {
      int y = (0xff & yuv420sp[yp]) - 16;
      if (y < 0) y = 0;
      if ((i & 1) == 0) {
        v = (0xff & yuv420sp[uvp++]) - 128;
        u = (0xff & yuv420sp[uvp++]) - 128;
      }
      int y1192 = 1192 * y;
      int r = (y1192 + 1634 * v);
      int g = (y1192 - 833 * v - 400 * u);
      int b = (y1192 + 2066 * u);

      if (r < 0) {
        r = 0;
      } else if (r > 262143) {
        r = 262143;
      }
      if (g < 0) {
        g = 0;
      } else if (g > 262143) {
        g = 262143;
      }
      if (b < 0) {
        b = 0;
      } else if (b > 262143) {
        b = 262143;
      }

      outImg.setPixelRgb(i, j, ((r << 6) & 0xff0000) >> 16,
          ((g >> 2) & 0xff00) >> 8, (b >> 10) & 0xff);
      /*rgb[yp] = 0xff000000 |
            ((r << 6) & 0xff0000) |
            ((g >> 2) & 0xff00) |
            ((b >> 10) & 0xff);*/
    }
  }
  return outImg;
}

List<Face> faces = [];
InputImage? _inputImage;

class FaceDetection extends StatefulWidget {
  const FaceDetection({super.key});

  @override
  State<FaceDetection> createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  void initState() {
    _backCam = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    _inputImage = inputImage;
    faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.green;

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint1,
      );

      void paintLandmark(FaceLandmarkType type) {
        final landmark = face.landmarks[type];
        if (landmark?.position != null) {
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              2,
              paint2);
        }
      }

      for (final type in FaceLandmarkType.values) {
        paintLandmark(type);
      }
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}

enum DetectorViewMode { liveFeed, gallery }

class DetectorView extends StatefulWidget {
  const DetectorView({
    Key? key,
    required this.title,
    required this.onImage,
    this.customPaint,
    this.text,
    this.initialDetectionMode = DetectorViewMode.liveFeed,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final DetectorViewMode initialDetectionMode;
  final Function(InputImage inputImage) onImage;
  final Function()? onCameraFeedReady;
  final Function(DetectorViewMode mode)? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<DetectorView> createState() => _DetectorViewState();
}

class _DetectorViewState extends State<DetectorView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: widget.customPaint,
      onImage: widget.onImage,
      onCameraFeedReady: widget.onCameraFeedReady,
      onDetectorViewModeChanged: _onDetectorViewModeChanged,
      initialCameraLensDirection: widget.initialCameraLensDirection,
      onCameraLensDirectionChanged: widget.onCameraLensDirectionChanged,
    );
  }

  void _onDetectorViewModeChanged() {
    // inputImage contains the entire photo
    if (faces.isEmpty || _inputImage == null) {
      global.snackbarText("No faces detected.");
    } else {
      // Load the input image
      double w = _inputImage!.metadata!.size.width;
      double h = _inputImage!.metadata!.size.height;
      var decoded = decodeYUV420SP(_inputImage!);
      var src = rotateImage(
          convertNV21ToJpeg(decoded.buffer.asUint8List(), w.toInt(), h.toInt()),
          h.toInt(),
          w.toInt(),
          !_backCam ? -90 : 90);

      // if (_backCam == false) {
      //   src = flipImageXAxis(src, w.toInt(), h.toInt());
      // }
      var lImage = imglib.decodeJpg(src);
      Uint8List combinedImageBytes;
      List<List<Object>> croppedFaces = [];
      // // Create a canvas to combine cropped faces
      for (var face in faces) {
        // Extract bounding box coordinates
        int left = face.boundingBox.left.toInt();
        int top = face.boundingBox.top.toInt();
        int width = face.boundingBox.width.toInt();
        int height = face.boundingBox.height.toInt();

        // Crop the input image using copyCrop from image package
        var croppedFace = imglib.copyCrop(lImage as imglib.Image,
            x: left, y: top, width: width, height: height);
        combinedImageBytes = imglib.encodeJpg(croppedFace);
        croppedFaces.add([
          combinedImageBytes,
          h,
          w,
        ]);
      }

      if (global.cameraShotFn == null) {
        uploadImages(croppedFaces);
        global.alert.customAlertNoActionWithoutPopScope(
            context,
            SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (List<Object> x in croppedFaces)
                  Image.memory(
                    x[0] as Uint8List,
                    height: x[1] as double,
                    width: x[2] as double,
                  )
              ],
            )),
            global.textWidgetWithHeavyFont(
                "${croppedFaces.length} faces detected"),
            () {},
            () {});

        // global.alert.customAlertNoActionWithoutPopScope(
        //     context,
        //     SingleChildScrollView(
        //         child: Image.memory(
        //       src,
        //       height: h,
        //       width: w,
        //     )),
        //     global.textWidgetWithHeavyFont(
        //         "${croppedFaces.length} faces detected"),
        //     () {},
        //     () {});
      } else {
        global.cameraShotFn!(croppedFaces);
      }

      // Combine the cropped face onto the combinedImage canvas
      // Update the UI if needed
      //   setState(() {});
      // }

      // Convert the combinedImage to bytes
    }
  }
}

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back})
      : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: global.textWidgetWithHeavyFont("Face detection"),
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        elevation: 0, // Remove the shadow under the AppBar
        leading: IconButton(
          onPressed: () {
            global.switchToPrimaryUi();
            // Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textSelectionTheme.selectionHandleColor,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Apply the glassy effect with blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
                // color:
                //     Colors.black.withOpacity(0.3), // Adjust the opacity as needed
                ),
          ),
          _liveFeedBody(),
        ],
      ),
    );
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? const Center(
                    child: Text('Changing camera lens'),
                  )
                : CameraPreview(
                    _controller!,
                    child: widget.customPaint,
                  ),
          ),
          // _backButton(),
          _switchLiveCameraToggle(),
          _detectionViewModeToggle(),
          _zoomControl(),
          _exposureControl(),
        ],
      ),
    );
  }

  Widget _detectionViewModeToggle() => Positioned(
        bottom: 16,
        left: (MediaQuery.of(context).size.width / 2) - 25,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: widget.onDetectorViewModeChanged,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.camera,
              size: 25,
              color: Theme.of(context).textSelectionTheme.selectionHandleColor,
            ),
          ),
        ),
      );
  Widget _switchLiveCameraToggle() => Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          heroTag: 'switchLiveCameraToggle',
          onPressed: _switchLiveCamera,
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.flip_camera_android,
            size: 30,
            color: Theme.of(context).textSelectionTheme.selectionHandleColor,
          ),
        ),
      );

  Widget _zoomControl() => Positioned(
        bottom: 80,
        left: 16,
        right: 16,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.zoom_out,
                  color:
                      Theme.of(context).textSelectionTheme.selectionHandleColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentZoomLevel.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _exposureControl() => Positioned(
        top: 40,
        right: 16,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentExposureOffset.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: _currentExposureOffset,
                min: _minAvailableExposureOffset,
                max: _maxAvailableExposureOffset,
                onChanged: (value) async {
                  setState(() {
                    _currentExposureOffset = value;
                  });
                  await _controller?.setExposureOffset(value);
                },
              ),
            ),
          ],
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _stopLiveFeed();
    await _startLiveFeed();
    _backCam = !_backCam;
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    var inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;
    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    debugPrint(rotation.toString());
    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
  }
}
