/* 
  Imports
*/
import 'package:expense_tracker/database/drift_database.dart' as db;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
/*
  Enums and Constants
*/

final uuid = Uuid(); //utility object to generate unique ids
final dateFormatter = DateFormat('dd-MM-yyyy'); // to format date in a readable format

enum Category {
  // Expense categories from the excel sheet
  food,
  cab,
  office,
  bill,
  home,
  other,
  Anubhav,
  Rachna,
  Baby

}

// icons as per categories
const categoryIcons = {
  Category.food:   Icons.food_bank,
  Category.cab:    Icons.local_taxi,
  Category.office: Icons.business_center,
  Category.bill:   Icons.receipt,
  Category.home:   Icons.home,
  Category.other:  Icons.category,
  Category.Anubhav: Icons.man,
  Category.Rachna:  Icons.woman,
  Category.Baby:    Icons.child_care,
};

/* Expense model class */
class Expense { 
  
  Expense({ // Constructor function
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    String? id,
  }) : id = id ?? uuid.v4(); // initializer list to generate a new unique id

  final String id;
  final String title;
  final double amount;
  final DateTime date; //Datetime is built into dart
  final Category category;

  String get formattedDate { //getters are computed properties which are dynamically derived based on Class' other properties
    return dateFormatter.format(date);
  }
}