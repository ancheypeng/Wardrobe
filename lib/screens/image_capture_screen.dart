import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wardrobe/database/db_helper.dart';

import 'item_form_screen.dart';

import 'package:tflite/tflite.dart';

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

  Tflite model = new Tflite();

  bool isModelLoaded = false;
  var _recognitions = [];
  var _colorRecognitions;

  @override
  initState() {
    super.initState();
    _dbHelper = widget.dbHelper;
    _initializeCamera();
    _loadModel().then((_) {
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

  Future<String> _loadColorModel() async {
    return Tflite.loadModel(
      model: "assets/model/colorModel.tflite",
      labels: "assets/model/colorLabels.txt",
    );
  }

  void _runModel(String path) async {
    if (!isModelLoaded) {
      _loadModel().then((_) {
        setState(() {
          isModelLoaded = true;
        });
        _runModel(path);
      });
    } else {
      //modelIsLoaded == true
      var recognitions = await Tflite.runModelOnImage(
        path: path,
        imageMean: 0, // defaults to 117.0
        imageStd: 255,
        threshold: 0,
      );
      setState(() {
        _recognitions = recognitions;
      });
      _loadColorModel().then((_) async {
        var recognitions = await Tflite.runModelOnImage(
          path: path,
          imageMean: 0, // defaults to 117.0
          imageStd: 255,
          threshold: 0,
        );
        setState(() {
          _colorRecognitions = recognitions;
          isModelLoaded = false;
        });
      });
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

      _runModel(path);

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

    if (cropped != null) {
      _runModel(cropped.path);
    }

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
                      colorRecognitions: _colorRecognitions,
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
              children: [
                Column(
                  children: _buildPredictionsPreview(),
                ),
                Column(
                  children: _buildColorPredictionsPreview(),
                ),
              ],
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

  List<Widget> _buildPredictionsPreview() {
    return _recognitions != null
        ? _recognitions
            .map<Widget>(
              (prediction) => Stack(
                children: [
                  Text(
                    prediction['label'] +
                        ": " +
                        prediction['confidence'].toString(),
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
                    prediction['label'] +
                        ": " +
                        prediction['confidence'].toString(),
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
        : [SizedBox.shrink()];
  }

  List<Widget> _buildColorPredictionsPreview() {
    return _colorRecognitions != null
        ? _colorRecognitions
            .map<Widget>(
              (prediction) => Stack(
                children: [
                  Text(
                    prediction['label'] +
                        ": " +
                        prediction['confidence'].toString(),
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
                    prediction['label'] +
                        ": " +
                        prediction['confidence'].toString(),
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
        : [SizedBox.shrink()];
  }
}
