import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';

NotificationDetails get _silentNotification {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'silent channel id',
    'silent channel name',
    'silent channel description',
    playSound: false,
    autoCancel: true,
    importance: Importance.High
  );
  final iOSChannelSpecifics = IOSNotificationDetails(presentSound: false);

  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showSilentNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  int id = 0,
}) =>
    _showNotification(notifications,
        title: title, body: body, id: id, type: _silentNotification);

NotificationDetails get _loudNotification {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    importance: Importance.High,
    playSound: true,
    enableVibration: true,
    autoCancel: true,
  );
  final iOSChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showLoudNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  String payload,
  int id = 0,
}) =>
    _showNotification(notifications,
        title: title, body: body, id: id, type: _loudNotification, payload: payload);

Future _showNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  String payload,
  @required NotificationDetails type,
  int id = 0,
}) =>
    notifications.show(id, title, body, type, payload: payload);

Future scheduleDailyLoudNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  @required Time time,
  String payload,
  int id = 0,
}) {
  return notifications.showDailyAtTime(id, title, body, time, _loudNotification,
      payload: payload);
}

Future scheduleDailySilentNotification(
    FlutterLocalNotificationsPlugin notifications, {
      @required String title,
      @required String body,
      @required Time time,
      String payload,
      int id = 0,
    }) {
  return notifications.showDailyAtTime(id, title, body, time, _silentNotification,
      payload: payload);
}

Future scheduleLoudNotification(
  FlutterLocalNotificationsPlugin notifications, {
    @required String title,
    @required String body,
    @required int id,
    String payload,
    @required DateTime dateTime
  }) {
  return notifications.schedule(id, title, body, dateTime, _loudNotification);
}

NotificationDetails getLoudBigPictureNotificationSettings(BigPictureStyleInformation bigPictureStyleInformation) {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    importance: Importance.High,
    playSound: true,
    enableVibration: true,
    autoCancel: true,
    style: AndroidNotificationStyle.BigPicture,
    styleInformation: bigPictureStyleInformation
  );
  final iOSChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future scheduleLoudBigPictureNotification(
    FlutterLocalNotificationsPlugin notifications, {
      @required String title,
      @required String body,
      @required int id,
      String payload,
      @required DateTime dateTime,
      @required BigPictureStyleInformation bigPictureStyleInformation
    }) {
  return notifications.show(id, title, body, getLoudBigPictureNotificationSettings(bigPictureStyleInformation), payload: payload);
}




