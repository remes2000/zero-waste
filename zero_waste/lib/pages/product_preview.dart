import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero_waste/models/product.dart';
import 'package:zero_waste/utils/card.dart';

class ProductPreview extends StatefulWidget {
  final int productId;

  ProductPreview({@required this.productId});

  @override
  _ProductPreviewState createState() => _ProductPreviewState();
}

class _ProductPreviewState extends State<ProductPreview> {
  Product product;

  void getProduct() async {
    product = await getProductById(this.widget.productId);
    this.setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Container();

    if (this.product != null) {
      widget = generateProductCard(product);
    }

    //SafeArea(child: new LayoutBuilder(
    //      builder: (BuildContext context, BoxConstraints constraints) {

    return Scaffold(
      appBar: AppBar(title: Text("Podgląd produktu")),
      body: Container(child: SafeArea(
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constrains) {
            return Center(
              child: Container(
                width: 0.8 * constrains.maxWidth,
                child: widget,
              ),
            );
          },
        ),
      )),
    );
  }
}
