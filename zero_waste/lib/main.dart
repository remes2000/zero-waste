import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zero_waste/change_notifieres/product_model.dart';
import 'package:zero_waste/database/database.dart';
import 'package:zero_waste/models/product.dart';
import 'package:zero_waste/pages/daily_summary.dart';
import 'package:zero_waste/pages/product_preview.dart';
import 'package:zero_waste/products_list.dart';
import 'globals.dart';
import 'pages/add_product.dart';
import 'models/product.dart';
import 'local_notifications_helper.dart';

void main() {
  runApp(ChangeNotifierProvider(
    builder: (context) => ProductModel(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ZeroWaste',
        theme: ThemeData(
          primarySwatch: Colors.blue
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  bool showOutOfDate = true;
  bool showTodays = true;
  bool showThisWeek = true;
  bool showThisMonth = true;
  bool showLater = true;

  @override
  void initState() {
    super.initState();

    final settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);

    scheduleNotifications();
  }

  Future onSelectNotification(String payload) async {
    if (payload == summaryNotificationPayload) {
      return await Navigator.push(
          context, MaterialPageRoute(builder: (context) => DailySummary()));
    }
    return await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductPreview(productId: int.parse(payload))));
  }

  void printPendingNotifications() async {
    var pendingNotificationRequests =
        await notifications.pendingNotificationRequests();

    print("----------===PENDING NOTIFICATIONS===----------");
    pendingNotificationRequests.forEach((PendingNotificationRequest request) {
      print('notification');
      print('id = ' + request.id.toString());
      print('title = ' + request.title);
      print('body = ' + request.body);
      print('payload = ' + request.payload);
    });
  }

  void scheduleNotifications() async {
    await scheduleDailySilentNotification(notifications,
        title: 'Zero Waste - sprawdź stan swojej lodówki',
        body: 'Kliknij w powiadomienie aby przejść do raportu dziennego',
        time: Time(11, 0, 0),
        payload: summaryNotificationPayload);
    printPendingNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zero Waste')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: ProductsList(showOutOfDate: showOutOfDate, showTodays: showTodays, showThisWeek: showThisWeek, showThisMonth: showThisMonth, showLater: showLater, notifications: notifications,),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
              )
            ),
            Padding(
                padding: EdgeInsets.all(15),
                child: ListTile(
                  title: Text("Podsumowanie dzienne"),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
                      return DailySummary();
                    }));
                  },
                )),
            Padding(
                padding: EdgeInsets.all(15),
                child: CheckboxListTile(
                  value: showOutOfDate,
                  onChanged: (bool value) {
                    showOutOfDate = value;
                    this.setState(() {});
                  },
                  title: Text(
                    'Przeterminowane',
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(15),
                child: CheckboxListTile(
                  value: showTodays,
                  onChanged: (bool value) {
                    showTodays = value;
                    this.setState(() {});
                  },
                  title: Text(
                    'Dzisiaj',
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(15),
                child: CheckboxListTile(
                  value: showThisWeek,
                  onChanged: (bool value) {
                    showThisWeek = value;
                    this.setState((){});
                  },
                  title: Text(
                    'W tym tygodniu',
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(15),
                child: CheckboxListTile(
                  value: showThisMonth,
                  onChanged: (bool value) {
                    showThisMonth = value;
                    this.setState(() {});
                  },
                  title: Text(
                    'W tym miesiącu',
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(15),
                child: CheckboxListTile(
                  value: showLater,
                  onChanged: (bool value) {
                    showLater = value;
                    this.setState(() {});
                  },
                  title: Text(
                    'Później',
                  ),
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return AddProductPage(notifications: notifications);
          }));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
