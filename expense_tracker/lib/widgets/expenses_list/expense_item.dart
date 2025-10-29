import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';


/*
  ExpenseItem widget to display individual expense details
*/

class ExpenseItem  extends StatelessWidget {
  // Constructor
  const ExpenseItem(this.expense, {super.key});

  // Properties
  final Expense expense;  

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          children: [
            Text(expense.title, style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('₹${expense.amount.toStringAsFixed(2)}'),
                const Spacer(),
                Row(
                  children: [
                    Icon(categoryIcons[expense.category] as IconData),
                    const SizedBox(width: 8),
                    Text(expense.formattedDate),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
