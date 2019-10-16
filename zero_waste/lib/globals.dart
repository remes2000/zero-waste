library zero_waste.globals;

DateTime resetTime(DateTime object){
  return DateTime(object.year, object.month, object.day, 0, 0, 0, 0, 0);
}

final String summaryNotificationPayload = "SUMMARY_NOTIFICATION_PAYLOAD";