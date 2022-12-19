import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// импортируем http пакет
import 'package:http/http.dart' as http;
import 'package:drinkwaterpro/models/user.dart';
import 'package:drinkwaterpro/models/pouring.dart';
import 'package:drinkwaterpro/models/device.dart';
import 'package:drinkwaterpro/models/payment.dart';
import 'package:drinkwaterpro/data/database.dart';

import 'package:flutter_yookassa_sdk/flutter_yookassa_sdk.dart';
import 'package:http_client/console.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;

import 'package:firebase_core/firebase_core.dart';
import 'package:drinkwaterpro/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

// мы ещё не раз будем использовать
// константу SERVER
const String SERVER = "https://lk.drinkwater.pro/api";
final DatabaseHandler handler = DatabaseHandler();

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer =
FirebaseAnalyticsObserver(analytics: analytics);

class Repository {

  Future<void> GA_set_map_route(int device) async {
    await analytics.logEvent(
      name: 'set_map_route',
      parameters: <String, dynamic>{
        'value': device,
      },
    );

    print('GA_set_map_route');
  }

  Future<void> add_log(String str, {String data: ''}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    final url = Uri.parse("$SERVER/addLog?"
        "user_id="+globals.userId.toString()+
        "&platform="+Platform.operatingSystem+
        "&platform_version="+Platform.operatingSystemVersion+
        "&app_version="+version+
        "&app_build="+buildNumber+
        "&message="+str+
        "&data="+data);
    if(globals.debug) {
      final response = await http.get(url);
      //print(response.body);
    }

  }




  Future<PouringList> fetchPourings() async {
    // сначала создаем URL, по которому
    // мы будем делать запрос

    final user = await handler.userInfo();
    final url = Uri.parse("$SERVER/pouringsFromUser?user="+user.id.toString());
    // делаем GET запрос
    final response = await http.get(url);
    //print(url);
    // проверяем статус ответа
    if (response.statusCode == 200) {
      // если все ок то возвращаем посты
      // json.decode парсит ответ
      //print(response.body);
      print('POURING: Наливы пользователя получены');
      return PouringList.fromJson(json.decode(response.body));

    } else {
      // в противном случае вызываем исключение
      throw Exception("failed request");
    }
  }



  Future<DeviceList> fetchDevices() async {
    // сначала создаем URL, по которому
    // мы будем делать запрос
    final url = Uri.parse("$SERVER/devices?lat="+globals.userLat.toString()+"&lon="+globals.userLon.toString());
    // делаем GET запрос
    final response = await http.get(url);
    print('DEVICE: запрос устройств '+ url.toString());
    // проверяем статус ответа
    if (response.statusCode == 200) {
      // если все ок то возвращаем посты
      // json.decode парсит ответ
      print('DEVICE: список получен');
      //print(response.body);
      return DeviceList.fromJson(json.decode(response.body));
    } else {
      print('DEVICE: ошибка получения');
      // в противном случае вызываем исключение
      throw Exception("failed request");
    }
  }

  Future<User> getUser(String token) async {
    final url = Uri.parse("$SERVER/getUserInfo");
    // делаем GET запрос
    final response = await http.post(url,
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      return userFromJson(response.body);
    } else {
      // в противном случае вызываем исключение
      throw Exception("failed request");
    }
  }


  Future<Map<String, dynamic>> sendCode(String phone, String sms_code) async {
    print('USER: Отправляем смс код');
    final url = Uri.parse("$SERVER/loginSms");
    // делаем POST запрос
    final response = await http.post(url,
      body: {'phone' : phone, 'sms_code' : sms_code,  'fmc' : globals.fmcToken},
    );
    print('USER DEBUG: '+response.body);
    // проверяем статус ответа
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      //print(resp['paymmentMethod']);
      return resp;
    } else {
      print('USER: errpr '+ response.body);
      // в противном случае вызываем исключение
      throw Exception("Неверный смс код");
    }
  }

  Future<String> signIn(String phone) async {
    // сначала создаем URL, по которому
    // мы будем делать запрос
    print('Телефон: '+phone);
    final url = Uri.parse("$SERVER/sendSms");
    // делаем GET запрос
    final response = await http.post(url,
        body: {'phone' : phone, 'fcm' : globals.fmcToken, 'fcmAccept' : globals.fmcAccept},
        //headers: { 'Content-Type': 'application/json'}
    );
    //print(url);
    // проверяем статус ответа
    if (response.statusCode == 201) {
      print('ok '+  response.body);
      return response.body;

    } else {
      print('error ' + response.body);
      throw Exception("Пользователь не найден");
    }
  }


  Future<User> editProfile(String token, int id, String name, String city, String email, ) async {
    final url = Uri.parse("$SERVER/editUser");
    print("ID пользователя" + id.toString());
    // делаем POST запрос
    var req_body = new Map();
    req_body['id'] = id;
    req_body['first_name'] = name;
    req_body['city'] = city;
    req_body['email'] = email;

    final response = await http.post(url,
      body: jsonEncode(req_body),
      headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );
    print(response.request.toString());
    // проверяем статус ответа
    if (response.statusCode == 200) {
      print('ok '+ response.body);
      //final us = json.decode(response.body);
      //inspect(response.body.toString());
      //print(1111);
      return userFromJson(response.body);
    } else {
      print('error '+ response.body);
      throw Exception("Ошибка обновления профиля");
    }
  }

  Future<bool> removeProfile(String token) async {
    final url = Uri.parse("$SERVER/removeUser");
    print("ID пользователя" + globals.userId.toString());
    // делаем POST запрос
    var req_body = new Map();
    req_body['id'] = globals.userId;


    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );
    print(response.request.toString());
    // проверяем статус ответа
    if (response.statusCode == 200) {
      print('ok '+ response.body);
      add_log('User: пользователь удален', data: globals.userId.toString());
      return true;
    } else {
      print('error '+ response.body);
      add_log('User: ошибка удаления пользователя');
      throw Exception("Ошибка удаления профиля");
    }
  }

  Future<Device> getDeviceInfo(String token, String code) async {
    final url = Uri.parse("$SERVER/getDeviceInfo");
    var req_body = new Map();
    req_body['code'] = code;
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('DEVICE:' + response.body);
      add_log('DEVICE: запрос инфы', data: response.body);
      return deviceFromJson(response.body);
    } else {
      print(response.body);
      print('DEVICE: error ' + response.body);
      add_log('DEVICE: error', data: response.body);
      throw Exception("Пользователь не найден");
    }
  }


  Future<String> checkout(phone) async {
    print('PAYMENT: создание платежа');
    final inputData = TokenizationModuleInputData(
      clientApplicationKey: "live_OTM1Mjkz0_CGHpGEgGN-IEGtJkbLvD7rQnSvcihC8vY",
      shopName: "Налей Воды",
      purchaseDescription: "Авторизация карты",
      amount: const Amount(value: 1, currency: Currency.rub()),
      savePaymentMethod: SavePaymentMethod.on,
      shopId: '935293',
      userPhoneNumber: phone,
      customerId: phone,
      isLoggingEnabled: true,
      tokenizationSettings: TokenizationSettings(
        paymentMethodTypes: PaymentMethodTypes.bankCard(),
        showYooKassaLogo: false,
      ),
    );
    try {
      final paymentData = await FlutterYookassaSdk.instance.tokenization(inputData);
      print('YOOMONEY CHECKOUT: '+paymentData.token.toString());
      return paymentData.token.toString();
    } on YooKassaException catch (error) {
      print('YOOMONEY CHECKOUT: '+error.toString());
      return error.toString();
    }
  }


  Future<Map> auth(token, value, description) async {
    final idempotenceKey = 'some_unique_idempotence_key' +
        DateTime.now().microsecondsSinceEpoch.toString();
    Map paymentResult;

    final httpClient = ConsoleClient();
    Request request = Request(
        'POST',
        Uri.parse(
            'https://api.yookassa.ru/v3/payments'),
        headers: Headers(),

        body: json.encode({
          "payment_token":
          "$token",
          "amount": {
            'value' : value,
            'currency': 'RUB',
          },
          "confirmation": {
            "type": "redirect",
            "return_url": "https://4081d9747ee2.ngrok.io/v1.3/verifications/yandex_checkout"
          },
          'capture' : true,
          "description": "$description"
        }));


    request.headers.add("Idempotence-Key", idempotenceKey);
    request.headers.add(
        'Authorization',
        "Basic " +
            base64Encode(
                utf8.encode("935293:live_ix6WVIY3ivKGBcVRWXFBLSBsi258MjVkJVtRZcT5ZOk")));
    request.headers.add('Content-Type', 'application/json');
    Response response = await httpClient.send(request);
    paymentResult =
        json.decode(await response.readAsString());
    //print(paymentResult['confirmation']);
    print(paymentResult);

    final payResult =  await FlutterYookassaSdk.instance.confirm3dsCheckout(
      confirmationUrl: paymentResult['confirmation']['confirmation_url'],
      paymentMethodType: paymentResult['payment_method']['type'],
    );

    return paymentResult;

  }

  Future<Map> info(payment) async {
    final idempotenceKey = 'some_unique_idempotence_key' +
        DateTime.now().microsecondsSinceEpoch.toString();
    Map infoResult;
    String infoJson;

    final httpClient = ConsoleClient();
    Request request = Request(
        'GET',
        Uri.parse(
            'https://api.yookassa.ru/v3/payments/'+payment),
        headers: Headers());


    //request.headers.add("Idempotence-Key", idempotenceKey);
    request.headers.add(
        'Authorization',
        "Basic " +
            base64Encode(
                utf8.encode("935293:live_ix6WVIY3ivKGBcVRWXFBLSBsi258MjVkJVtRZcT5ZOk")));
    //request.headers.add('Content-Type', 'application/json');
    Response response = await httpClient.send(request);
    //print(await response.readAsString());
    infoJson = await response.readAsString();
    infoResult =  json.decode(infoJson);
    print(infoResult['status']);
    add_log('PAYMENT: Статус оплаты: '+ infoResult['status'], data: infoJson);
    return infoResult;

  }

  Future<Map> payCard(token, value, description) async {
    final idempotenceKey = 'some_unique_idempotence_key' +
        DateTime.now().microsecondsSinceEpoch.toString();
    Map paymentResult;
    print(token+ ' ' + value.toString() + ' ' + description);
    add_log("PAYMENT: Оплата токеном", data: token);
    final httpClient = ConsoleClient();
    String payment;
    Request request = Request(
        'POST',
        Uri.parse(
            'https://api.yookassa.ru/v3/payments'),
        headers: Headers(),
        body: json.encode({
          "amount": {
            'value' : value,
            'currency': 'RUB',
          },
          'payment_method_id' : '$token',
          'capture' : true,
          "description": "$description"
        }));
    request.headers.add("Idempotence-Key", idempotenceKey);
    request.headers.add(
        'Authorization',
        "Basic " +
            base64Encode(
                utf8.encode("935293:live_ix6WVIY3ivKGBcVRWXFBLSBsi258MjVkJVtRZcT5ZOk")));
    request.headers.add('Content-Type', 'application/json');
    Response response = await httpClient.send(request);

    payment = await response.readAsString();
    add_log("PAYMENT: Результат оплаты", data: payment);
    paymentResult = json.decode(payment);
    print(paymentResult);
    return paymentResult;
  }

  Future<Payment> addPaymentMethod(pay, token) async {
   // print(pay);
    print(pay['id']);

    var req_body = new Map();
    req_body['uuid'] = pay['payment_method']['id'];
    req_body['type'] = pay['payment_method']['card']['card_type'];
    req_body['first6'] = pay['payment_method']['card']['first6'];
    req_body['last4'] = pay['payment_method']['card']['last4'];

    final url = Uri.parse("$SERVER/addUserPaymentMethod");

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept' : 'application/json'}
    );

    if (response.statusCode == 200) {
      print('Метод добавлен: ' + response.body);
      add_log('PAYMENT: Метод оплаты добавлен на сервер');
      return paymentFromJson(response.body);
    } else {
      print('error ' + response.body);
      add_log('PAYMENT: Ошибка добавления метода оплаты на сервер');
      throw Exception("Пользователь не найден");
    }

  }

  Future<Payment> removePaymentMethod(uuid, token) async {

    var req_body = new Map();
    req_body['uuid'] = uuid;
    final url = Uri.parse("$SERVER/removeUserPaymentMethod");

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept' : 'application/json'}
    );

    if (response.statusCode == 200) {
      print('Метод удален: ' + response.body);
      add_log('PAYMENT: Метод оплаты удален с сервера');
      return paymentFromJson(response.body);
    } else {
      print('error ' + response.body);
      add_log('PAYMENT: Ошибка удаления метода оплаты с сервера');
      throw Exception("Пользователь не найден");
    }

  }

  Future<String> changePaymentMethod(uuid, token) async {


    var req_body = new Map();
    req_body['uuid'] = uuid;
    
    final url = Uri.parse("$SERVER/changeUserPaymentMethod");

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept' : 'application/json'}
    );

    if (response.statusCode == 200) {
      print('Метод изменен: ' + response.body);
      add_log('PAYMENT: Метод оплаты изменен');
     return "ok";
    } else {
      print('error ' + response.body);
      add_log('PAYMENT: Ошибка изменения метода оплаты');
      throw Exception("Пользователь не найден");
    }

  }

  Future<paymentMethodList> getPaymentMethods(token) async {
    final url = Uri.parse("$SERVER/getUserPaymentMethod");
    // делаем GET запрос
    final response = await http.post(url,
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('Методы получены: ' + response.body.toString());
      add_log('PAYMENT: Метод оплаты получены с сервера');
      return paymentMethodList.fromJson(json.decode(response.body));
    } else {
      print('error ' + response.body);
      add_log('PAYMENT: ошибка получения методов оплаты');
      throw Exception("Пользователь не найден");
    }
  }


  Future<Pouring> getLastPouring(token) async {
    final url = Uri.parse("$SERVER/getLastPouring");
    print('Получаем информацию о наливе с сервера...');
    var req_body = new Map();
    req_body['device_id'] = globals.currentDeviceId;
    req_body['user_id'] = globals.userId;

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('Налив получен: ' + response.body.toString());
      final pouring = Pouring.fromJson(json.decode(response.body));
      print(pouring.liters);
      return pouring;
    } else {
      print('error ' + response.body);
      add_log("POURING: Налив не найден");
      throw Exception("Налив не найден");
    }

  }

  Future<Pouring> setPayServer(token , order, summ, uuid) async {
    final url = Uri.parse("$SERVER/payLastPouring");
    print('Изменяем налив на сервере...');
    add_log("POURING: Изменяем налив на сервере...");
    var req_body = new Map();
    req_body['id'] = order;
    req_body['summ'] = summ;
    req_body['uuid'] = uuid;

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print(response.body);
      print('POURING: Налив изменен: ' + response.body.toString());
      add_log("POURING: Налив изменен");
      final pouring = Pouring.fromJson(json.decode(response.body));
      print(pouring.liters);
      return pouring;
    } else {
      print('POURING: ' + response.body);
      add_log("POURING: Ошибка обновления налива", data: response.body);
      throw Exception("Ошибка обновления налива");
    }

  }

  Future<Map>  payBonus(token, summ) async {
    final url = Uri.parse("$SERVER/payBonus");
    print('Производим оплату бонусами...');
    var req_body = new Map();
    req_body['summ'] = summ;

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('Оплата прошла: ' + response.body.toString());

      return jsonDecode(response.body.toString());
    } else {
      print('error ' + response.body);
      throw Exception("Ошибка оплаты");
    }

  }

  Future<String> unlockDevice(token, id) async {
    final url = Uri.parse("$SERVER/unlockDevice");
    print('DEVICE: Производим активацию аппарата #'+id.toString()+'...');
    var req_body = new Map();
    req_body['id'] = id;


    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('DEVICE: ' + response.body.toString());
      //globals.currentPouringId = response.body;
      add_log('POURING: Создан налив', data: response.body);
      return response.body.toString();
    } else {
      print('DEVICE: ' + response.body);
      throw Exception("Ошибка активации");
    }

  }

  Future<String> lockDevice(token, id) async {
    final url = Uri.parse("$SERVER/lockDevice");
    print('DEVICE: Производим деаактивацию аппарата #'+id.toString()+'...');
    var req_body = new Map();
    req_body['id'] = id;


    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('DEVICE: ' + response.body.toString());

      return response.body.toString();
    } else {
      print('DEVICE: ' + response.body);
      throw Exception("Ошибка деактивации");
    }

  }

  Future<String> startPouring(token, id) async {
    final url = Uri.parse("$SERVER/startPouring");
    print('DEVICE: Производим активацию налива...');
    var req_body = new Map();
    req_body['id'] = id;

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('DEVICE: ' + response.body.toString());

      return response.body.toString();
    } else {
      print('DEVICE: ' + response.body);
      throw Exception("Ошибка активации");
    }

  }

  Future<String> stopPouring(token, id) async {
    final url = Uri.parse("$SERVER/stopPouring");
    print('DEVICE: Производим останов налива...');
    var req_body = new Map();
    req_body['id'] = id;

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('DEVICE: ' + response.body.toString());

      return response.body.toString();
    } else {
      print('DEVICE: ' + response.body);
      throw Exception("Ошибка активации");
    }

  }

  Future<String> startOzon(token, id) async {
    final url = Uri.parse("$SERVER/startOzon");
    print('DEVICE: Производим активацию озона...');
    var req_body = new Map();
    req_body['id'] = id;

    // делаем GET запрос
    final response = await http.post(url,
        body: jsonEncode(req_body),
        headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      print('DEVICE: ' + response.body.toString());

      return response.body.toString();
    } else {
      print('DEVICE: ' + response.body);
      throw Exception("Ошибка активации");
    }

  }

  Future<String> getSettings() async {
    // сначала создаем URL, по которому
    // мы будем делать запрос
    final token_api = await handler.getParam('api_token');
    final user = await handler.userInfo();
    //await Future.delayed(Duration(seconds: 2));
    add_log('Запрос настроек', data: globals.fmcToken!);
    final url = Uri.parse("$SERVER/getSettings?fmcAccept="+globals.fmcAccept!+"&fmc="+globals.fmcToken!);
    print(url);
    add_log(url.toString());
    // делаем GET запрос
    final response = await http.get(url,

        headers: { 'Authorization': 'Bearer $token_api', 'Content-Type': 'application/json'}
    );
    //print(url);
    // проверяем статус ответа
    if (response.statusCode == 200) {
      // если все ок то возвращаем посты
      // json.decode парсит ответ
      final settings = json.decode(response.body);
      //print(settings);
      print("------------");
      settings.forEach((setting) {

        if (setting['key'] == 'bonus') {
         globals.bonus =   int.parse(setting['value']);
         print('Settings Bonus: '+globals.bonus.toString());
        }

        if (setting['key'] == 'waitPouring') {
          globals.waitPouring =   int.parse(setting['value']);
          print('Settings waitPouring: '+globals.waitPouring.toString());
        }

        if (setting['key'] == 'blockApp') {
          globals.blockApp =   int.parse(setting['value']);
          print('Settings blockApp: '+globals.blockApp.toString());
        }

        if (setting['key'] == 'blockMessage') {
          globals.blockMessage =  setting['value'];
          print('Settings blockMessage: '+globals.blockMessage.toString());
        }

      });
      print("------------");
      return "Ok";

    } else {
      // в противном случае вызываем исключение
      throw Exception("failed request");
    }
  }


  //Firebase


}

