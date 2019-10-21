import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero_waste/models/product.dart';

import '../globals.dart';

Widget generateProductCard(Product product){
  return Card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.file(
            File(product.imagePath),
          ),
          Padding(
            padding: const EdgeInsets.all(7),
            child: Text("Data ważności: ",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18)),
          ),
          renderDate(product),
          Padding(
            padding: const EdgeInsets.all(7),
            child: Text(renderIsoDate(
                product)),
          )
        ],
      ));
}

Widget renderDate(Product product) {
  DateTime date = resetTime(
      DateTime.fromMillisecondsSinceEpoch(product.expirationDate * 1000));
  DateTime now = resetTime(DateTime.now());
  DateTime weekInFuture = resetTime(
      DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch)
          .add(Duration(days: 7)));
  String content = "";
  if (date.isAfter(weekInFuture)) {
    content = date.toIso8601String().split("T")[0];
  } else {
    int daysDifference = date.difference(now).inDays;
    if (daysDifference == 0) {
      content = "Ostatni dzień przydatności";
    } else if (daysDifference < 0) {
      content = "Produkt przeterminowany :(";
    } else {
      content = daysDifference.toString() +
          (daysDifference == 1 ? ' dzień' : ' dni');
    }
  }
  return Padding(
    padding: const EdgeInsets.all(7),
    child: Text(
      content,
      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    ),
  );
}