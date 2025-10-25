import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:developer' as log_dev;

import 'package:tg/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // LoginScreen for the application
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hide = true;
  var url =
      Uri.https('jdeaiscrp.c1y7.velocity.cloud', 'jderest/v2/tokenrequest');

  String userName = "";
  String passWd = "";

  void doPostData(String username, String password) async {
    // post the data with given dres
    int status = 0;
    try {
      final url = Uri.parse(
          'https://jdeaiscrp.c1y7.velocity.cloud/jderest/v2/tokenrequest');
      log_dev.log("url : $url", name: "doPostData");

      final headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {"username": username, "password": password};

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
      log_dev.log("Success code : $statusCode", name: "doPostData");

      log_dev.log("Success body : ${responseBody.length}", name: "doPostData");

      var parsedJson = json.decode(responseBody);

      log_dev.log(
          "Success body : ${parsedJson['username']}, ${parsedJson['role']} ${parsedJson['userInfo']['token']}",
          name: "doPostData");

      log_dev.log("Succes : $status | redirecting to Home Page",
          name: "doPostData");

      String token = parsedJson['userInfo']['token'];
      if (mounted) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MyApp(loginToken: token)));
      }
    } catch (er) {
      log_dev.log("Error : ${er.toString()} | Wont redirect",
          name: "doPostData");

      Widget okButton = TextButton(onPressed: () {
        Navigator.of(context).pop();
      }, child: const Text("OK"));

      AlertDialog alert = AlertDialog(
        title: const Text('Error'),
        content:
            const Text('Please reload the app and enter correct credentials.'),
        backgroundColor: Colors.red,
        actions: [okButton],
      );

      if (mounted) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0553B1),
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
                      userName = val.trim(); // set the username
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
                      passWd = val!; //set the password
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
                                fontSize: 18))),
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
