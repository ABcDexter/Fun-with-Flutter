import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:expense_tracker/models/expense.dart';

/*
  NewExpense widget to add a new expense
*/
class NewExpense extends StatefulWidget {
    const NewExpense({super.key});

    @override
    State<NewExpense> createState() {
        return _NewExpense();
    }
}

class _NewExpense extends State<NewExpense> {
    /*
    var _enteredTitle = '';

    void _saveTitleInput (String inputValue){
        //setState(() { UI need not to update, so no need to call setState
            _enteredTitle = inputValue;
        //});
    
    }*/

    final _titleController = TextEditingController();
    final _amountController = TextEditingController();
    final _dateController = TextEditingController();


    void _presentDatePicker() {

        final now = DateTime.now();
        final firstDate = DateTime(now.year - 1, now.month, now.day);
        final lastDate = DateTime(now.year + 1, now.month, now.day);
        
        showDatePicker(
            context: context,
            initialDate: now,
            firstDate: firstDate,
            lastDate: lastDate,
        ).then((pickedDate) {
            if (pickedDate != null) {
                _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
            }
        });
    }

    @override
    void dispose() { //only StatefulWidgets have dispose method
        _titleController.dispose();
        _amountController.dispose();
        _dateController.dispose();
        super.dispose(); // only call super.dispose after disposing own resources
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
                children: [
                    TextField( // Title Input Field
                        controller: _titleController,
                        // onChanged: _saveTitleInput, for mutliple fields
                        maxLength: 50,
                        decoration: InputDecoration(labelText: 'Title' ),
                    ),
                    
                    const SizedBox(height: 16),

                    Row( 
                      children: [
                        Expanded(
                            child: TextField( // Amount Input Field
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ ' ),
                            ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                            child:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Select Date'),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: 
                                        TextField( // Date Input Field
                                            controller: _dateController,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                                hintText: 'Choose Date',
                                            ),
                                            onTap: _presentDatePicker,
                                        ),
                                  ),
                                  ],

                                ),
                            ),
                        ]
                        ),
                        

                    const SizedBox(height: 16),

                    Row(children: [
                        ElevatedButton(
                            onPressed: () {
                                // Handle cancel logic
                                Navigator.pop(context); //closes the bottom sheet
                            },
                            child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                            onPressed: () {
                                // Handle save expense logic
                                print('AB DEBUG : Expense Saved = ${_titleController.text}');
                                print('AB DEBUG : Amount = ${_amountController.text}');
                            },
                            child: const Text('Save Expense'),
                        ),


                    ],
                    )
                ],
            ),
        );
    }
}