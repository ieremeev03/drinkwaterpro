
import '../data/repository.dart';
import '../models/pouring.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../data/database.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'dart:convert';


class PouringController extends ControllerMVC {
  // создаем наш репозиторий
  final Repository repo = new Repository();




  // конструктор нашего контроллера
  PouringController();


  LastPouring lastPouring = LastPouringLoading();

  final DatabaseHandler handler = DatabaseHandler();
  late PaymentController _controllerPay;


  void init() async {

    unlockDevice(globals.currentDeviceId);
    print(globals.userPhone);

    //final channel = IOWebSocketChannel.connect('wss://lk.drinkwater.pro:9000/?user=79120701060');

    //channel.sink.add('received!');

  }





  void unlockDevice(id) async {
    try {
      print('DEVICE: Активация аппарата...');
      repo.add_log('DEVICE: Активация аппарата...');
      final token_api = await handler.getParam('api_token');
      final unlock = await repo.unlockDevice(token_api,id);


    } catch (error) {

      print('DEVICE:' + error.toString());
    }
  }

  void lockDevice(id) async {
    try {
      print('DEVICE: Дективация аппарата...');
      repo.add_log('DEVICE: Дективация аппарата...');
      final token_api = await handler.getParam('api_token');
      final lock = await repo.lockDevice(token_api,id);


    } catch (error) {
      print('DEVICE:' + error.toString());
    }
  }

  void startPouring(id) async {
    try {
      print('DEVICE: Стартуем налив...');
      repo.add_log('DEVICE: Стартуем налив...');
      final token_api = await handler.getParam('api_token');
      final start = await repo.startPouring(token_api,id);


    } catch (error) {
      print('DEVICE:' + error.toString());
    }
  }

  void stopPouring(id) async {
    try {
      print('DEVICE: Останавливаем налив...');
      repo.add_log('DEVICE: Останавливаем налив...');
      final token_api = await handler.getParam('api_token');
      final stop = await repo.stopPouring(token_api,id);


    } catch (error) {
      print('DEVICE:' + error.toString());
    }
  }

  void startOzon(id) async {
    try {
      print('DEVICE: Запускаем озонирование...');
      repo.add_log('DEVICE: Запускаем озонирование...');
      final token_api = await handler.getParam('api_token');
      final ozon = await repo.startOzon(token_api,id);


    } catch (error) {
      print('DEVICE:' + error.toString());
    }
  }

  void getLastPouring(void Function(LastPouring) callback) async {
    try {
      lockDevice(globals.currentDeviceId);
      print('Ожидание... '+ globals.waitPouring.toString() + 'сек');
      await Future.delayed(Duration(seconds: globals.waitPouring));
      print('Запрос налива...');
      repo.add_log('POURING: Запрос последнего налива...');
      final token_api = await handler.getParam('api_token');
      final pouring = await repo.getLastPouring(token_api);


      globals.liters = pouring.liters;
      globals.summ = pouring.liters! * globals.currentDevicePrice;
      double summa = double.parse((globals.summ!).toStringAsFixed(2));

      globals.summ = summa;
      globals.order = pouring.id;

      print('Налив №: '+ globals.order.toString());
      print('Цена: '+ globals.currentDevicePrice.toString());
      print('Литров: '+ globals.liters.toString());
      print('Рублей: '+ summa.toString());

      repo.add_log('POURING: Полученный налив', data: jsonEncode(pouring));

      // сервер вернул результат
      setState(() => lastPouring = LastPouringSuccess(pouring));
      callback(LastPouringSuccess(pouring));
    } catch (error) {
      // произошла ошибка
      print(error);
      setState(() => lastPouring = LastPouringFailure(error.toString()));
      callback(LastPouringFailure(error.toString()));
    }
  }




}

