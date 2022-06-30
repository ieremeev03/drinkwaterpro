
// сначала создаем объект самого поста
import 'dart:convert';
import 'dart:developer';

Param paramFromJson(String str) => Param.fromJson(json.decode(str));

String paramToJson(Param data) => json.encode(data.toJson());

Param paramFromMap(String str) => Param.fromMap(json.decode(str));

String paramToMap(Param data) => json.encode(data.toMap());

class Param {
  Param({
    this.name,
    this.value,

  });


  String? name;
  String? value;


  factory Param.fromJson(Map<String, dynamic> json) => Param(
    name: json["name"],
    value: json["value"],

  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "value": value,
  };


  factory Param.fromMap(Map<dynamic, dynamic> json) => Param(
    name: json["name"],
    value: json["value"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "value": value,

  };
}