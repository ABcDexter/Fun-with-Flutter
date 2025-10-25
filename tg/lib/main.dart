/*_________________
    Imports
_________________*/
import 'package:flutter/material.dart';
import 'package:tg/pages/login_screen.dart';
import 'package:tg/pages/main_page.dart';

/*_________________
  Main Function
_________________*/
main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class Home extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  var email;

  Home({super.key, this.email});

  runApp(Function() MyApp) {
    // TODO: implement runApp
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

class MyApp extends StatelessWidget {
static const String title = 'Cycle Count';
String loginToken = '';

  MyApp({super.key, required this.loginToken}); // take this value from Login Screen

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MainPage(loginToken: loginToken),
    );
  }
}
