import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zero_waste/local_notifications_helper.dart';
import 'package:zero_waste/models/product.dart';
import 'package:zero_waste/utils/card.dart';

class ProductPreview extends StatefulWidget {
  final int productId;
  final FlutterLocalNotificationsPlugin notifications;

  ProductPreview({@required this.productId, @required this.notifications});

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

  void showNotification() async {
    await showLoudBigPictureNotification(this.widget.notifications,
        title: 'Data ważności jednego z produktów kończy się dzisiaj',
        body: "Kliknij w powiadomienie aby zobaczyć szczegóły",
        payload: product.id.toString(),
        id: product.id * -1,
        bigPictureStyleInformation: BigPictureStyleInformation(
            product.imagePath, BitmapSource.FilePath));
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Container();

    if (this.product != null) {
      widget = Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
                  itemBuilder: (context, position) {
                    return Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: generateProductCard(product),
                    );
                  },
                  itemCount: 1))
        ],
      );
    }

    //SafeArea(child: new LayoutBuilder(
    //      builder: (BuildContext context, BoxConstraints constraints) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Podgląd produktu"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              showNotification();
            },
          )
        ],
      ),
      body: Container(child: SafeArea(
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constrains) {
            return Center(
              child: Container(
                width: (MediaQuery.of(context).size.width *
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0.8
                        : 0.5)),
                child: widget,
              ),
            );
          },
        ),
      )),
    );
  }
}
