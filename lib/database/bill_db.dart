import 'package:bill_cal/classes/categories_rate.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    // the following line is for development purposes only
    // ****************************************************************
    databaseFactory
        .deleteDatabase(join(await getDatabasesPath(), 'bill_database.db'));
    // ****************************************************************
    final billDb = await openDatabase(
      join(await getDatabasesPath(), 'bill_database.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE Category(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, hasFlatRate INTEGER);');
        await db.execute(
            'CREATE TABLE Rate(id INTEGER PRIMARY KEY AUTOINCREMENT, priority INTEGER, units INTEGER, rate double, fk_category_id, FOREIGN KEY (fk_category_id) REFERENCES Category (id));');
      },
      version: 1,
    );
    // var tables = await billDb.rawQuery(
    //     "SELECT name from sqlite_schema where type in ('table', 'view')");
    return billDb;
  }

  addCategory(Category c) async {
    var dbClient = await db;

    await dbClient.transaction((txn) async {
      int categoryId = await txn.rawInsert(
          'INSERT INTO Category(name, hasFlatRate) VALUES (?,?)',
          [c.name, c.hasFlatRate == true]);

      var batch = txn.batch();
      for (var i = 0; i < c.rates.length; i++) {
        batch.insert('Rate', {
          'priority': i + 1,
          'units': c.rates[i].endUnits - c.rates[i].startUnits + 1,
          'rate': c.rates[i].rate,
          'fk_category_id': categoryId,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  getCategories() async {
    var dbClient = await db;
    var categories = await dbClient.rawQuery('''
      SELECT Category.name, Category.hasFlatRate, Rate.priority, Rate.units, Rate.rate
      FROM Category
      INNER JOIN Rate ON Category.id = Rate.fk_category_id
    ''');
    return categories;
  }
}
