/* ***************
    Imports
**************** */
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' ;
import 'dart:developer' as logDev;

import 'package:tg/pages/home-page.dart';
import 'package:tg/widget/tab-bar_widget.dart';

import 'dart:convert';


/* 
Login class to hold user credentials
*/
class Login {
  String username; // "VELOCITY",
  String password; // "JPY920",

  Login(this.username, this.password);


  factory Login.fromJson(dynamic json){
    return Login(json['username'] as String, json['password'] as String);
  }

  @override
  String toString(){
    return '{ ${username}, ${password} }';
  }

}

/* ***************
  Main Function
**************** */
main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // LoginScreen for the application
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hide = true;
  var url =  Uri.https('jdeaiscrp.c1y7.velocity.cloud', 'jderest/v2/tokenrequest');
      //"https://jdeaiscrp.c1y7.velocity.cloud/jderest/v2/tokenrequest";

  String userName = "";
  String passWd = "";

  void doPostData( String username,  String password) async{ //}(String username, String password) async {
    // post the data with given dres
    int status = 0;
    try {

      final url = Uri.parse('https://jdeaiscrp.c1y7.velocity.cloud/jderest/v2/tokenrequest');
      logDev.log("url : $url", name: "doPostData");

      final headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {"username":username, "password":password};
      //Map<String, dynamic> body = {"username":"velocity", "password":"dv2ksitp"};

      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');

      Response response = await post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );

      int statusCode = response.statusCode;
      //for outer logic
      status = statusCode;

      String responseBody = response.body;
      //print the success code
      logDev.log("Success code : $statusCode", name: "doPostData");

      logDev.log("Success body : ${responseBody.length}", name: "doPostData");
      // parse the json to get the token
      //User user = User.fromJson(jsonDecode(responseBody));

      var parsedJson = json.decode(responseBody);
      //User user = User(parsedJson['username'], parsedJson['environment'], parsedJson['role'], parsedJson['jassserver']);

      //var token = json.decode(parsedJson['userInfo']);
      logDev.log("Success body : ${parsedJson['username']}, ${parsedJson['role']} ${parsedJson['userInfo']['token']}", name: "doPostData");

      logDev.log("Succes : $status | redirecting to Home Page", name: "doPostData"  );

      String token = parsedJson['userInfo']['token'];
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyApp(loginToken: token)));

    }
      catch (er){
        logDev.log("Error : ${er.toString()} | Wont redirect", name: "doPostData"  );

        Widget okButton = TextButton(onPressed: (){}, child: const Text("OK"));

        AlertDialog alert = AlertDialog(
          title: const Text('Error'),
          content: const Text('Please reload the app and enter correct credentials.'),
          backgroundColor: Colors.red,
          actions: [ okButton],
        );

        showDialog(
          context: context, builder: (BuildContext context) {
            return alert;
        });
      }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 400),
              width: double.infinity,
              height: 450,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: const EdgeInsets.only(top: 200, left: 50, right: 50),
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38, spreadRadius: 0.1, blurRadius: 5)
                  ]),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                        hintText: "Username",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                      onChanged: (val) {
                        userName = val;
                      },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    obscureText: hide,
                    decoration: InputDecoration(
                        hintText: "Password",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hide = !hide;
                            });
                          },
                          icon: hide
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onChanged: (String? val) {
                      passWd = val!;  //set the password
                    },
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        onPressed: () => doPostData(userName, passWd),
                        child: const Text("Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)
                                )
                              ),
                  ),

                ],
              ),
            ),
            const Positioned(
                top: 80,
                left: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TG Cycle Count",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Enter username and password to login",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 17),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}


class User {
  String username;     // "VELOCITY",
  String environment; // "JPY920",
  String role;       // "*ALL",
  String jasserver; // "http://c1y76088.ora.vtscloud.io:3001",

  User(this.username, this.environment, this.role, this.jasserver);
 

  factory User.fromJson(dynamic json){
    return User(json['username'] as String, json['environment'] as String,
        json['role'] as String, json['jassserver'] as String);
  }

  @override
  String toString(){
    return '{ ${username}, ${environment}, ${role},${jasserver} }';
  }

  }

class Home extends StatelessWidget {
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
  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Home Screen"),
      ),
    );
  }*/

}

class MyApp extends StatelessWidget {
static const String title = 'Cycle Count';
String loginToken = '';

MyApp({super.key, required this.loginToken}); // take this value from Login Screen


@override
  Widget build(BuildContext context) => MaterialApp(

      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: MainPage(loginToken: loginToken,),
    );
}

class MainPage extends StatefulWidget {
  String loginToken = '';

  MainPage({super.key, required this.loginToken});
  @override
    _MainPageState createState() => _MainPageState(loginToken:loginToken);
  }

class _MainPageState extends State<MainPage> {

  String loginToken = '';

  _MainPageState({required this.loginToken});

  // todo fetch this from a POST call
  // Initial Selected Value
  static var items = [
    '    Branch 5320',
    '    Branch 5321',
    '    Branch 5322',
    '    Branch 5323',

  ];

  String dropdownvalue = items[0];

  @override
  Widget build(BuildContext context) => TabBarWidget(
    title: MyApp.title,
    tabs: [
      const Tab(icon: Icon(Icons.sort_by_alpha),text: 'Cycle counts'),
      //Tab(icon: Icon(Icons.select_all), text: 'Selectable'),
      //Tab(icon: Icon(Icons.edit), text: 'Editable'),
      const Tab(icon: Icon(Icons.edit), text: 'Cycle Count Entry'),
         ],
    children: [
      SortablePage(),
     // Container(),
      //Container(),

      Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
                Expanded(
                child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                SizedBox(
                height: 50 ,
                child:
                        DropdownButton(

                        // Initial Value
                        value: dropdownvalue,

                        // Down Arrow Icon
                        icon: const Icon(Icons.arrow_circle_down),

                        // Array list of items
                        items: items.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        // After selecting the desired option,it will
                        // change button value to selected value
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                      )

                ),


              ListTile(
                title:  const Text('Cycle Count Description' ' | ' + '5320 – Week 15 2022-MA'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  //Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Run 41410A - Print Cycle Count Sheet'  ' | ' + 'N'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  //Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Version'  ' | ' + 'CCSHEET'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  //Navigator.pop(context);
                },
              ),
                  const Divider(
                    height: 10,
                    thickness: 1,
                    indent: 1,
                    endIndent: 0,
                    color: Colors.black,
                  ),

                  ListTile(
                    title: const Text('SUBMIT'),
                    onTap: () {
                      // ToDo a post request to https://jdeaiscrp.c1y7.velocity.cloud/jderest/v2/report/execute
                      Navigator.pop(context);
                    },
                  )
              ],
          )
      )
    ],
    )
    )
  ]);
}
