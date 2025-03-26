import 'dart:convert';
import 'package:cropsight/views/pages/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CropSightDatabase {
  static final CropSightDatabase _instance = CropSightDatabase._internal();
  static Database? _database;

  static const String insectListTable = 'insectList';
  static const String insectManageTable = 'insectManage';
  //
  static const String insectListTableCB = 'insectListCB';
  static const String insectManageTableCB = 'insectManageCB';
  //
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

    await db.execute('''
      CREATE TABLE $insectListTableCB (
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
      CREATE TABLE $insectManageTableCB (
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
        isSynced INTEGER DEFAULT 0,
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
      debugPrint('Error loading JSON data: $e');
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

  //cb
  Future<Map<String, dynamic>> loadJsonDataCB() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/resources/cropsight-cebuano.json');
      return json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading JSON data: $e');
      throw Exception('Failed to load cropsight.json: $e');
    }
  }

  //cb
  Future<bool> isInsectListEmptyCB() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $insectListTableCB'));
    return count == 0;
  }

  //cb
  Future<bool> isInsectManageEmptyCB() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $insectManageTableCB'));
    return count == 0;
  }

  // Clear all data from tables
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(
        insectManageTable); // Delete from manage first due to foreign key
    await db.delete(insectListTable);
    await db.delete(
        insectManageTableCB); // Delete from manage first due to foreign key
    await db.delete(insectListTableCB);
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
        debugPrint('Inserted insect: ${insect['insectName']}');
      } else {
        debugPrint(
            'Insect ${insect['insectName']} already exists, skipping insertion');
      }
    } catch (e) {
      debugPrint('Error inserting insect: $e');
      throw Exception('Failed to insert insect data: $e');
    }
  }

  // ceb
  Future<void> insertInsectListCB(Map<String, dynamic> insect) async {
    final db = await database;
    try {
      // Check if this specific insect already exists
      final existing = await db.query(
        insectListTableCB,
        where: 'insectID = ?',
        whereArgs: [insect['insectID']],
      );

      if (existing.isEmpty) {
        await db.insert(
          insectListTableCB,
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
        debugPrint('Inserted insect: ${insect['insectName']}');
      } else {
        debugPrint(
            'Insect ${insect['insectName']} already exists, skipping insertion');
      }
    } catch (e) {
      debugPrint('Error inserting insect: $e');
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
        debugPrint('Inserted management for: ${manage['insectName']}');
      } else {
        debugPrint(
            'Management data for ${manage['insectName']} already exists, skipping insertion');
      }
    } catch (e) {
      debugPrint('Error inserting management data: $e');
      throw Exception('Failed to insert management data: $e');
    }
  }

// cb
  Future<void> insertInsectManageCB(Map<String, dynamic> manage) async {
    final db = await database;
    try {
      // Check if management data already exists for this insect
      final existing = await db.query(
        insectManageTableCB,
        where: 'insectId = ?',
        whereArgs: [manage['insectId']],
      );

      if (existing.isEmpty) {
        await db.insert(
          insectManageTableCB,
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
        debugPrint('Inserted management for: ${manage['insectName']}');
      } else {
        debugPrint(
            'Management data for ${manage['insectName']} already exists, skipping insertion');
      }
    } catch (e) {
      debugPrint('Error inserting management data: $e');
      throw Exception('Failed to insert management data: $e');
    }
  }

  // Updated populate database function with checks
  Future<void> populateDatabase() async {
    try {
      final bool isInsectEmpty = await isInsectListEmpty();
      final bool isManageEmpty = await isInsectManageEmpty();

      final bool isInsectEmptyCB = await isInsectListEmptyCB();
      final bool isManageEmptyCB = await isInsectManageEmptyCB();

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

        debugPrint('Initial database population completed');
      } else {
        debugPrint('Database already contains data, skipping population');
      }

      // Only populate if both tables are empty
      if (isInsectEmptyCB && isManageEmptyCB) {
        final jsonData = await loadJsonDataCB();
        final cropsightData = jsonData['cropsightData'];

        // Insert insect list data
        for (var insect in cropsightData['insectList']) {
          await insertInsectListCB(insect);
        }

        // Insert insect management data
        for (var manage in cropsightData['insectManage']) {
          await insertInsectManageCB(manage);
        }

        debugPrint('Initial database population completed Cebuano Ver');
      } else {
        debugPrint(
            'Database already contains data, skipping population Cebuano Ver');
      }
    } catch (e) {
      debugPrint('Error populating database: $e');
      throw Exception('Failed to populate database: $e');
    }
  }

  // Helper function to get all insects
  Future<List<Map<String, dynamic>>> getAllInsects() async {
    final db = await database;
    final LanguagePreference languagePreference = LanguagePreference();
    var currentLanguage = languagePreference.languageCode;
    String insectListT = 'insectList';

    if (currentLanguage == 'cb') {
      insectListT = 'insectListCB';
    }

    try {
      final insects = await db.query(
        insectListT,
        orderBy: 'insectID',
      );
      debugPrint('Retrieved ${insects.length} insects');
      return insects;
    } catch (e) {
      debugPrint('Error getting insects: $e');
      throw Exception('Failed to get insects: $e');
    }
  }

  // Helper function to get management data for specific insect
  Future<Map<String, dynamic>?> getInsectManagement(int insectId) async {
    final db = await database;
    final LanguagePreference languagePreference = LanguagePreference();
    var currentLanguage = languagePreference.languageCode;
    String insectManageT = 'insectManage';

    if (currentLanguage == 'cb') {
      insectManageT = 'insectManageCB';
    }
    try {
      final List<Map<String, dynamic>> results = await db.query(
        insectManageT,
        where: 'insectId = ?',
        whereArgs: [insectId],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting insect management: $e');
      throw Exception('Failed to get insect management: $e');
    }
  }

  //
  Future<Map<String, dynamic>?> getInsectID(int insectId) async {
    final db = await database;
    final LanguagePreference languagePreference = LanguagePreference();
    var currentLanguage = languagePreference.languageCode;
    String insectListT = 'insectList';

    if (currentLanguage == 'cb') {
      insectListT = 'insectListCB';
    }
    try {
      final List<Map<String, dynamic>> results = await db.query(
        insectListT,
        where: 'insectID = ?',
        whereArgs: [insectId],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting insect management: $e');
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

  //sync to online supabase
  Future<List<Map<String, dynamic>>> getUnsyncedScans() async {
    final db = await database;
    return await db
        .query('scanningHistory', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'scanningHistory',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch data from scanningHistory with sorting and limit
  Future<List<Map<String, dynamic>>> getScanningHistory({
    String sortBy = 'latest',
    int limit = 10,
    String location = 'Panabo', // Add an optional location parameter
  }) async {
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
    String queryLimit = (limit > 0) ? 'LIMIT $limit' : ''; // No LIMIT if -1

    // Build the query with optional location filter
    String query;
    List<dynamic> queryArgs = [];

    query =
        'SELECT * FROM $scanningHistory WHERE location = ? ORDER BY $orderByClause $queryLimit';
    queryArgs.add(location);

    // Execute the query with or without location filter
    return await db.rawQuery(query, queryArgs);
  }

  //Reports that based on history

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

  Future<String> countEntriesByMonth(
      String targetMonth, String targetYear) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries with the given month and year
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $scanningHistory WHERE month = ? AND year = ?',
      [
        targetMonth,
        targetYear
      ], // Use parameterized query to prevent SQL injection
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

  // based on month
  Future<Map<String, int>> countEntriesByLocationAndInsect(
      String location, String month, String year) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries for each insectName with the given location, month, and year
    final result = await db.rawQuery('''
    SELECT
      SUM(CASE WHEN insectName = 'Stem Borer' THEN 1 ELSE 0 END) AS StemBorerCount,
      SUM(CASE WHEN insectName = 'Green Leafhopper' THEN 1 ELSE 0 END) AS GreenLeafhopperCount,
      SUM(CASE WHEN insectName = 'Rice Bugs' THEN 1 ELSE 0 END) AS RiceBugCount,
      SUM(CASE WHEN insectName = 'Rice Leaffolder' THEN 1 ELSE 0 END) AS GreenLeaffolderCount
    FROM $scanningHistory
    WHERE location = ? AND month = ? AND year = ?
  ''', [location, month, year]);

    // Extract the counts from the query result
    return {
      'Stem Borer': result[0]['StemBorerCount'] as int? ?? 0,
      'Green Leafhopper': result[0]['GreenLeafhopperCount'] as int? ?? 0,
      'Rice Bugs': result[0]['RiceBugCount'] as int? ?? 0,
      'Green leaffolder': result[0]['GreenLeaffolderCount'] as int? ?? 0,
    };
  }

  //based on year
  Future<Map<String, int>> countEntriesByLocationAndInsectForYear(
      String location, String year) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries for each insectName with the given location and year
    final result = await db.rawQuery('''
    SELECT
      SUM(CASE WHEN insectName = 'Stem Borer' THEN 1 ELSE 0 END) AS StemBorerCount,
      SUM(CASE WHEN insectName = 'Green Leafhopper' THEN 1 ELSE 0 END) AS GreenLeafHopperCount,
      SUM(CASE WHEN insectName = 'Rice Bugs' THEN 1 ELSE 0 END) AS RiceBugCount,
      SUM(CASE WHEN insectName = 'Rice Leaffolder' THEN 1 ELSE 0 END) AS GreenLeaffolderCount
    FROM $scanningHistory
    WHERE location = ? AND year = ?
  ''', [location, year]);

    // Extract the counts from the query result
    return {
      'Stem Borer': result[0]['StemBorerCount'] as int? ?? 0,
      'Green Leafhopper': result[0]['GreenLeafHopperCount'] as int? ?? 0,
      'Rice Bugs': result[0]['RiceBugCount'] as int? ?? 0,
      'Green leaffolder': result[0]['GreenLeaffolderCount'] as int? ?? 0,
    };
  }

  Future<String> countEntriesByLocationAndMonth(
      String location, String month) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries with the given location and month
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $scanningHistory WHERE location = ? AND month = ?',
      [location, month], // Use parameterized query to prevent SQL injection
    );

    // Extract the count value from the query result
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count.toString(); // Convert the count to a string
  }

  Future<String> countEntriesByLocationAndYear(
      String location, String year) async {
    final db = await database; // Access the database instance

    // Perform the query to count entries with the given location and year
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $scanningHistory WHERE location = ? AND year = ?',
      [location, year], // Use parameterized query to prevent SQL injection
    );

    // Extract the count value from the query result
    int count = Sqflite.firstIntValue(result) ?? 0; // Default to 0 if null
    return count.toString(); // Convert the count to a string
  }

  // Method to delete a specific scanning history entry by its ID
  Future<int> deleteScanningHistoryEntry(int id) async {
    final db = await database; // Ensure database is initialized
    try {
      // Delete the entry with the matching ID from scanningHistory table
      int deletedCount = await db.delete(
        scanningHistory, // Table name
        where: 'id = ?', // Condition to match the specific ID
        whereArgs: [id], // Pass the ID as an argument
      );

      if (deletedCount > 0) {
        debugPrint('Deleted scanning history entry with ID: $id');
      } else {
        debugPrint('No scanning history entry found with ID: $id');
      }

      return deletedCount; // Return the number of rows deleted
    } catch (e) {
      debugPrint('Error deleting scanning history entry: $e');
      throw Exception('Failed to delete scanning history entry: $e');
    }
  }
}

class OnlineDatabase {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> signInAnonymously() async {
    bool isConnected = await InternetConnectionChecker.instance.hasConnection;

    if (isConnected) {
      try {
        final response = await _supabase.auth.signInAnonymously();
        if (response.user != null) {
          debugPrint("Signed in as Guest: ${response.user!.id}");
          return "Signed in as Guest";
        }
      } catch (e) {
        debugPrint("Failed to sign in anonymously: $e");
      }
    }

    return "No internet connection";
  }

  Future<void> uploadScan(Map<String, dynamic> scan) async {
    await _supabase.from('scanningHistory').insert({
      'insectId': scan['insectId'],
      'insectName': scan['insectName'],
      'insectDamage': scan['insectDamage'],
      'insectPic': scan['insectPic'],
      'insectPercent': scan['insectPercent'],
      'location': scan['location'],
      'month': scan['month'],
      'year': scan['year'],
    });
  }

  // Count entries by year
  Future<int> countEntriesByYear(String targetYear) async {
    final response = await _supabase
        .from('scanningHistory')
        .select('id')
        .eq('year', targetYear)
        .count(CountOption.exact);

    return response.count;
  }

  // Count entries by month and year
  Future<String> countEntriesByMonth(
      String targetMonth, String targetYear) async {
    final response = await _supabase
        .from('scanningHistory')
        .select('id')
        .eq('month', targetMonth)
        .eq('year', targetYear)
        .count(CountOption.exact);

    return (response.count).toString();
  }

  // Count entries by location
  Future<String> countEntriesByLocation(String targetLocation) async {
    final response = await _supabase
        .from('scanningHistory')
        .select('id')
        .eq('location', targetLocation)
        .count(CountOption.exact);

    return (response.count).toString();
  }

  // Count entries by location, month, and year for specific insects
  Future<Map<String, int>> countEntriesByLocationAndInsect(
      String location, String month, String year) async {
    final response = await _supabase
        .from('scanningHistory')
        .select('insectName')
        .eq('location', location)
        .eq('month', month)
        .eq('year', year);

    // Count occurrences of each insect
    int stemBorerCount =
        response.where((entry) => entry['insectName'] == 'Stem Borer').length;
    int greenLeafhopperCount = response
        .where((entry) => entry['insectName'] == 'Green Leafhopper')
        .length;
    int riceBugCount =
        response.where((entry) => entry['insectName'] == 'Rice Bugs').length;
    int greenLeaffolderCount = response
        .where((entry) => entry['insectName'] == 'Rice Leaffolder')
        .length;

    return {
      'Stem Borer': stemBorerCount,
      'Green Leafhopper': greenLeafhopperCount,
      'Rice Bugs': riceBugCount,
      'Green leaffolder': greenLeaffolderCount,
    };
  }

  // Count entries by location and year for specific insects
  Future<Map<String, int>> countEntriesByLocationAndInsectForYear(
      String location, String year) async {
    final response = await _supabase
        .from('scanningHistory')
        .select('insectName')
        .eq('location', location)
        .eq('year', year);

    // Count occurrences of each insect
    int stemBorerCount =
        response.where((entry) => entry['insectName'] == 'Stem Borer').length;
    int greenLeafhopperCount = response
        .where((entry) => entry['insectName'] == 'Green Leafhopper')
        .length;
    int riceBugCount =
        response.where((entry) => entry['insectName'] == 'Rice Bugs').length;
    int greenLeaffolderCount = response
        .where((entry) => entry['insectName'] == 'Rice Leaffolder')
        .length;

    return {
      'Stem Borer': stemBorerCount,
      'Green Leafhopper': greenLeafhopperCount,
      'Rice Bugs': riceBugCount,
      'Green leaffolder': greenLeaffolderCount,
    };
  }

  // Count entries by location and month
  Future<String> countEntriesByLocationAndMonth(
      String location, String month) async {
    final response = await _supabase
        .from('scanningHistory')
        .select('id')
        .eq('location', location)
        .eq('month', month)
        .count(CountOption.exact);

    return (response.count).toString();
  }

  // Count entries by location and year
  Future<String> countEntriesByLocationAndYear(
      String location, String year) async {
    final response = await _supabase
        .from('scanningHistory')
        .select('id')
        .eq('location', location)
        .eq('year', year)
        .count(CountOption.exact);

    return (response.count).toString();
  }
}

class SyncService {
  final CropSightDatabase _localDatabase = CropSightDatabase();
  final OnlineDatabase _onlineDatabase = OnlineDatabase();

  Future<void> syncData() async {
    // Check internet connection using internet_connection_checker
    bool isConnected = await InternetConnectionChecker.instance.hasConnection;
    if (!isConnected) {
      debugPrint('No internet connection');
      return; // No internet connection
    }

    // Get unsynced scans from local database
    List<Map<String, dynamic>> unsyncedScans =
        await _localDatabase.getUnsyncedScans();

    // Upload unsynced scans to Supabase
    for (var scan in unsyncedScans) {
      await _onlineDatabase.uploadScan(scan);
      await _localDatabase.markAsSynced(scan['id']);
    }

    // debugPrint('Sync Complete');
  }
}
