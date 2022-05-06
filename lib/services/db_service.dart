import 'package:sqflite/sqflite.dart';

abstract class IDbService {
  Database get db;
}

class DbService extends IDbService {
  late Database _db;

  @override
  Database get db => _db;

  init() async {
    // follow this migration pattern https://github.com/tekartik/sqflite/blob/master/sqflite/doc/migration_example.md
    _db = await openDatabase(
      'podd.db',
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  _onCreate(Database db, int version) async {
    var batch = db.batch();
    _createTableReportTypeV1(batch);
    _createTableCategoryV1(batch);
    await batch.commit();
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  _createTableReportTypeV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS report_type");
    batch.execute('''CREATE TABLE report_type (
      id TEXT PRIMARY KEY,
      name TEXT,
      categoryId INT,
      definition TEXT,
      ordering INT,
      updatedAt TEXT
    )''');
  }

  _createTableCategoryV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS category");
    batch.execute('''CREATE TABLE category (
      id int PRIMARY KEY,
      name TEXT,      
      icon TEXT,
      ordering INT
    )''');
  }
}
