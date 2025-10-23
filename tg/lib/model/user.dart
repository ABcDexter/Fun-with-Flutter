class User {

  //Class which contains the Model
/*
  "col_25": "Cycle Number",
  "col_30": "Description",
  "col_26": "Cycle Status",
  "col_60": "Cycle Status Description",
  "col_27": "Count Date",

  "col_39": "Items To Count"
*/
  final String cycleNumber;
  final String desc;
  final String cycleStatus;
  final String cycleStatusDesc;
  final String countDate;
  final int itemsToCount;

  const User({
    required this.cycleNumber,
    required this.desc,
    required this.cycleStatus,
    required this.cycleStatusDesc,
    required this.countDate,
    required this.itemsToCount,
  });

  User copy({
    String? cycleNumber,
    String? desc,
    String? cycleStatus,
    String? cycleStatusDesc,
    String? countDate,
    int? itemsToCount,
  }) =>
      User(
        cycleNumber: cycleNumber ?? this.cycleNumber,
        desc: desc ?? this.desc,
        cycleStatus: cycleStatus ?? this.cycleStatus,
        cycleStatusDesc: cycleStatusDesc ?? this.cycleStatusDesc,
        countDate: countDate ?? this.countDate,
        itemsToCount: itemsToCount ?? this.itemsToCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              cycleNumber == other.cycleNumber &&
              desc == other.desc &&
              cycleStatus == other.cycleStatus &&
              cycleStatusDesc == other.cycleStatusDesc &&
              countDate == other.countDate &&
              itemsToCount == other.itemsToCount;

  @override
  int get hashCode => cycleNumber.hashCode ^ desc.hashCode ^ cycleStatus.hashCode ^ cycleStatusDesc.hashCode ^ countDate.hashCode ^ itemsToCount.hashCode;
}
