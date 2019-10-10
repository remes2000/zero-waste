import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zero_waste/change_notifieres/product_model.dart';
import 'package:zero_waste/database/database.dart';
import 'package:zero_waste/models/product.dart';
import 'package:zero_waste/products_list.dart';
import 'pages/add_product.dart';
import 'models/product.dart';

void main(){
  runApp(ChangeNotifierProvider(
    builder: (context) => ProductModel(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroWaste',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage()
    );
  }
}

class HomePage extends StatelessWidget{
  void showProducts() async {
    List<Product> products = await getAllProducts();
    products.forEach((Product p) {
      print(p.toMap());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zero Waste')
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
             height: constraints.maxHeight,
             width: constraints.maxWidth,
              child: ProductsList(),
            );
          },
        ),
      ),
      /*
      body: Column(
        children: <Widget>[
          /*
          FlatButton(
            child: Text("Clear Database"),
            color: Colors.blue,
            onPressed: () async {
              Database db = await getDatabase();
              db.delete("product");
            },
          ),*/
          ProductsList()
        ],
      ),*/
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showProducts();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return AddProduct();
              }
            )
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
