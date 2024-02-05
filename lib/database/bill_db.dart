import 'package:bill_cal/classes/categories_rate.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  // TODO: extract logger logic maybe
  final logger = Logger(
      printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 3,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    printTime: false,
  ));
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

  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  initDb() async {
    // the following line is for development purposes only
    // ****************************************************************
    // databaseFactory
    //     .deleteDatabase(join(await getDatabasesPath(), 'bill_database.db'));
    // ****************************************************************
    final billDb = await openDatabase(
      join(await getDatabasesPath(), 'bill_database.db'),
      onConfigure: onConfigure,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE Category(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, hasFlatRate INTEGER);');
        await db.execute(
            'CREATE TABLE Rate(id INTEGER PRIMARY KEY AUTOINCREMENT, priority INTEGER, units INTEGER, rate double, fk_category_id, FOREIGN KEY (fk_category_id) REFERENCES Category (id) ON DELETE CASCADE);');
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
          'units': c.rates[i].units,
          'rate': c.rates[i].rate,
          'fk_category_id': categoryId,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  deleteCategory(String categoryName) async {
    var dbClient = await db;
    await dbClient.rawQuery(
        'DELETE FROM Category WHERE Category.name = (?)', [categoryName]);
  }

  Future<Map<String, Category>> getCategories() async {
    var dbClient = await db;
    var categories = await dbClient.rawQuery('''
      SELECT Category.name, Category.hasFlatRate, Rate.priority, Rate.units, Rate.rate
        FROM Category
      INNER JOIN Rate 
        ON Category.id = Rate.fk_category_id
      ORDER BY
        Category.name ASC,
        Rate.priority ASC;
    ''');

    // TODO: remove the following logs
    logger.i('categories: $categories');
    return toMap(categories);
  }

  getRates() async {
    var dbClient = await db;
    var rates = await dbClient.rawQuery('SELECT * FROM Rate');
    logger.i('rates: $rates');
  }

  Map<String, Category> toMap(categories) {
    Map<String, Category> initialValue = {};
    var categoriesGroupedByName = categories.fold<Map<String, Category>>(
      initialValue,
      (previousValue, element) {
        Map<String, Category> val = previousValue;
        String categoryName = element['name'];
        if (!val.containsKey(categoryName)) {
          val[categoryName] = Category(
              name: categoryName,
              hasFlatRate: element['hasFlatRate'] == 1,
              rates: <Rate>[]);
        }
        val[categoryName]!
            .rates
            .add(Rate(units: element['units'], rate: element['rate']));
        return val;
      },
    );
    return categoriesGroupedByName;
  }
}
