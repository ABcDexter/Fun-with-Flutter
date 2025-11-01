/* 
  Imports
*/
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

  List<Expense> _registeredExpenses = [
    // TODO Remove hardcoded expenses
    Expense(title: 'Test Expense', amount: 19.99, date: DateTime.now(), category: Category.food),
    Expense(title: 'Test Expense 2', amount: 49.99, date: DateTime.now(), category: Category.cab),
    Expense(title: 'Test Expense 3', amount: 99.99, date: DateTime.now(), category: Category.office),
    Expense(title: 'Test Expense 4', amount: 199.99, date: DateTime.now(), category: Category.bill),
    Expense(title: 'Test Expense 5', amount: 299.99, date: DateTime.now(), category: Category.home),
    Expense(title: 'Test Expense 6', amount: 399.99, date: DateTime.now(), category: Category.other),
    Expense(title: 'Test Expense 7', amount: 499.99, date: DateTime.now(), category: Category.Anubhav),
    Expense(title: 'Test Expense 8', amount: 599.99, date: DateTime.now(), category: Category.Rachna),    
    Expense(title: 'Test Expense 9', amount: 699.99, date: DateTime.now(), category: Category.Baby),
  ];

  _openAddExpenseOverlay() {
    // Function to open overlay for adding a new expense
    showModalBottomSheet(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        //backgroundColor: const Color.fromARGB(255, 187, 6, 111),
        backgroundColor: const Color(0xFF3366FF),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay, //{}
            icon: const Icon(Icons.add),
          ),
        ],
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
