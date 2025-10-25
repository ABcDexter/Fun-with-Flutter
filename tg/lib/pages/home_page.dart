import 'package:tg/data/users.dart';
import 'package:tg/model/user.dart';
import 'package:tg/model/cycle.dart';
import 'package:tg/widget/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as log_dev;

class SortablePage extends StatefulWidget {
  const SortablePage({super.key});

  @override
  _SortablePageState createState() => _SortablePageState();
}

class _SortablePageState extends State<SortablePage> {
  late List<User> users;
  late List<Cycle> cycles;
  int? sortColumnIndex;
  bool isAscending = false;

  @override
  void initState() {
    super.initState();

    users = List.of(allUsers);
    //this.cycles = List.of(allCycles);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ScrollableWidget(child: buildDataTable()),
  );

  Widget buildDataTable() {
    final columns = ['Cycle Number', 'Description', 'Cycle Status', 'Cycle Status Description',
      'Count Date', 'Items to Count'];

    return DataTable(
      sortAscending: isAscending,
      sortColumnIndex: sortColumnIndex,
      columns: getColumns(columns),
      rows: getRows(users),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
    label: Text(column),
    onSort: onSort,
  ))
      .toList();

  List<DataRow> getRows(List<User> users) => users.map((User user) {
    final cells = [user.cycleNumber, user.desc, user.cycleStatus, user.countDate, user.cycleStatusDesc, user.itemsToCount];
    log_dev.log("cells USER : ${cells[0]}", name: "getRows");

    const testThis = 1; //[cycles[0].fsP5541240W5541240A.data.gridData.rowset[0]];
    log_dev.log("testThis USER : $testThis", name: "getRows");


    return DataRow(cells: getCells(cells));
  }).toList();

  List<DataCell> getCells(List<dynamic> cells) =>
      cells.map((data) => DataCell(Text('$data'))).toList();

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      users.sort((user1, user2) =>
          compareString(ascending, user1.cycleNumber, user2.cycleNumber));
    } else if (columnIndex == 1) {
      users.sort((user1, user2) =>
          compareString(ascending, user1.desc, user2.desc));
    } else if (columnIndex == 2) {
      users.sort((user1, user2) =>
          compareString(ascending, '${user1.itemsToCount}', '${user2.itemsToCount}'));
    }

    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);
}
