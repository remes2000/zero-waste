import 'package:flutter/material.dart';
import '../camera.dart';

class AddProduct extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Dodaj produkt')
      ),
      body: CameraWidget(),
    );
  }
}