/* 
  Imports
*/
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

  final List<Expense> _registeredExpenses = [
    Expense(title: 'Test Expense', amount: 19.99, date: DateTime.now(), category: Category.food),
    Expense(title: 'Test Expense 2', amount: 49.99, date: DateTime.now(), category: Category.cab),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Column(
        children: <Widget> [
          const Text('List of Expenses!'),
          Expanded(
            child: ExpensesList(expenses: _registeredExpenses),
          ),
        ],
      ),
    );
  }
}
