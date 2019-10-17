import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:zero_waste/globals.dart';
import 'package:zero_waste/models/product.dart';

class ProductModel extends ChangeNotifier{
  final List<Product> _products = [];
  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);

  void add(Product product){
    _products.add(product);
    notifyListeners();
  }

  void set(List<Product> products){
    _products.clear();
    _products.addAll(products);
    notifyListeners();
  }

  void addAll(List<Product> products){
    _products.addAll(products);
    notifyListeners();
  }

  void delete(Product product){
    _products.removeAt(_products.indexOf(product));
    notifyListeners();
  }
}