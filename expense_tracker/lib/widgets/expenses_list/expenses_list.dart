
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
/*
  ExpensesList widget to display a list of expenses
*/
class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        return ExpenseItem(expense);
      },
    );  
  }
}