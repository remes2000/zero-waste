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

  Widget renderDate(Product product){
    DateTime date = resetTime(DateTime.fromMillisecondsSinceEpoch(product.expirationDate*1000));
    DateTime now = resetTime(DateTime.now());
    DateTime weekInFuture = resetTime(DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch).add(Duration(days: 7)));
    String content = "";
    if(date.isAfter(weekInFuture)){
      content = date.toIso8601String().split("L")[0];
    } else {
      content = date.difference(now).inDays.toString() + ' dni';
    }
    return Padding(
      padding: const EdgeInsets.all(7),
      child: Text(content,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
    );
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
                    return Align(
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
                                  child: Text("Data ważności: ", textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
                                ),
                                renderDate(product.products[position])
                              ],
                            )
                          ),
                        )
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
