import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationRecord {
  final int? id;
  final String timestamp;
  final double latitude;
  final double longitude;

  LocationRecord({
    this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });

  // Convert a LocationRecord into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Implement toString to make it easier to see information about
  // each record when using the print statement.
  @override
  String toString() {
    return 'LocationRecord{id: $id, timestamp: $timestamp, latitude: $latitude, longitude: $longitude}';
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('location_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE records (
  id $idType,
  timestamp $textType,
  latitude $realType,
  longitude $realType
)
''');
  }

  Future<LocationRecord> create(LocationRecord record) async {
    final db = await instance.database;
    final id = await db.insert('records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<LocationRecord>> getRecentRecords({int limit = 10}) async {
    final db = await instance.database;
    final maps = await db.query(
      'records',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    if (maps.isNotEmpty) {
      return maps
          .map(
            (json) => LocationRecord(
              id: json['id'] as int,
              timestamp: json['timestamp'] as String,
              latitude: json['latitude'] as double,
              longitude: json['longitude'] as double,
            ),
          )
          .toList();
    } else {
      return [];
    }
  }

  Future<List<LocationRecord>> getRecordsByDate(DateTime date) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().substring(
      0,
      10,
    ); // Format to YYYY-MM-DD

    final maps = await db.query(
      'records',
      where: 'substr(timestamp, 1, 10) = ?',
      whereArgs: [dateString],
      orderBy: 'timestamp DESC',
    );

    if (maps.isNotEmpty) {
      return maps
          .map(
            (json) => LocationRecord(
              id: json['id'] as int,
              timestamp: json['timestamp'] as String,
              latitude: json['latitude'] as double,
              longitude: json['longitude'] as double,
            ),
          )
          .toList();
    } else {
      return [];
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

extension LocationRecordCopyWith on LocationRecord {
  LocationRecord copyWith({int? id}) {
    return LocationRecord(
      id: id ?? this.id,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
