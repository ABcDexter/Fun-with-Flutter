import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:expense_tracker/models/expense.dart' as model;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'drift_database.g.dart';

@DataClassName('DriftExpense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();      
  IntColumn get category => intEnum<model.Category>()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;

  Future<void> insertExpense(model.Expense expense) {
    return into(expenses).insert(ExpensesCompanion(
      id: Value(expense.id),
      title: Value(expense.title),
      amount: Value(expense.amount),
      date: Value(expense.date),
      category: Value(expense.category),
    ));
  }

  Future<List<model.Expense>> getAllExpenses() async {
    final driftExpenses = await select(expenses).get();
    return driftExpenses.map((driftExpense) {
      return model.Expense(
        id: driftExpense.id,
        title: driftExpense.title,
        amount: driftExpense.amount,
        date: driftExpense.date,
        category: driftExpense.category,
      );
    }).toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}

final AppDatabase database = AppDatabase();