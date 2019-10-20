import 'package:sqflite/sqflite.dart';
import 'package:zero_waste/database/database.dart';
import '../database/database.dart';
class Product{
  int id;
  int expirationDate;
  String imagePath;

  Product({this.id, this.expirationDate, this.imagePath});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'expiration_date': expirationDate,
      'image_path': imagePath
    };
  }
}

Future<void> deleteProduct(int id) async{
  final Database db = await getDatabase();
  await db.delete(
    'product', where: 'id = ?', whereArgs: [id]
  );
  return;
}

Future<Product> insertProduct(Product product) async{
  final Database db = await getDatabase();
  product.id = await db.insert(
    'product',
    product.toMap(),
  );
  return product;
}

Future<Product> updateProduct(Product product) async {
  final Database db = await getDatabase();
  await db.update('product', product.toMap(),
    where: 'id = ?', whereArgs: [product.id]);
  return product;
}

Future<List<Product>> getAllProducts() async{
  final Database db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query('product');
  return List.generate(maps.length, (i) {
    return Product(
      id: maps[i]['id'],
      expirationDate: maps[i]['expiration_date'],
      imagePath: maps[i]['image_path'],
    );
  });
}