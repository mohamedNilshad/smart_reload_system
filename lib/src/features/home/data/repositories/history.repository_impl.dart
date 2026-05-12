import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/domain/repositories/database_helper.repository.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/features/home/data/models/code_history.dart';
import 'package:smart_reload_system/src/features/home/domain/entities/history.entity.dart';
import 'package:smart_reload_system/src/features/home/domain/repositories/history.repository.dart';
import 'package:smart_reload_system/src/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HistoryRepositoryImpl implements HistoryRepository {
  final DatabaseHelperRepository databaseHelper = sl<DatabaseHelperRepository>();
  // final JokeRemoteDataSource remoteDataSource;

  // HistoryRepositoryImpl(this.remoteDataSource);

  ///Fetch All History
  @override
  Future<Either<Failure, List<CodeHistory>>> fetchHistory() async {
    try {
      final db = await databaseHelper.database;

      final SharedPreferences prefs = sl<SharedPreferences>();
      if(prefs.containsKey('items')){
        if (!prefs.containsKey('isDbChanged')) {
          await prefs.setBool('isDbChanged', false);
        }
        bool? isChanged = prefs.getBool('isDbChanged');

        if(!isChanged!){
          String? jsonString = prefs.getString('items');
          if (jsonString != null) {
            CodeHistory history;
            ///fetch data from sharedpref
            List<dynamic> jsonList = jsonDecode(jsonString);
             List<History> items = jsonList.map<History>((v) => History.fromJson(v)).toList();


            ///change data to sqlite
            for(var item in items){
              history = CodeHistory(
                content: item.value,
                codeType: item.type!,
                contentType: (item.type! == AppStrings.qrCodeData) ? AppStrings.textData : '',
                bgColor: Colors.white.toARGB32(),
                fgColor: AppColors.black.toARGB32(),
                size: 0.0,
                padding: Sizes.sm,
                edge: 0.0,
                enableBoarder: false,
                saveName: item.title,
                modifiedDate: item.date.toString(),
                createdDate: item.date.toString(),
              );
              await db.insert('Code_Details', history.toMap());
            }

            ///change changed status
            await prefs.setBool('isDbChanged', true);
            await prefs.remove('items');
            debugPrint('DB Changed SuccessFully');
          }
        }
      }

      final result = await db.query('Code_Details');
      if (result.isNotEmpty) {
        List<CodeHistory> data = result.map((e) => CodeHistory.fromMap(e)).toList();
        return Right(data);
      }
      return const Right([]);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  ///Update History
  @override
  Future<Either<Failure, bool>> updateHistory(CodeHistory history) async {
    try {
      final db = await databaseHelper.database;
      int result = await db.update(
        'Code_Details',
        history.toMap(),
        where: 'id = ?',
        whereArgs: [history.id],
      );

      return Right(result > 0);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  ///Update History
  @override
  Future<Either<Failure, bool>> renameHistory(int id, String newName) async {
    try {
      final db = await databaseHelper.database;
      int result = await db.update(
        'Code_Details',
        {'saveName': newName},
        where: 'id = ?',
        whereArgs: [id],
      );

      return Right(result > 0);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  ///Save New History
  @override
  Future<Either<Failure, bool>> saveHistory(CodeHistory history) async {
    try {
      final db = await databaseHelper.database;
      int result = await db.insert('Code_Details', history.toMap());
      return Right(result > 0);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  ///Delete History
  @override
  Future<Either<Failure, bool>> deleteHistory(int historyId) async {
    try {
      final db = await databaseHelper.database;
      int result = await db.delete(
        'Code_Details',
        where: 'id = ?',
        whereArgs: [historyId],
      );

      return Right(result > 0);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}


