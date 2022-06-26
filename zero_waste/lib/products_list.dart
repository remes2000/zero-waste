import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:zero_waste/change_notifieres/product_model.dart';
import 'package:zero_waste/globals.dart';
import 'package:zero_waste/models/product.dart' as prefix0;
import 'package:zero_waste/pages/product_preview.dart';
import 'package:zero_waste/utils/card.dart';

import 'models/product.dart';

class ProductsList extends StatefulWidget {
  final bool showOutOfDate;
  final bool showTodays;
  final bool showThisWeek;
  final bool showThisMonth;
  final bool showLater;
  final FlutterLocalNotificationsPlugin notifications;

  const ProductsList(
      {this.showOutOfDate,
      this.showTodays,
      this.showThisWeek,
      this.showThisMonth,
      this.showLater,
      this.notifications})
      : super();

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductsList> {
  @override
  void initState() {
    super.initState();
    getAllProducts().then((List<Product> products) {
      Provider.of<ProductModel>(context, listen: false).set(products);
    });
  }

  void deleteProduct(Product product) async {
    //First of all delete image file
    File image = File(product.imagePath);
    try {
      Provider.of<ProductModel>(context, listen: false).delete(product);
      if (await image.exists()) {
        await image.delete();
      }
      await prefix0.deleteProduct(product.id);
      //cancel notification
      await this.widget.notifications.cancel(product.id);
      this.setState(() {});
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Produkt został poprawnie usuniety"),
      ));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Wystąpił problem podczas usuwania produktu"),
      ));
      print(e);
    }
  }

  Widget renderListViewHeader(Product product) {
    DateTime now = resetTime(DateTime.now());
    DateTime productDate = resetTime(
        DateTime.fromMillisecondsSinceEpoch(product.expirationDate * 1000));
    if (productDate.difference(now).inDays < 0) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text("Przeterminowane :(",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent)),
      );
    } else if (productDate.difference(now).inDays == 0) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text("Dzisiaj",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.grey)),
      );
    } else if (productDate.difference(now).inDays <= 7) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text("W tym tygodniu",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.grey)),
      );
    } else if (productDate.month == now.month) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text("W tym miesiącu",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.grey)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text("Później",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductModel>(
      builder: (context, product, child) {
        List<Product> products = [];
        products.addAll(product.products);
        products.sort((Product p1, Product p2) {
          return p1.expirationDate - p2.expirationDate;
        });
        products = products.where((Product p) {
          if (isToday(p)) {
            return this.widget.showTodays;
          }
          if (isOutOfTime(p)) {
            return this.widget.showOutOfDate;
          }
          if (isThisWeek(p)) {
            return this.widget.showThisWeek;
          }
          if (isThisMonth(p)) {
            return this.widget.showThisMonth;
          }
          if (isLater(p)) {
            return this.widget.showLater;
          }
          return true;
        }).toList();
        List<Product> todays =
            products.where((Product product) => isToday(product)).toList();
        List<Product> outOfTime =
            products.where((Product product) => isOutOfTime(product)).toList();
        List<Product> thisWeek =
            products.where((Product product) => isThisWeek(product)).toList();
        List<Product> thisMonth =
            products.where((Product product) => isThisMonth(product)).toList();
        List<Product> later =
            products.where((Product product) => isLater(product)).toList();
        if (products.length == 0) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cloud_off,
                  size: 100,
                  color: Colors.grey,
                ),
                Text(
                  "Brak produktów do wyświetlenia",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                )
              ],
            ),
          );
        }
        return Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                  itemBuilder: (context, position) {
                    return Column(
                      children: <Widget>[
                        ((outOfTime.length > 0 &&
                                    outOfTime.first == products[position]) ||
                                (thisWeek.length > 0 &&
                                    thisWeek.first == products[position]) ||
                                (thisMonth.length > 0 &&
                                    thisMonth.first == products[position]) ||
                                (later.length > 0 &&
                                    later.first == products[position]) ||
                                (todays.length > 0 &&
                                    todays.first == products[position]))
                            ? renderListViewHeader(products[position])
                            : Container(),
                        Dismissible(
                          key: Key(UniqueKey().toString()),
                          onDismissed: (DismissDirection direction) {
                            deleteProduct(products[position]);
                          },
                          confirmDismiss: (DismissDirection direction) async {
                            final bool res = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Potwierdź"),
                                    content: Text(
                                        "Czy na pewno chcesz usunąć produkt?"),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text("Usuń"),
                                      ),
                                      FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("Anuluj"),
                                      )
                                    ],
                                  );
                                });
                            return res;
                          },
                          child: Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
                                      return ProductPreview(productId: products[position].id, notifications: this.widget.notifications,);
                                    }));
                                  },
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width *
                                        (MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? 0.8
                                            : 0.5)),
                                    child: generateProductCard(products[position])
                                  ))),
                        )
                      ],
                    );
                  },
                  itemCount: products.length),
            )
          ],
        );
      },
    );
  }
}
