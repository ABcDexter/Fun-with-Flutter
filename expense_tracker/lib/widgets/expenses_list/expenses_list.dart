
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
//import expenses.dart to access _removeExpense function
import 'package:expense_tracker/expenses.dart';
/*
  ExpensesList widget to display a list of expenses
*/
class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required void Function(Expense) onRemoveExpense,
  }) : _onRemoveExpense = onRemoveExpense;

  final List<Expense> expenses;
  final void Function(Expense) _onRemoveExpense;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        return 
        Dismissible(
          key: ValueKey(expense),
          background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.75),
            margin: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          onDismissed: (direction) {
            // direction = left to right or right to left
            // TODO remove from the drift database
            _onRemoveExpense(expense);
          },
          child: ExpenseItem(expense),
        );
      },
    );  
  }
}