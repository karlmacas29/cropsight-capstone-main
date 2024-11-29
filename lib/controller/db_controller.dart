import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CropSightDatabase {
  static final CropSightDatabase _instance = CropSightDatabase._internal();
  static Database? _database;
  static const String insectListTable = 'insectList';
  static const String insectManageTable = 'insectManage';
  static const String scanningHistory = 'scanningHistory';

  CropSightDatabase._internal();

  factory CropSightDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'cropsight.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create insectList table
    await db.execute('''
      CREATE TABLE $insectListTable (
        insectID INTEGER PRIMARY KEY,
        insectName TEXT,
        insectPic TEXT,
        insectDesc TEXT,
        insectWhere TEXT,
        insectDamage TEXT
      )
    ''');

    // Create insectManage table
    await db.execute('''
      CREATE TABLE $insectManageTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        insectId INTEGER,
        insectName TEXT,
        insectPic TEXT,
        cultureMn TEXT,
        biologicalMn TEXT,
        chemicalMn TEXT,
        FOREIGN KEY (insectId) REFERENCES $insectListTable (insectID)
      )
    ''');

    //Create scanHistory table
    await db.execute('''
      CREATE TABLE $scanningHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        insectId INTEGER,
        insectName TEXT,
        insectDamage TEXT,
        insectPic TEXT,
        insectPercent TEXT,
        location TEXT,
        month TEXT,
        year TEXT,
        FOREIGN KEY (insectId) REFERENCES $insectListTable (insectID)
      )
    ''');
  }

  Future<Map<String, dynamic>> loadJsonData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/resources/cropsight.json');
      return json.decode(jsonString);
    } catch (e) {
      print('Error loading JSON data: $e');
      throw Exception('Failed to load cropsight.json: $e');
    }
  }

  // Check if data exists in insectList table
  Future<bool> isInsectListEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $insectListTable'));
    return count == 0;
  }

  // Check if data exists in insectManage table
  Future<bool> isInsectManageEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $insectManageTable'));
    return count == 0;
  }

  // Clear all data from tables
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(
        insectManageTable); // Delete from manage first due to foreign key
    await db.delete(insectListTable);
  }

  // Insert data into insectList table with check
  Future<void> insertInsectList(Map<String, dynamic> insect) async {
    final db = await database;
    try {
      // Check if this specific insect already exists
      final existing = await db.query(
        insectListTable,
        where: 'insectID = ?',
        whereArgs: [insect['insectID']],
      );

      if (existing.isEmpty) {
        await db.insert(
          insectListTable,
          {
            'insectID': insect['insectID'],
            'insectName': insect['insectName'],
            'insectPic': insect['insectPic'],
            'insectDesc': insect['insectDesc'],
            'insectWhere': insect['insectWhere'],
            'insectDamage': insect['insectDamage'],
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('Inserted insect: ${insect['insectName']}');
      } else {
        print(
            'Insect ${insect['insectName']} already exists, skipping insertion');
      }
    } catch (e) {
      print('Error inserting insect: $e');
      throw Exception('Failed to insert insect data: $e');
    }
  }

  // Insert data into insectManage table with check
  Future<void> insertInsectManage(Map<String, dynamic> manage) async {
    final db = await database;
    try {
      // Check if management data already exists for this insect
      final existing = await db.query(
        insectManageTable,
        where: 'insectId = ?',
        whereArgs: [manage['insectId']],
      );

      if (existing.isEmpty) {
        await db.insert(
          insectManageTable,
          {
            'insectId': manage['insectId'],
            'insectName': manage['insectName'],
            'insectPic': manage['insectPic'],
            'cultureMn': json.encode(manage['cultureMn']),
            'biologicalMn': json.encode(manage['biologicalMn']),
            'chemicalMn': json.encode(manage['chemicalMn']),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('Inserted management for: ${manage['insectName']}');
      } else {
        print(
            'Management data for ${manage['insectName']} already exists, skipping insertion');
      }
    } catch (e) {
      print('Error inserting management data: $e');
      throw Exception('Failed to insert management data: $e');
    }
  }

  // Updated populate database function with checks
  Future<void> populateDatabase() async {
    try {
      final bool isInsectEmpty = await isInsectListEmpty();
      final bool isManageEmpty = await isInsectManageEmpty();

      // Only populate if both tables are empty
      if (isInsectEmpty && isManageEmpty) {
        final jsonData = await loadJsonData();
        final cropsightData = jsonData['cropsightData'];

        // Insert insect list data
        for (var insect in cropsightData['insectList']) {
          await insertInsectList(insect);
        }

        // Insert insect management data
        for (var manage in cropsightData['insectManage']) {
          await insertInsectManage(manage);
        }

        print('Initial database population completed');
      } else {
        print('Database already contains data, skipping population');
      }
    } catch (e) {
      print('Error populating database: $e');
      throw Exception('Failed to populate database: $e');
    }
  }

  // Helper function to get all insects
  Future<List<Map<String, dynamic>>> getAllInsects() async {
    final db = await database;
    try {
      final insects = await db.query(
        insectListTable,
        orderBy: 'insectID',
      );
      print('Retrieved ${insects.length} insects');
      return insects;
    } catch (e) {
      print('Error getting insects: $e');
      throw Exception('Failed to get insects: $e');
    }
  }

  // Helper function to get management data for specific insect
  Future<Map<String, dynamic>?> getInsectManagement(int insectId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        insectManageTable,
        where: 'insectId = ?',
        whereArgs: [insectId],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      print('Error getting insect management: $e');
      throw Exception('Failed to get insect management: $e');
    }
  }

  //
  Future<Map<String, dynamic>?> getInsectID(int insectId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        insectListTable,
        where: 'insectID = ?',
        whereArgs: [insectId],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      print('Error getting insect management: $e');
      throw Exception('Failed to get insect management: $e');
    }
  }

  // Helper function to decode JSON strings from database
  Map<String, dynamic> decodeManagementData(
      Map<String, dynamic> managementData) {
    return {
      ...managementData,
      'cultureMn': managementData['cultureMn'] != null
          ? json.decode(managementData['cultureMn'])
          : [],
      'biologicalMn': managementData['biologicalMn'] != null
          ? json.decode(managementData['biologicalMn'])
          : [],
      'chemicalMn': managementData['chemicalMn'] != null
          ? json.decode(managementData['chemicalMn'])
          : [],
      // 'cultureMn': json.decode(managementData['cultureMn']),
      // 'biologicalMn': json.decode(managementData['biologicalMn']),
      // 'chemicalMn': json.decode(managementData['chemicalMn']),
    };
  }

  // Insert data into scanningHistory table
  Future<int> insertScanningHistory(Map<String, dynamic> data) async {
    final db = await database; // Ensure database is initialized
    return await db.insert(
      scanningHistory, // Table name
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch data from scanningHistory with sorting and limit
  Future<List<Map<String, dynamic>>> getScanningHistory(
      {String sortBy = 'latest', int limit = 10}) async {
    final db = await database;

    // Determine sort order based on user selection
    String orderByClause;
    switch (sortBy) {
      case 'year':
        orderByClause = 'year DESC';
        break;
      case 'month':
        orderByClause = 'month DESC';
        break;
      default: // Default is 'latest'
        orderByClause = 'id DESC';
    }

    // Limit query
    String queryLimit =
        limit > 0 ? 'LIMIT $limit' : ''; // No limit if 'all' selected

    // Execute query
    return await db.rawQuery(
        'SELECT * FROM $scanningHistory ORDER BY $orderByClause $queryLimit');
  }

  //
  Future<int> countEntriesByYear(String targetYear) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries with the given year
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $scanningHistory WHERE year = ?',
      [targetYear], // Use parameterized query to prevent SQL injection
    );

    // Extract the count value from the query result
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<String> countEntriesByMonth(String targetMonth) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries with the given month
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $scanningHistory WHERE month = ?',
      [targetMonth], // Use parameterized query to prevent SQL injection
    );

    // Extract the count value from the query result
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count.toString(); // Convert the count to a string
  }

  Future<String> countEntriesByLocation(String targetLocation) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries with the given location
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $scanningHistory WHERE location = ?',
      [targetLocation], // Use parameterized query to prevent SQL injection
    );

    // Extract the count value from the query result
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count.toString(); // Convert the count to a string
  }
}
