import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('QRYZE.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    debugPrint('DB Initiated');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const String tblHistoryName = 'Code_Details';
    const String tblSettingsName = 'Code_Settings';

    await db.execute('''
      CREATE TABLE $tblHistoryName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        codeType TEXT NOT NULL,
        contentType TEXT NULL,
        bgColor INTEGER NULL,
        fgColor INTEGER NULL,
        size REAL NULL,
        padding REAL NULL,
        edge REAL NULL,
        boarderWidth REAL NULL,
        boarderColor INTEGER NULL,
        enableBoarder BOOLEAN NOT NULL,
        saveName TEXT NOT NULL,
        modifiedDate TEXT NOT NULL,
        createdDate TEXT NOT NULL
      )
    ''');
    debugPrint('History Table created');

    await db.execute('''
      CREATE TABLE $tblSettingsName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bgColor INTEGER NULL,
        fgColor INTEGER NULL,
        padding REAL NULL,
        edge REAL NULL,
        boarderWidth REAL NULL,
        boarderColor INTEGER NULL,
        enableBoarder BOOLEAN NULL,
        autoRedirect BOOLEAN NULL,
        continuesScan BOOLEAN NULL
      )
    ''');
    debugPrint('profile Table created');
  }
}
