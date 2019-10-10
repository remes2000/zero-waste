import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zero_waste/change_notifieres/product_model.dart';
import 'package:zero_waste/globals.dart';

import 'models/product.dart';

class ProductsList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductsList> {
  @override
  void initState() {
    super.initState();
    getAllProducts().then((List<Product> products) {
      Provider.of<ProductModel>(context).addAll(products);
    });
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
      if(daysDifference == 0){
        content = "Ostatni dzień przydatności";
      } else if(daysDifference < 0){
        content = "Produkt przeterminowany :(";
      } else {
        content = daysDifference.toString() + (daysDifference==1?' dzień':' dni');
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

  void deleteProduct(Product product){
    //First of all delete image file

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductModel>(
      builder: (context, product, child) {
        if (product.products.length == 0) return Container();
        return Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                  itemBuilder: (context, position) {
                    return Dismissible(
                      key: Key(product.products[position].id.toString()),
                      confirmDismiss: (DismissDirection direction) async {
                        final bool res = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Potwierdź"),
                              content: Text("Czy na pewno chcesz usunąć produkt?"),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text("Usuń"),
                                ),
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("Anuluj"),
                                )
                              ],
                            );
                          }
                        );
                        return res;
                      },
                      child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Card(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Image.file(
                                  File(product.products[position].imagePath),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Text("Data ważności: ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18)),
                                ),
                                renderDate(product.products[position])
                              ],
                            )),
                          )),
                    );
                  },
                  itemCount: product.products.length),
            )
          ],
        );
      },
    );
  }
}
