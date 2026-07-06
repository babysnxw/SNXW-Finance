import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'database.dart';

final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);

final FutureProvider<Isar> isarProvider = FutureProvider<Isar>(
  (ref) => ref.watch(databaseProvider).isar,
);