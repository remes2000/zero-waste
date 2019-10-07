import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController controller;
  List<CameraDescription> cameras;
  Future<void> _initializeControllerFuture;
  String picturePath = "";
  bool pictureAccepted = false;

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      controller = CameraController(cameras.first, ResolutionPreset.medium);
      _initializeControllerFuture = controller.initialize();
      _initializeControllerFuture.then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
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

  Widget selectDateView() {
    return SafeArea(child: new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: <Widget>[
            Center(
                child: Container(
                    height: constraints.maxHeight * 0.6,
                    child: Card(child: Image.file(File(picturePath))))),
            Container(
                height: constraints.maxHeight * 0.1,
                child: Center(
                    child: Text("Data ważności: ",
                        style: TextStyle(fontSize: 20, )))),
            Container(
                height: constraints.maxHeight * 0.3,
                child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      ListTile(
                        title: Center(child: Text('1 dzień')),
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('3 dni')),
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('Tydzień')),
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('Miesiąc')),
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('Wybierz datę')),
                      ),
                      Divider(),
                    ]))
          ],
        );
      },
    ));
  }

  Widget acceptImageView() {
    return SafeArea(child: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        children: <Widget>[
          Container(
              height: constraints.maxHeight * 0.7,
              child: Card(child: Image.file(File(picturePath)))),
          Container(
              height: constraints.maxHeight * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () {
                      pictureAccepted = true;
                      this.setState(() {});
                    },
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
                      pictureAccepted = false;
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
                height: constraints.maxHeight * 0.7,
                child: Card(
                    child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller)))),
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
    if (controller == null || !controller.value.isInitialized) {
      widget = Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width,
      );
    } else {
      if (this.picturePath != '') {
        if (pictureAccepted) {
          widget = selectDateView();
        } else {
          widget = acceptImageView();
        }
      } else {
        widget = takeAPictureView();
      }
    }

    return widget;
  }
}
