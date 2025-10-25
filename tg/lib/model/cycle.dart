import 'dart:convert';

Cycle cycleFromJson(String str) => Cycle.fromJson(json.decode(str));

String cycleToJson(Cycle data) => json.encode(data.toJson());

class Cycle {
  Cycle({
     required this.fsP5541240W5541240A,
     required this.stackId,
     required this.stateId,
     required this.rid,
     required this.currentApp,
     required this.timeStamp,
     required this.sysErrors,
  });

  FsP5541240W5541240A fsP5541240W5541240A;
  int stackId;
  int stateId;
  String rid;
  String currentApp;
  String timeStamp;
  List<dynamic> sysErrors;

  factory Cycle.fromJson(Map<String, dynamic> json) => Cycle(
    fsP5541240W5541240A: FsP5541240W5541240A.fromJson(json["fs_P5541240_W5541240A"]),
    stackId: json["stackId"],
    stateId: json["stateId"],
    rid: json["rid"],
    currentApp: json["currentApp"],
    timeStamp: json["timeStamp"],
    sysErrors: List<dynamic>.from(json["sysErrors"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "fs_P5541240_W5541240A": fsP5541240W5541240A.toJson(),
    "stackId": stackId,
    "stateId": stateId,
    "rid": rid,
    "currentApp": currentApp,
    "timeStamp": timeStamp,
    "sysErrors": List<dynamic>.from(sysErrors.map((x) => x)),
  };
}

class FsP5541240W5541240A {
  FsP5541240W5541240A({
    required this.title,
    required this.data,
    required this.errors,
    required this.warnings,
  });

  String title;
  Data data;
  List<dynamic> errors;
  List<dynamic> warnings;

  factory FsP5541240W5541240A.fromJson(Map<String, dynamic> json) => FsP5541240W5541240A(
    title: json["title"],
    data: Data.fromJson(json["data"]),
    errors: List<dynamic>.from(json["errors"].map((x) => x)),
    warnings: List<dynamic>.from(json["warnings"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "data": data.toJson(),
    "errors": List<dynamic>.from(errors.map((x) => x)),
    "warnings": List<dynamic>.from(warnings.map((x) => x)),
  };
}

class Data {
  Data({
    required this.zCycs70,
    required this.zCycs66,
    required this.zCsdj36,
    required this.zCsdj57,
    required this.gridData,
    required this.z16,
    required this.zCsdj35,
    required this.z50,
    required this.zCycs69,
  });

  ZCsdj36 zCycs70;
  ZCsdj36 zCycs66;
  ZCsdj36 zCsdj36;
  ZCsdj36 zCsdj57;
  GridData gridData;
  ZCsdj36 z16;
  ZCsdj35 zCsdj35;
  ZCsdj36 z50;
  ZCsdj36 zCycs69;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    zCycs70: ZCsdj36.fromJson(json["z_CYCS_70"]),
    zCycs66: ZCsdj36.fromJson(json["z_CYCS_66"]),
    zCsdj36: ZCsdj36.fromJson(json["z_CSDJ_36"]),
    zCsdj57: ZCsdj36.fromJson(json["z_CSDJ_57"]),
    gridData: GridData.fromJson(json["gridData"]),
    z16: ZCsdj36.fromJson(json["z__16"]),
    zCsdj35: ZCsdj35.fromJson(json["z_CSDJ_35"]),
    z50: ZCsdj36.fromJson(json["z__50"]),
    zCycs69: ZCsdj36.fromJson(json["z_CYCS_69"]),
  );

  Map<String, dynamic> toJson() => {
    "z_CYCS_70": zCycs70.toJson(),
    "z_CYCS_66": zCycs66.toJson(),
    "z_CSDJ_36": zCsdj36.toJson(),
    "z_CSDJ_57": zCsdj57.toJson(),
    "gridData": gridData.toJson(),
    "z__16": z16.toJson(),
    "z_CSDJ_35": zCsdj35.toJson(),
    "z__50": z50.toJson(),
    "z_CYCS_69": zCycs69.toJson(),
  };
}

class GridData {
  GridData({
    required this.id,
    required this.fullGridId,
    required this.titles,
    required this.columnInfo,
    required this.rowset,
    required this.summary,
  });

  int id;
  String fullGridId;
  Titles titles;
  ColumnInfo columnInfo;
  List<Rowset> rowset;
  Summary summary;

  factory GridData.fromJson(Map<String, dynamic> json) => GridData(
    id: json["id"],
    fullGridId: json["fullGridId"],
    titles: Titles.fromJson(json["titles"]),
    columnInfo: ColumnInfo.fromJson(json["columnInfo"]),
    rowset: List<Rowset>.from(json["rowset"].map((x) => Rowset.fromJson(x))),
    summary: Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullGridId": fullGridId,
    "titles": titles.toJson(),
    "columnInfo": columnInfo.toJson(),
    "rowset": List<dynamic>.from(rowset.map((x) => x.toJson())),
    "summary": summary.toJson(),
  };
}

class ColumnInfo {
  ColumnInfo({
    required this.zCyno25,
    required this.zDsc130,
    required this.zCycs26,
    required this.zDl0160,
    required this.zCsdj27,
    required this.zCylo40,
    required this.zCyit39,
  });

  ZCyit39Class zCyno25;
  ZCyit39Class zDsc130;
  ZCyit39Class zCycs26;
  ZCsdj35 zDl0160;
  ZCyit39Class zCsdj27;
  ZCyit39Class zCylo40;
  ZCyit39Class zCyit39;

  factory ColumnInfo.fromJson(Map<String, dynamic> json) => ColumnInfo(
    zCyno25: ZCyit39Class.fromJson(json["z_CYNO_25"]),
    zDsc130: ZCyit39Class.fromJson(json["z_DSC1_30"]),
    zCycs26: ZCyit39Class.fromJson(json["z_CYCS_26"]),
    zDl0160: ZCsdj35.fromJson(json["z_DL01_60"]),
    zCsdj27: ZCyit39Class.fromJson(json["z_CSDJ_27"]),
    zCylo40: ZCyit39Class.fromJson(json["z_CYLO_40"]),
    zCyit39: ZCyit39Class.fromJson(json["z_CYIT_39"]),
  );

  Map<String, dynamic> toJson() => {
    "z_CYNO_25": zCyno25.toJson(),
    "z_DSC1_30": zDsc130.toJson(),
    "z_CYCS_26": zCycs26.toJson(),
    "z_DL01_60": zDl0160.toJson(),
    "z_CSDJ_27": zCsdj27.toJson(),
    "z_CYLO_40": zCylo40.toJson(),
    "z_CYIT_39": zCyit39.toJson(),
  };
}

class ZCyit39Class {
  ZCyit39Class({
    required this.id,
    required this.dataType,
    required this.bsvw,
    required this.title,
    required this.visible,
    required this.longName,
    required this.qbeEnabled,
  });

  int id;
  int dataType;
  bool bsvw;
  String title;
  bool visible;
  String longName;
  bool qbeEnabled;

  factory ZCyit39Class.fromJson(Map<String, dynamic> json) => ZCyit39Class(
    id: json["id"],
    dataType: json["dataType"],
    bsvw: json["bsvw"],
    title: json["title"],
    visible: json["visible"],
    longName: json["longName"],
    qbeEnabled: json["qbeEnabled"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dataType": dataType,
    "bsvw": bsvw,
    "title": title,
    "visible": visible,
    "longName": longName,
    "qbeEnabled": qbeEnabled,
  };
}

class ZCsdj35 {
  ZCsdj35({
    required this.id,
    required this.dataType,
    required this.title,
    required this.visible,
    required this.longName,
    required this.value,
  });

  int id;
  int dataType;
  String title;
  bool visible;
  String longName;
  String value;

  factory ZCsdj35.fromJson(Map<String, dynamic> json) => ZCsdj35(
    id: json["id"],
    dataType: json["dataType"],
    title: json["title"],
    visible: json["visible"],
    longName: json["longName"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dataType": dataType,
    "title": title,
    "visible": visible,
    "longName": longName,
    "value": value,
  };
}

class Rowset {
  Rowset({
    required this.rowIndex,
    required this.moExist,
    required this.zCyno25,
    required this.zDsc130,
    required this.zCycs26,
    required this.zDl0160,
    required this.zCsdj27,
    required this.zCylo40,
    required this.zCyit39,
  });

  int rowIndex;
  bool moExist;
  ZCy zCyno25;
  ZDl0160Class zDsc130;
  ZDl0160Class zCycs26;
  ZDl0160Class zDl0160;
  ZDl0160Class zCsdj27;
  ZCy zCylo40;
  ZCy zCyit39;

  factory Rowset.fromJson(Map<String, dynamic> json) => Rowset(
    rowIndex: json["rowIndex"],
    moExist: json["MOExist"],
    zCyno25: ZCy.fromJson(json["z_CYNO_25"]),
    zDsc130: ZDl0160Class.fromJson(json["z_DSC1_30"]),
    zCycs26: ZDl0160Class.fromJson(json["z_CYCS_26"]),
    zDl0160: ZDl0160Class.fromJson(json["z_DL01_60"]),
    zCsdj27: ZDl0160Class.fromJson(json["z_CSDJ_27"]),
    zCylo40: ZCy.fromJson(json["z_CYLO_40"]),
    zCyit39: ZCy.fromJson(json["z_CYIT_39"]),
  );

  Map<String, dynamic> toJson() => {
    "rowIndex": rowIndex,
    "MOExist": moExist,
    "z_CYNO_25": zCyno25.toJson(),
    "z_DSC1_30": zDsc130.toJson(),
    "z_CYCS_26": zCycs26.toJson(),
    "z_DL01_60": zDl0160.toJson(),
    "z_CSDJ_27": zCsdj27.toJson(),
    "z_CYLO_40": zCylo40.toJson(),
    "z_CYIT_39": zCyit39.toJson(),
  };
}

class ZDl0160Class {
  ZDl0160Class({
    required this.internalValue,
    required this.value,
  });

  String internalValue;
  String value;

  factory ZDl0160Class.fromJson(Map<String, dynamic> json) => ZDl0160Class(
    internalValue: json["internalValue"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "internalValue": internalValue,
    "value": value,
  };
}

class ZCy {
  ZCy({
    required this.internalValue,
    required this.value,
  });

  int internalValue;
  String value;

  factory ZCy.fromJson(Map<String, dynamic> json) => ZCy(
    internalValue: json["internalValue"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "internalValue": internalValue,
    "value": value,
  };
}

class Summary {
  Summary({
    required this.records,
    required this.moreRecords,
  });

  int records;
  bool moreRecords;

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    records: json["records"],
    moreRecords: json["moreRecords"],
  );

  Map<String, dynamic> toJson() => {
    "records": records,
    "moreRecords": moreRecords,
  };
}

class Titles {
  Titles({
    required this.col25,
    required this.col30,
    required this.col26,
    required this.col60,
    required this.col27,
    required this.col40,
    required this.col39,
  });

  String col25;
  String col30;
  String col26;
  String col60;
  String col27;
  String col40;
  String col39;

  factory Titles.fromJson(Map<String, dynamic> json) => Titles(
    col25: json["col_25"],
    col30: json["col_30"],
    col26: json["col_26"],
    col60: json["col_60"],
    col27: json["col_27"],
    col40: json["col_40"],
    col39: json["col_39"],
  );

  Map<String, dynamic> toJson() => {
    "col_25": col25,
    "col_30": col30,
    "col_26": col26,
    "col_60": col60,
    "col_27": col27,
    "col_40": col40,
    "col_39": col39,
  };
}

class ZCsdj36 {
  ZCsdj36({
    required this.id,
    required this.dataType,
    required this.bsvw,
    required this.title,
    required this.staticText,
    required this.visible,
    required this.longName,
    required this.editable,
    required this.value,
    required this.internalValue,
  });

  int id;
  int dataType;
  bool bsvw;
  String title;
  String staticText;
  bool visible;
  String longName;
  bool editable;
  String value;
  String internalValue;

  factory ZCsdj36.fromJson(Map<String, dynamic> json) => ZCsdj36(
    id: json["id"],
    dataType: json["dataType"],
    bsvw: json["bsvw"],
    title: json["title"],
    staticText: json["staticText"],
    visible: json["visible"],
    longName: json["longName"],
    editable: json["editable"],
    value: json["value"],
    internalValue: json["internalValue"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dataType": dataType,
    "bsvw": bsvw,
    "title": title,
    "staticText": staticText,
    "visible": visible,
    "longName": longName,
    "editable": editable,
    "value": value,
    "internalValue": internalValue,
  };
}
