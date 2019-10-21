import 'package:flutter/material.dart';
import 'package:zero_waste/models/product.dart';

import '../globals.dart';

class DailySummary extends StatefulWidget {
  @override
  _DailySummaryState createState() => _DailySummaryState();
}

class _DailySummaryState extends State<DailySummary> {
  final TextStyle numberStyles = TextStyle(fontSize: 80);
  final TextStyle description = TextStyle(fontSize: 20);
  List<Widget> cards = [];

  @override
  void initState() {
    super.initState();
    generateSummary();
  }

  Widget generateCard(String topText, String number, String bottomText) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Text(
                  topText,
                  style: description,
                ),
                Text(number, style: numberStyles),
                Text(bottomText, style: description)
              ],
            )));
  }

  void generateSummary() async {
    List<Product> products = await getAllProducts();
    List<Product> today = products.where((Product product) {
      DateTime now = resetTime(DateTime.now());
      DateTime productDate = resetTime(
          DateTime.fromMillisecondsSinceEpoch(product.expirationDate * 1000));
      return productDate.difference(now).inDays == 0;
    }).toList();
    List<Product> tommorow = products.where((Product product) {
      DateTime now = resetTime(DateTime.now());
      DateTime productDate = resetTime(
          DateTime.fromMillisecondsSinceEpoch(product.expirationDate * 1000));
      return productDate.difference(now).inDays == 1;
    }).toList();
    List<Product> dayAfterTommorow = products.where((Product product) {
      DateTime now = resetTime(DateTime.now());
      DateTime productDate = resetTime(
          DateTime.fromMillisecondsSinceEpoch(product.expirationDate * 1000));
      return productDate.difference(now).inDays == 2;
    }).toList();
    List<Product> thisWeek = products.where((Product product) {
      DateTime now = resetTime(DateTime.now());
      DateTime productDate = resetTime(
          DateTime.fromMillisecondsSinceEpoch(product.expirationDate * 1000));
      return productDate.difference(now).inDays <= 7 &&
          productDate.difference(now).inDays >= 3;
    }).toList();

    cards = [];
    cards.add(generateCard("Dzisiaj", today.length.toString(),
        today.length == 1 ? 'produkt' : 'produktów'));
    cards.add(generateCard("Jutro", tommorow.length.toString(),
        tommorow.length == 1 ? 'produkt' : 'produktów'));
    cards.add(generateCard("Pojutrze", dayAfterTommorow.length.toString(),
        dayAfterTommorow.length == 1 ? 'produkt' : 'produktów'));
    cards.add(generateCard("W tym tygodniu", thisWeek.length.toString(),
        thisWeek.length == 1 ? 'produkt' : 'produktów'));
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Podsumowanie dzienne")),
        body: SafeArea(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: <Widget>[
                Container(
                    height: constraints.maxHeight * (MediaQuery.of(context).orientation == Orientation.portrait?0.15:0.3),
                    child: Center(
                        child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Text(
                        DateTime.now().toIso8601String().split('T')[0],
                        style: TextStyle(
                            fontSize: 35,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      Text("Datę ważności kończy: ", style: TextStyle(fontSize: 15),)
                    ],
                  )
                ))),
                Container(
                  height: constraints.maxHeight * (MediaQuery.of(context).orientation == Orientation.portrait?0.85:0.7),
                  child: ListView.builder(
                    itemBuilder: (context, position) {
                      return Center(
                        child: Container(
                          width: constraints.maxWidth * 0.7,
                          child: cards[position],
                        ),
                      );
                    },
                    itemCount: cards.length,
                  ),
                )
              ],
            );
          },
        )));
  }
}
