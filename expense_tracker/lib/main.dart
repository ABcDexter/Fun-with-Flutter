/* 
  Imports
*/

import 'package:flutter/material.dart';
import 'package:expense_tracker/expenses.dart';

/*
  Main Function
*/
void main() {
  runApp(
    MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Expenses(),
    ));
}
