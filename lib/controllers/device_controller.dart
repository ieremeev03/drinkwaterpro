
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../data/repository.dart';
import '../models/device.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:drinkwaterpro/data/database.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:geolocator/geolocator.dart';

class DeviceController extends ControllerMVC {
  // создаем наш репозиторий
  final Repository repo = new Repository();
  final DatabaseHandler handler = DatabaseHandler();
  // конструктор нашего контроллера
  DeviceController();

  // первоначальное состояние - загрузка данных
  DeviceResult currentState = DeviceResultLoading();

  void init() async {
    try {
      // получаем данные из репозитория
      final deviceList = await repo.fetchDevices();
      // если все ок то обновляем состояние на успешное
      setState(() => currentState = DeviceResultSuccess(deviceList));
    } catch (error) {
      print(error);
      // в противном случае произошла ошибка
      setState(() => currentState = DeviceResultFailure("Нет интернета"));
    }
  }

  void getDevice(String code, void Function(DeviceInfo) callback) async {
    try {
      print("Запрос информации оаппарате с сервера");
      var id = 0;
      final token = await handler.getParam('api_token');
      final result = await repo.getDeviceInfo(token, code);

      if (result != null ) {
        globals.currentDeviceId = result.id!;
        globals.currentDevicePrice = result.price!;
      }

      callback(DeviceInfoSuccess(result));
    } catch (error) {
      callback(DeviceInfoFailure("Ошибка получения информации"));
    }
  }



  Future<CameraPosition> currentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;
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

  Set<Marker>  markers (List<Device> devices) {
    final Set<Marker> markers = new Set();


    devices.forEach((value) {
      var latitude = double.parse(value.latitude);
      assert(latitude is double);
      var longitude = double.parse(value.longitude);
      assert(longitude is double);
      markers.add( Marker(
          markerId: MarkerId(value.id.toString()),
          position: LatLng(latitude, longitude),
          onTap: () => print('Tapped me at '+value.id.toString()),
        infoWindow: InfoWindow( //popup info
          title: 'Автомат №'+value.id.toString(),
          snippet: value.deviceAddress.toString(),
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker


      ));
    });

    return markers;
  }






}

