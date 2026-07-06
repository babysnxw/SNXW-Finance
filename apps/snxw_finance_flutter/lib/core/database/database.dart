import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'snxw_finance';

  Future<Isar>? _isarFuture;

  Future<Isar> get isar => _isarFuture ??= _open();

  Future<Isar> _open() async {
    final Directory directory = await _resolveDirectory();

    return Isar.open(
      const <CollectionSchema<dynamic>>[],
      directory: directory.path,
      name: _databaseName,
    );
  }

  Future<Directory> _resolveDirectory() async {
    final Directory baseDirectory = await getApplicationSupportDirectory();
    final Directory databaseDirectory = Directory('${baseDirectory.path}${Platform.pathSeparator}isar');

    if (!await databaseDirectory.exists()) {
      await databaseDirectory.create(recursive: true);
    }

    return databaseDirectory;
  }
}