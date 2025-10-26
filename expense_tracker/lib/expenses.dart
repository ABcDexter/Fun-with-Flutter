/* 
  Imports
*/
import 'package:flutter/material.dart';

/*
  Classes
*/
class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> { //State is a generic class so we need to specify the type of State it is managing
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
          Text('Welcome to Expense Tracker!'),
          Text('Expenses list...')
        ],
      )
    );
  }
}
