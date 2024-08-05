// To parse this JSON data, do
//
//     final insects = insectsFromJson(jsonString);

import 'dart:convert';

Insects insectsFromJson(String str) => Insects.fromJson(json.decode(str));

String insectsToJson(Insects data) => json.encode(data.toJson());

class Insects {
  CropsightData cropsightData;

  Insects({
    required this.cropsightData,
  });

  factory Insects.fromJson(Map<String, dynamic> json) => Insects(
        cropsightData: CropsightData.fromJson(json["cropsightData"]),
      );

  Map<String, dynamic> toJson() => {
        "cropsightData": cropsightData.toJson(),
      };
}

class CropsightData {
  List<InsectList> insectList;
  List<InsectManage> insectManage;

  CropsightData({
    required this.insectList,
    required this.insectManage,
  });

  factory CropsightData.fromJson(Map<String, dynamic> json) => CropsightData(
        insectList: List<InsectList>.from(
            json["insectList"].map((x) => InsectList.fromJson(x))),
        insectManage: List<InsectManage>.from(
            json["insectManage"].map((x) => InsectManage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "insectList": List<dynamic>.from(insectList.map((x) => x.toJson())),
        "insectManage": List<dynamic>.from(insectManage.map((x) => x.toJson())),
      };
}

class InsectList {
  int insectId;
  String insectName;
  String insectPic;
  String insectDesc;
  String insectWhere;
  String insectDamage;

  InsectList({
    required this.insectId,
    required this.insectName,
    required this.insectPic,
    required this.insectDesc,
    required this.insectWhere,
    required this.insectDamage,
  });

  factory InsectList.fromJson(Map<String, dynamic> json) => InsectList(
        insectId: json["insectID"],
        insectName: json["insectName"],
        insectPic: json["insectPic"],
        insectDesc: json["insectDesc"],
        insectWhere: json["insectWhere"],
        insectDamage: json["insectDamage"],
      );

  Map<String, dynamic> toJson() => {
        "insectID": insectId,
        "insectName": insectName,
        "insectPic": insectPic,
        "insectDesc": insectDesc,
        "insectWhere": insectWhere,
        "insectDamage": insectDamage,
      };
}

class InsectManage {
  int insectId;
  String insectName;
  String insectPic;
  List<String> cultureMn;
  List<String> biologicalMn;
  List<String> chemicalMn;

  InsectManage({
    required this.insectId,
    required this.insectName,
    required this.insectPic,
    required this.cultureMn,
    required this.biologicalMn,
    required this.chemicalMn,
  });

  factory InsectManage.fromJson(Map<String, dynamic> json) => InsectManage(
        insectId: json["insectId"],
        insectName: json["insectName"],
        insectPic: json["insectPic"],
        cultureMn: List<String>.from(json["cultureMn"].map((x) => x)),
        biologicalMn: List<String>.from(json["biologicalMn"].map((x) => x)),
        chemicalMn: List<String>.from(json["chemicalMn"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "insectId": insectId,
        "insectName": insectName,
        "insectPic": insectPic,
        "cultureMn": List<dynamic>.from(cultureMn.map((x) => x)),
        "biologicalMn": List<dynamic>.from(biologicalMn.map((x) => x)),
        "chemicalMn": List<dynamic>.from(chemicalMn.map((x) => x)),
      };
}
