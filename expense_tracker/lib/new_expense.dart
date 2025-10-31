import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';

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
    DateTime? _selectedDate;
    Category? _selectedCategory = Category.other;

    void _presentDatePicker() async {

        final now = DateTime.now();
        final firstDate = DateTime(now.year - 1, now.month, now.day);
        final lastDate = DateTime(now.year + 1, now.month, now.day);
        final pickedDate = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: firstDate,
            lastDate: lastDate,
        );

        if (pickedDate != null) {
            _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        }

        setState(() {
            _selectedDate = pickedDate;
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

                    DropdownButton(
                            hint: const Text('Select Category'),
                            items: Category.values
                                .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category.name.toUpperCase()),
                                )).toList(),
                            
                            onChanged: (value) { 
                              if (value == null)  {
                                  return ;
                                }
                              setState(() {
                                _selectedCategory = value;
                              });
                              print('AB DEBUG : Selected Category = $_selectedCategory');
                            }
                        ),

                    const SizedBox(height: 32),

                    Row(children: [
                        
                        
                        //CANCEL Button
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
                                print('AB DEBUG : Date = ${_selectedDate != null ? DateFormat('dd-MM-yyyy').format(_selectedDate!) : 'No Date Chosen'}');
                                Navigator.pop(context); //closes the bottom sheet
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