import 'dart:async';
import 'dart:io';

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/recognition_model.dart';

import 'item_form_screen.dart';

import 'package:tflite/tflite.dart';
import 'package:http/http.dart' as http;

class ImageCaptureScreen extends StatefulWidget {
  final DbHelper dbHelper;

  ImageCaptureScreen({
    Key key,
    @required this.dbHelper,
  }) : super(key: key);

  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  DbHelper _dbHelper;

  File _imageFile;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool _showCapturedPhoto = false;

  bool isModelLoaded = false;
  var _recognitions;

  @override
  initState() {
    super.initState();
    _dbHelper = widget.dbHelper;
    _initializeCamera();
    _loadModel().then((value) {
      setState(() {
        isModelLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.max);
    _initializeControllerFuture = _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  Future<String> _loadModel() async {
    return Tflite.loadModel(
      model: "assets/model/model.tflite",
      labels: "assets/model/labels.txt",
    );
  }

  //void _runModel(String path) async {
  // if (isModelLoaded) {
  //   var recognitions = await Tflite.runModelOnImage(
  //     path: _imageFile.path,
  //   );
  //   setState(() {
  //     _recognitions = recognitions;
  //   });
  // }
  //}

  void _predict(File imageFile) async {
    var stream = new http.ByteStream(imageFile.openRead());
    stream.cast();
    var length = await imageFile.length();

    var uri = Uri.parse(
        //'https://eastus.api.cognitive.microsoft.com/customvision/v3.0/Prediction/5036b984-9bbe-427d-bdc0-858b7842129a/classify/iterations/Iteration1/image');
        'https://eastus.api.cognitive.microsoft.com/customvision/v3.0/Prediction/9269bc05-18a1-4b87-a3f1-99d8fa5244ea/classify/iterations/Iteration13/image');

    var request = new http.MultipartRequest('POST', uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    request.files.add(multipartFile);

    Map<String, String> headers = {
      'Prediction-Key': 'b1d21122558c4de5a0e8b67d5e2cf24a',
      'Content-Type': 'application/json'
    };
    request.headers.addAll(headers);

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      // response.stream.transform(utf8.decoder).listen((value) {
      //   print(value);
      // });
      setState(() {
        _recognitions =
            Recognition.fromJson(json.decode(response.body)).predictions;
      });
    } else {
      print("ERROR " + response.statusCode.toString());
    }
  }

  //@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller == null) {
        _initializeControllerFuture = _controller.initialize();
      }
    }
  }

  void onCaptureButtonPressed() async {
    //on camera button press
    try {
      final path = join(
        (await getTemporaryDirectory()).path, //Temporary path
        '${DateTime.now()}.png',
      );
      await _controller.takePicture(path); //take photo
      _imageFile = File(path);

      //_runModel(path);
      _predict(_imageFile);

      setState(() {
        _showCapturedPhoto = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: Colors.orange[1000],
        toolbarTitle: 'Crop Image',
      ),
    );

    //_runModel(cropped.path);

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void _clear() {
    setState(() {
      _showCapturedPhoto = false;
      _imageFile = null;
      _recognitions = null;
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    if (_showCapturedPhoto) {
      return BottomAppBar(
        elevation: 0,
        color: Colors.black26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              onPressed: _cropImage,
              child: Icon(
                Icons.crop,
                color: Colors.white,
              ),
            ),
            FlatButton(
              onPressed: _clear,
              child: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemFormScreen(
                      dbHelper: _dbHelper,
                      imageFile: _imageFile,
                      recognitions: _recognitions,
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildFloatingActionButton() {
    if (_showCapturedPhoto) {
      //return SizedBox.shrink();
      return _recognitions == null
          ? Icon(
              Icons.cloud_upload,
              color: Colors.white,
            )
          : Icon(
              Icons.cloud_done,
              color: Colors.white,
            );
    } else {
      return Opacity(
        opacity: 0.9,
        child: FloatingActionButton(
          onPressed: onCaptureButtonPressed,
          child: Icon(Icons.camera_alt),
          shape: CircleBorder(
            side: BorderSide(color: Colors.white, width: 4.0),
          ),
          backgroundColor: Colors.transparent,
        ),
      );
    }
  }

  Widget _buildCameraView(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    if (_showCapturedPhoto) {
      return Stack(
        children: [
          Transform.scale(
            scale: _controller.value.aspectRatio / deviceRatio,
            child: Center(
              child: Image.file(_imageFile, fit: BoxFit.cover),
            ),
          ),

          //shows the probability values for each tag
          Positioned(
            top: 80,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _recognitions != null
                  ? _recognitions
                      .map<Widget>(
                        (prediction) => Stack(
                          children: [
                            Text(
                              prediction['tagName'] +
                                  ": " +
                                  prediction['probability'].toString(),
                              //textAlign: TextAlign.end,
                              style: TextStyle(
                                //color: Colors.lightGreen,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              prediction['tagName'] +
                                  ": " +
                                  prediction['probability'].toString(),
                              //textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.lightGreen,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList()
                  : [SizedBox.shrink()],
            ),
          ),
        ],
      );
      // Old show image code
      // Container(
      //   child: new OverflowBox(
      //     minWidth: size.width,
      //     minHeight: size.height,
      //     maxHeight: double.infinity,
      //     child: Image.file(_imageFile, fit: BoxFit.cover),
      //   ),
      // );
    } else {
      return FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Transform.scale(
                scale: _controller.value.aspectRatio / deviceRatio,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller), //cameraPreview
                  ),
                ));
          } else {
            return Center(
                child:
                    CircularProgressIndicator()); // Otherwise, display a loading indicator.
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Picture'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _buildCameraView(context),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
    );
  }
}
