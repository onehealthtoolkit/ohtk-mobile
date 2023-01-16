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
      version: 8,
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
    _createTableReportV5(batch);
    _createTableObservationDefinitionV1(batch);
    _createTableMonitoringDefinitionV1(batch);
    _createTableSubjectRecordV1(batch);
    _createTableMonitoringRecordV1(batch);
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
    if (oldVersion == 3) {
      await _alterTableReportV4(batch);
    }
    if (oldVersion == 4) {
      await _alterTableReportV5(batch);
    }
    if (oldVersion == 5) {
      await _alterTableReportTypeV6(batch);
    }
    if (oldVersion == 6) {
      await _createTableObservationDefinitionV1(batch);
      await _createTableMonitoringDefinitionV1(batch);
    }
    if (oldVersion == 7) {
      await _createTableSubjectRecordV1(batch);
      await _createTableMonitoringRecordV1(batch);
    }
    await batch.commit();
  }

  _createTableReportTypeV2(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS report_type");
    batch.execute('''CREATE TABLE report_type (
      id TEXT PRIMARY KEY,
      name TEXT,
      category_id INT,
      definition TEXT,
      followup_definition TEXT,
      ordering INT,
      updated_at TEXT
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

  _createTableReportV5(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS report");
    batch.execute('''
      CREATE TABLE report (
        id TEXT PRIMARY KEY,
        data TEXT,
        report_type_id TEXT,
        report_type_name TEXT,
        incident_date TEXT,
        gps_location TEXT,
        submitted INT,
        incident_in_authority BOOLEAN
      )
    ''');
  }

  _createTableObservationDefinitionV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS observation_definition");
    batch.execute('''CREATE TABLE observation_definition (
      id TEXT PRIMARY KEY,
      name TEXT,
      description TEXT,
      form_definition TEXT,
      updated_at TEXT,
      is_active INT
    )''');
  }

  _createTableMonitoringDefinitionV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS monitoring_definition");
    batch.execute('''CREATE TABLE monitoring_definition (
      id TEXT PRIMARY KEY,
      name TEXT,
      description TEXT,
      form_definition TEXT,
      updated_at TEXT,
      is_active INT,
      definition_id TEXT
    )''');
  }

  _createTableSubjectRecordV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS subject_record");
    batch.execute('''
      CREATE TABLE subject_record (
        id TEXT PRIMARY KEY,
        data TEXT,
        definition_id INT,
        record_date TEXT,
        gps_location TEXT
      )
    ''');
  }

  _createTableMonitoringRecordV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS monitoring_record");
    batch.execute('''
      CREATE TABLE monitoring_record (
        id TEXT PRIMARY KEY,
        data TEXT,
        monitoring_definition_id INT,
        subject_id TEXT
      )
    ''');
  }

  _alterTableReportTypeV3(Batch batch) {
    batch.execute("ALTER TABLE report_type add column submitted int");
  }

  _alterTableReportTypeV6(Batch batch) {
    batch
        .execute("ALTER TABLE report_type add column followup_definition TEXT");

    /// Old way to rename columns: categoryId, updatedAt
    /// Sqlite 3.25 supports 'Rename Column' query
    /// https://developer.android.com/reference/android/database/sqlite/package-summary
    batch.execute('''CREATE TABLE temp_report_type (
      id TEXT PRIMARY KEY,
      name TEXT,
      category_id INT,
      definition TEXT,
      followup_definition TEXT,
      ordering INT,
      updated_at TEXT
    )''');

    batch.execute('''INSERT INTO temp_report_type(
      id, name, category_id, definition, followup_definition, ordering, updated_at
      ) 
      SELECT id, name, categoryId, definition, followup_definition, ordering, updatedAt
      FROM report_type;

    ''');
    batch.execute("DROP TABLE report_type");
    batch.execute("ALTER TABLE temp_report_type RENAME TO report_type");
  }

  _alterTableReportV4(Batch batch) {
    batch
        .execute("ALTER TABLE report add column incident_in_authority BOOLEAN");
  }

  _alterTableReportV5(Batch batch) {
    batch.execute("ALTER TABLE report add column report_type_name TEXT");
  }
}
