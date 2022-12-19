
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../data/repository.dart';
import '../models/device.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:drinkwaterpro/data/database.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:drinkwaterpro/pages/home/block.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceController extends ControllerMVC {
  // создаем наш репозиторий
  final Repository repo = new Repository();
  final DatabaseHandler handler = DatabaseHandler();
  // конструктор нашего контроллера
  DeviceController();

  // первоначальное состояние - загрузка данных
  DeviceResult currentState = DeviceResultLoading();

  void init(context) async {
    try {
      // получаем данные из репозитория
      final center = currentPosition().then((value) async {
        repo.add_log('DEVICE: Получение списка устройств');
        final deviceList = await repo.fetchDevices();
        // если все ок то обновляем состояние на успешное

        if (deviceList.devices.length >0) {
          setState(() => currentState = DeviceResultSuccess(deviceList));

          if(globals.blockApp == 1) {
            Navigator.of(context, rootNavigator: true).pushReplacement(
              MaterialPageRoute(builder: (context) => BlockPage()),
            );

          }



        } else {
          setState(() => currentState = DeviceResultFailure('Поблизости нет аппаратов с чистой водой'));
        }
      });





    } catch (error) {
      print(error);
      repo.add_log('DEVICE: Ошибка получения списка устройств');
      // в противном случае произошла ошибка
      setState(() => currentState = DeviceResultFailure("Произошла ошибка"));
    }
  }



  void getDevice(String code, void Function(DeviceInfo) callback) async {
    try {
      print("Запрос информации оаппарате с сервера");
      repo.add_log('DEVICE: Запрос информации о аппарате с сервера', data: code);
      var id = 0;
      final token = await handler.getParam('api_token');
      final result = await repo.getDeviceInfo(token, code);
      repo.add_log('Log 1', data: result.id.toString());

      if (result != null ) {
        globals.currentDeviceId = result.id!;
        globals.currentDevicePrice = result.price!;
        globals.currentDeviceTemp = result.temp!;
        if(globals.currentDeviceTemp < 0) globals.currentDeviceTemp = 10;
        globals.currentDevicePpm = result.ppm!;
        globals.currentDeviceUuid = result.deviceUuid!;

        await FirebaseAnalytics.instance.logSelectItem(
          itemListId: globals.currentDeviceId.toString(),
          itemListName: result.deviceAddress!,
        );
      }

      repo.add_log('Log 2');

      callback(DeviceInfoSuccess(result));
    } catch (error) {
      repo.add_log('DEVICE: Ошибка получения информации о аппарате с сервера');
      callback(DeviceInfoFailure("Ошибка получения информации"));
    }
  }



  Future<CameraPosition> currentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    double latitude = 0.0;
    double longitude = 0.0;

    print(permission.name);
    repo.add_log('USER: Geo Permission', data: permission.name.toString());

    if(permission.name == "deniedForever" || permission.name == "denied") {
        final url = Uri.parse("http://ip-api.com/json");
        await http.get(url).then((value) {
          repo.add_log('USER: Geo IP', data: value.body.toString());

          latitude = json.decode(value.body)['lat'].toDouble();
          longitude = json.decode(value.body)['lon'].toDouble();
          globals.userLat = latitude;
          globals.userLon = longitude;

          repo.add_log('USER: Geo IP', data: 'latitude '+latitude.toString() + ' longitude '+longitude.toString());
        });

    } else {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;longitude = position.longitude;
      globals.userLat = latitude;
      globals.userLon = longitude;

    }



    repo.add_log('USER: Получение текущей геопозиции', data: 'latitude '+latitude.toString()+' longitude '+ longitude.toString());



    return CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );

  }

/*
  Future<void> route() async {
    final DrivingResultWithSession resultWithSession;
    final current = currentPosition().then((value) {

      final Placemark startPlacemark = Placemark(
        mapId: MapObjectId('start_placemark'),
        point: value,
        icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/img/route_start.png'),
                scale: 0.3
            )
        ),
      );

      final Placemark endPlacemark = Placemark(
        mapId: MapObjectId('stop_by_placemark'),
        point: Point(latitude: 45.0360, longitude: 38.9746),
        icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/img/route_stop_by.png'),
                scale: 0.3
            )
        ),
      );

      print('Route: ${startPlacemark.point},${endPlacemark.point}');

      var resultWithSession = YandexDriving.requestRoutes(
          points: [
            RequestPoint(point: startPlacemark.point, requestPointType: RequestPointType.wayPoint),
            RequestPoint(point: endPlacemark.point, requestPointType: RequestPointType.wayPoint),
          ],
          drivingOptions: DrivingOptions(
              initialAzimuth: 0,
              routesCount: 5,
              avoidTolls: true
          )
      );

      print(resultWithSession);
    });
  }



*/








}

