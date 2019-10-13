import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDatabase() async{
  return openDatabase(
    join(await getDatabasesPath(), 'zero_waste_database1.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE product(id INTEGER PRIMARY KEY, image_path TEXT, expiration_date INTEGER)",
      );
    },
    version: 1
  );
}
