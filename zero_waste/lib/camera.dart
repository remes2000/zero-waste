import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:camera/camera.dart';

class CameraWidget extends StatefulWidget{
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget>{
  CameraController controller;
  List<CameraDescription> cameras = globals.cameras;
  @override
  void initState(){
    super.initState();
    controller = CameraController(cameras.first, ResolutionPreset.medium);
    controller.initialize().then((_){
      if(!mounted){
        return;
      }
      setState((){});
    });
  }

  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (!controller.value.isInitialized){
      widget = Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width,
      );
    } else {
      widget = SafeArea(
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints){
            return Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.red),
                  height: constraints.maxHeight * 0.7,
                  width: constraints.maxWidth,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller)
                  )
                ),
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
                      ]
                    )
                  ),
                )
              ],
            );
          },
        )
      );
    }

    return widget;
  }

}