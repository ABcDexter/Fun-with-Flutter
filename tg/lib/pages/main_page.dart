import 'package:flutter/material.dart';
import 'package:tg/main.dart';
import 'package:tg/pages/home_page.dart';
import 'package:tg/widget/tab_bar_widget.dart';

class MainPage extends StatefulWidget {
  String loginToken = '';

  MainPage({super.key, required this.loginToken});
  @override
  _MainPageState createState() => _MainPageState(loginToken: loginToken);
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
      tabs: const [
        Tab(icon: Icon(Icons.sort_by_alpha), text: 'Cycle counts'),
        Tab(icon: Icon(Icons.edit), text: 'Cycle Count Entry'),
      ],
      children: [
        const SortablePage(),
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
                    height: 50,
                    child: DropdownButton(
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
                    )),
                ListTile(
                  title: const Text(
                      'Cycle Count Description' ' | ' '5320 – Week 15 2022-MA'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    //Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                      'Run 41410A - Print Cycle Count Sheet' ' | ' + 'N'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    //Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Version' ' | ' + 'CCSHEET'),
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
            ))
          ],
        ))
      ]);
}
