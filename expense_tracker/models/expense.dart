/* 
  Imports
*/
import 'package:uuid/uuid.dart';

final uuid = Uuid(); //utility object to generate unique ids

/* Expense model class */
class Expense { 
  
  Expense({ // Constructor function
    required this.title,
    required this.amount,
    required this.date,
  }) : id = uuid.v4(); // initializer list to generate a new unique id

  final String id;
  final String title;
  final double amount;
  final DateTime date; //Datetime is built into dart

}