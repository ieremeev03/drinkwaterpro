// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

Device deviceFromJson(String str) => Device.fromJson(json.decode(str));

String deviceToJson(Device data) => json.encode(data.toJson());

class  Device {
  Device({
    this.id,
    this.deviceUuid,
    this.deviceAddress,
    required this.latitude,
    required this.longitude,
    required this.price,
  });

  int? id;
  String? deviceUuid;
  String? deviceAddress;
  String latitude;
  String longitude;
  int? price;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json["id"],
    deviceUuid: json["deviceUuid"],
    deviceAddress: json["deviceAddress"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    price: json["price"],
  );


  Map<String, dynamic> toJson() => {
    "id": id,
    "deviceUuid": deviceUuid,
    "deviceAddress": deviceAddress,
    "latitude": latitude,
    "longitude": longitude,
    "price": price,
  };


}

// PostList являются оберткой для массива постов
class DeviceList {
  final List<Device> devices = [];
  DeviceList.fromJson(List<dynamic> jsonItems) {
    for (var jsonItem in jsonItems) {
      devices.add(Device.fromJson(jsonItem));
    }
  }
}

// PostList являются оберткой для массива постов
class PlacemarkList {
  final List<Device> devices = [];
  PlacemarkList.fromPlacemark(List<dynamic> jsonItems) {
    for (var jsonItem in jsonItems) {
      devices.add(Device.fromJson(jsonItem));
    }
  }
}


// наше представление будет получать объекты
// этого класса и определять конкретный его
// подтип
abstract class DeviceResult {}

// указывает на успешный запрос
class DeviceResultSuccess extends DeviceResult {
  final DeviceList deviceList;
  DeviceResultSuccess(this.deviceList);
}

// произошла ошибка
class DeviceResultFailure extends DeviceResult {
  final String error;
  DeviceResultFailure(this.error);
}

// загрузка данных
class DeviceResultLoading extends DeviceResult {
  DeviceResultLoading();
}


abstract class DeviceInfo{}
// указывает на успешный запрос
class DeviceInfoSuccess extends DeviceInfo {
  final Device device;
  DeviceInfoSuccess(this.device);
}

// произошла ошибка
class DeviceInfoFailure extends DeviceInfo {
  final String error;
  DeviceInfoFailure(this.error);
}