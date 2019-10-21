import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:zero_waste/change_notifieres/product_model.dart';
import 'package:zero_waste/local_notifications_helper.dart';
import '../globals.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

class AddProductPage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin notifications;

  AddProductPage({this.notifications}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj produkt')),
      body: AddProduct(notifications: notifications),
    );
  }
}

class AddProduct extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notifications;

  AddProduct({this.notifications}) : super();

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void printPendingNotifications() async {
    var pendingNotificationRequests =
    await this.widget.notifications.pendingNotificationRequests();

    print("----------===PENDING NOTIFICATIONS===----------");
    pendingNotificationRequests.forEach((PendingNotificationRequest request) {
      print('notification');
      print('id = ' + request.id.toString());
      print('title = ' + request.title);
      print('body = ' + request.body);
      print('payload = ' + request.payload);
    });
  }


  void saveProduct(DateTime expirationTime) async {
    Product product = Product(
        id: null,
        expirationDate: (expirationTime.millisecondsSinceEpoch / 1000).floor());
    try {
      product = await insertProduct(product);
      //Once we have product id, lets save our photo
      final File tempPicture = File(picturePath);
      final String path =
          '${(await getApplicationDocumentsDirectory()).path}/${product.id}.png';
      await tempPicture.copy(path);
      product.imagePath = path;
      //Now update product db row
      await updateProduct(product);
      picturePath = "";
      pictureAccepted = false;
      Provider.of<ProductModel>(context).add(product);
      //once everything is saved, let's schedule notification
      DateTime scheduleNotificationTime = setTime(expirationTime, 12, 0, 0);
      await scheduleLoudBigPictureNotification(this.widget.notifications,
          title: 'Data ważności jednego z produktów kończy się dzisiaj',
          body: "Kliknij w powiadomienie aby zobaczyć szczegóły",
          payload: product.id.toString(),
          id: product.id,
          bigPictureStyleInformation: BigPictureStyleInformation(
            product.imagePath,
            BitmapSource.FilePath
          ),
          dateTime: scheduleNotificationTime);
      this.setState(() {});
      printPendingNotifications();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Produkt został poprawnie dodany"),
      ));
    } catch (e) {
      print(e);
      picturePath = "";
      pictureAccepted = false;
      this.setState(() {});
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Wystąpił problem podczas dodawania produktu"),
      ));
    }
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
                        style: TextStyle(
                          fontSize: 20,
                        )))),
            Container(
                height: constraints.maxHeight * 0.3,
                child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      ListTile(
                        title: Center(child: Text('1 dzień')),
                        onTap: () {
                          saveProduct(DateTime.now().add(Duration(days: 1)));
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('3 dni')),
                        onTap: () {
                          saveProduct(DateTime.now().add(Duration(days: 3)));
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('Tydzień')),
                        onTap: () {
                          saveProduct(DateTime.now().add(Duration(days: 7)));
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('Miesiąc')),
                        onTap: () {
                          DateTime now = DateTime.now();
                          DateTime monthInFuture = DateTime(
                              now.year,
                              now.month == 12 ? 1 : now.month + 1,
                              now.day,
                              now.hour,
                              now.minute,
                              now.second,
                              now.millisecond,
                              now.microsecond);
                          saveProduct(monthInFuture);
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Center(child: Text('Wybierz datę')),
                        onTap: () {
                          DatePicker.showDatePicker(context,
                              minDateTime: DateTime.now(),
                              pickerTheme: DateTimePickerTheme(
                                  cancel: Text(
                                    "Anuluj",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  confirm: Text("Zatwierdź",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 17))),
                              //To be honest i have no idea what 'list' variable stores
                              onConfirm: (DateTime date, List<int> list) {
                            saveProduct(date);
                          });
                        },
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
              child: Center(
                child: Card(child: Image.file(File(picturePath))),
              )),
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
