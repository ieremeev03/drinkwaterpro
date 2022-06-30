import 'dart:async';
import 'dart:convert';


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

// мы ещё не раз будем использовать
// константу SERVER
const String SERVER = "https://lk.drinkwater.pro/api";
final DatabaseHandler handler = DatabaseHandler();

class Repository {

  // обработку ошибок мы сделаем в контроллере
  // мы возвращаем Future объект, потому что
  // fetchPhotos асинхронная функция
  // асинхронные функции не блокируют UI
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
    final url = Uri.parse("$SERVER/devices");
    // делаем GET запрос
    final response = await http.get(url);
    print('DEVICE: запрос устройств');
    // проверяем статус ответа
    if (response.statusCode == 200) {
      // если все ок то возвращаем посты
      // json.decode парсит ответ
      print('DEVICE: список получен');
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
      body: {'phone' : phone, 'sms_code' : sms_code},
    );
    print('USER DEBUG: '+response.body);
    // проверяем статус ответа
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      print(resp['paymmentMethod']);
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
        body: {'phone' : phone},
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
    print(city);
    req_body['email'] = email;

    final response = await http.post(url,
      body: jsonEncode(req_body),
      headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
    );
    print(response.request.toString());
    // проверяем статус ответа
    if (response.statusCode == 200) {
      print('ok '+ response.body);
      return userFromJson(response.body);
    } else {
      print('error '+ response.body);
      throw Exception("Ошибка обновления профиля");
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
      return deviceFromJson(response.body);
    } else {
      print('DEVICE: error ' + response.body);
      throw Exception("Пользователь не найден");
    }
  }


  Future<String> checkout(phone) async {
    print('PAYMENT: создание платежа');
    final inputData = TokenizationModuleInputData(
      clientApplicationKey: "test_OTA1NDk3wVpMQneHZ9iQrxdT8MsNtHPVZ8fxBFwFxjo",
      shopName: "Налей Воды",
      purchaseDescription: "Авторизация карты",
      amount: const Amount(value: 1, currency: Currency.rub()),
      savePaymentMethod: SavePaymentMethod.on,
      shopId: '905497',
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
                utf8.encode("905497:test_CCk1K1MZCjWqAjA0NI8sLe96B2jGvpShdFtRf1s8HDM")));
    request.headers.add('Content-Type', 'application/json');
    Response response = await httpClient.send(request);
    paymentResult =
        json.decode(await response.readAsString());
    print(paymentResult);
    return paymentResult;

  }

  Future<Map> payCard(token, value, description) async {
    final idempotenceKey = 'some_unique_idempotence_key' +
        DateTime.now().microsecondsSinceEpoch.toString();
    Map paymentResult;
    print(token+ ' ' + value.toString() + ' ' + description);
    final httpClient = ConsoleClient();
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
                utf8.encode("905497:test_CCk1K1MZCjWqAjA0NI8sLe96B2jGvpShdFtRf1s8HDM")));
    request.headers.add('Content-Type', 'application/json');
    Response response = await httpClient.send(request);
    paymentResult =
        json.decode(await response.readAsString());
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
      return paymentFromJson(response.body);
    } else {
      print('error ' + response.body);
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
      return paymentMethodList.fromJson(json.decode(response.body));
    } else {
      print('error ' + response.body);
      throw Exception("Пользователь не найден");
    }
  }


  Future<Pouring> getLastPouring(token) async {
    final url = Uri.parse("$SERVER/getLastPouring");
    print('Получаем информацию о наливе с сервера...');
    var req_body = new Map();
    req_body['device_id'] = globals.currentDeviceId;

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
      throw Exception("Налив не найден");
    }

  }

  Future<Pouring> setPayServer(token , order, summ, uuid) async {
    final url = Uri.parse("$SERVER/payLastPouring");
    print('Изменяем налив на сервере...');
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
      final pouring = Pouring.fromJson(json.decode(response.body));
      print(pouring.liters);
      return pouring;
    } else {
      print('POURING: ' + response.body);
      throw Exception("Ошибка обновления налива");
    }

  }

  Future<String> payBonus(token, summ) async {
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

      return response.body.toString();
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

      return response.body.toString();
    } else {
      print('DEVICE: ' + response.body);
      throw Exception("Ошибка активации");
    }

  }

}

