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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  _onCreate(Database db, int version) async {
    var batch = db.batch();
    _createTableReportTypeV2(batch);
    _createTableCategoryV2(batch);
    _createTableReportImageV2(batch);
    _createTableReportV3(batch);
    await batch.commit();
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var batch = db.batch();
    if (oldVersion == 1) {
      await _createTableReportImageV2(batch);
    }
    if (oldVersion == 2) {
      await _createTableReportV3(batch);
      await _alterTableReportTypeV3(batch);
    }
    await batch.commit();
  }

  _createTableReportTypeV2(Batch batch) {
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

  _createTableCategoryV2(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS category");
    batch.execute('''CREATE TABLE category (
      id int PRIMARY KEY,
      name TEXT,      
      icon TEXT,
      ordering INT
    )''');
  }

  _createTableReportImageV2(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS report_image");
    batch.execute('''CREATE TABLE report_image (
      id TEXT PRIMARY KEY,
      reportId TEXT,
      image BLOB,
      submitted INT
    )''');
  }

  _createTableReportV3(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS report");
    batch.execute('''
      CREATE TABLE report (
        id TEXT PRIMARY KEY,
        data TEXT,
        report_type_id TEXT,
        incident_date TEXT,
        gps_location TEXT,
        submitted INT        
      )
    ''');
  }

  _alterTableReportTypeV3(Batch batch) {
    batch.execute("ALTER TABLE report_type add column submitted int");
  }
}
