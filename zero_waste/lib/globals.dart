library zero_waste.globals;

import 'models/product.dart';

DateTime resetTime(DateTime object){
  return DateTime(object.year, object.month, object.day, 0, 0, 0, 0, 0);
}

DateTime setTime(DateTime object, int hours, int minutes, int seconds){
  return DateTime(object.year, object.month, object.day, hours, minutes, seconds, 0, 0);
}

final String summaryNotificationPayload = "SUMMARY_NOTIFICATION_PAYLOAD";

bool isOutOfTime(Product product){
  DateTime now = resetTime(DateTime.now());
  DateTime productDate = resetTime(DateTime.fromMillisecondsSinceEpoch(
      product.expirationDate * 1000));
  return productDate.difference(now).inDays < 0;
}

bool isToday(Product product){
  DateTime now = resetTime(DateTime.now());
  DateTime productDate = resetTime(DateTime.fromMillisecondsSinceEpoch(
      product.expirationDate * 1000));
  return productDate.difference(now).inDays == 0;
}

bool isThisWeek(Product product){
  DateTime now = resetTime(DateTime.now());
  DateTime productDate = resetTime(DateTime.fromMillisecondsSinceEpoch(
      product.expirationDate * 1000));
  return productDate.difference(now).inDays <= 7 &&
      productDate.difference(now).inDays > 0;
}

bool isThisMonth(Product product){
  DateTime now = resetTime(DateTime.now());
  DateTime productDate = resetTime(DateTime.fromMillisecondsSinceEpoch(
      product.expirationDate * 1000));
  return now.month == productDate.month &&
      productDate.difference(now).inDays > 7;
}

bool isLater(Product product){
  return !isOutOfTime(product) && !isThisWeek(product) && !isThisMonth(product);
}

String renderIsoDate(Product product) {
  DateTime date = resetTime(
      DateTime.fromMillisecondsSinceEpoch(product.expirationDate * 1000));
  return date.toIso8601String().split("T")[0];
}
