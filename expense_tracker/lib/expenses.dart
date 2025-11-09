/* 
  Imports
*/
import 'package:expense_tracker/database/drift_database.dart' as db;
import 'package:expense_tracker/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';

/*
  Classes
*/
class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}


class _ExpensesState extends State<Expenses> { //State is a generic class so we need to specify the type of State it is managing

  List<Expense> _registeredExpenses = [];

  _openAddExpenseOverlay() {
    // Function to open overlay for adding a new expense
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, //automatically available in State class
      builder: (ctx) { //ctx is the BuildContext of the bottom sheet
        return NewExpense(onAddExpense: _addExpense); //we're passing the function as parameter
      }
    );
  } 

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    setState(() {
      _registeredExpenses.remove(expense);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Expense>>(
      // Fetch expenses from the database
      // in case the data is not yet available, show a loading spinner
      future: db.database.getAllExpenses(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          // If we have data, populate the list
          if (_registeredExpenses.isEmpty && snapshot.hasData) {
            _registeredExpenses = snapshot.data!;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Expense Tracker'),
              centerTitle: true,
              backgroundColor: const Color(0xFF3366FF),
              actions: [
                IconButton(
                  onPressed: _openAddExpenseOverlay,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                const Text('List of Expenses!'),
                Expanded(
                  child: ExpensesList(expenses: _registeredExpenses, onRemoveExpense: _removeExpense),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
      
