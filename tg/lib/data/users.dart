import 'package:tg/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' ;
import 'dart:developer' as logDev;
import 'dart:convert';


  List<User> newUsers = []; // List<User>.empty(growable: true);
  //newUsers= (User(cycleNumber: '289189', desc: 'Week 15 - 5515', cycleStatus: '20', countDate: '04/15/2022', cycleStatusDesc: '20-printed', itemsToCount: 44));



void doPostData( String username,  String password) async{
  // post the data with given dress
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
  }


}


final allUsers = <User>[
  User(cycleNumber: '289189', desc: 'Week 15 - 5515', cycleStatus: '20', countDate: '04/15/2022', cycleStatusDesc: '20-printed', itemsToCount: 44),
  User(cycleNumber: '289190', desc: 'Week 15 - 5885', cycleStatus: '21', countDate: '05/15/2022', cycleStatusDesc: '20-printed', itemsToCount: 60),
];

