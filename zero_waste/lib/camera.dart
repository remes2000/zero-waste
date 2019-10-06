import 'dart:io';

import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController controller;
  List<CameraDescription> cameras = globals.cameras;
  Future<void> _initializeControllerFuture;
  String picturePath = "";

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras.first, ResolutionPreset.medium);
    _initializeControllerFuture = controller.initialize();
    _initializeControllerFuture.then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void takeAPicture() async {
    try {
      await _initializeControllerFuture;
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      await controller.takePicture(path);
      this.picturePath = path;
      this.setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Widget acceptImageView() {
    return SafeArea(child: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        children: <Widget>[
          Container(
            height: constraints.maxHeight * 0.7,
            width: constraints.maxWidth,
            child: Image.file(File(picturePath))
          ),
          Container(
              height: constraints.maxHeight * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () {},
                    child: Icon(
                      Icons.check,
                      size: 50,
                      color: Colors.white,
                    ),
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.green,
                    padding: const EdgeInsets.all(15.0),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      picturePath = "";
                      this.setState(() {});
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 50,
                      color: Colors.white,
                    ),
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.red,
                    padding: const EdgeInsets.all(15.0),
                  ),
                ],
              ))
        ],
      );
    }));
  }

  Widget takeAPictureView() {
    return SafeArea(child: new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(color: Colors.red),
                height: constraints.maxHeight * 0.7,
                width: constraints.maxWidth,
                child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller))),
            Container(
              height: constraints.maxHeight * 0.3,
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                    /*
                        RawMaterialButton(
                          onPressed: () {
                            changeCamera();
                          },
                          child: Icon(
                            Icons.switch_camera,
                            size: 25,
                            color: Colors.white,
                          ),
                          shape: new CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.blue,
                          padding: const EdgeInsets.all(15.0),
                        ),*/
                    RawMaterialButton(
                      onPressed: () {
                        takeAPicture();
                      },
                      child: Icon(
                        Icons.photo_camera,
                        size: 50,
                        color: Colors.white,
                      ),
                      shape: new CircleBorder(),
                      elevation: 2.0,
                      fillColor: Colors.blue,
                      padding: const EdgeInsets.all(15.0),
                    ),
                  ])),
            )
          ],
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (!controller.value.isInitialized) {
      widget = Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width,
      );
    } else {
      if (this.picturePath != '') {
        widget = acceptImageView();
      } else {
        widget = takeAPictureView();
      }
    }

    return widget;
  }
}
