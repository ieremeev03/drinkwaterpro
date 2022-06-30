
import '../data/repository.dart';
import '../models/pouring.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../data/database.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/controllers/payment_controller.dart';


class PouringController extends ControllerMVC {
  // создаем наш репозиторий
  final Repository repo = new Repository();


  // конструктор нашего контроллера
  PouringController();

  final DatabaseHandler handler = DatabaseHandler();
  late PaymentController _controllerPay;

  String broker           = '79.174.13.141';
  int port                = 1883;
  String username         = '0022';
  String passwd           = '123456';
  String clientIdentifier = 'android';

  void init() async {
    unlockDevice(globals.currentDeviceId);
  }


  void unlockDevice(id) async {
    try {
      print('DEVICE: Активация аппарата...');
      final token_api = await handler.getParam('api_token');
      final unlock = await repo.unlockDevice(token_api,id);


    } catch (error) {
      print('DEVICE:' + error.toString());
    }
  }

  void getLastPouring(void Function(LastPouring) callback) async {
    try {
      print('Запрос налива...');
      final token_api = await handler.getParam('api_token');
      final pouring = await repo.getLastPouring(token_api);


      globals.liters = pouring.liters;
      globals.summ = pouring.liters! * globals.currentDevicePrice;
      globals.order = pouring.id;

      print('Налив №: '+ globals.order.toString());
      print('Цена: '+ globals.currentDevicePrice.toString());
      print('Литров: '+ globals.liters.toString());
      print('Рублей: '+ globals.summ.toString());

      // сервер вернул результат
      callback(LastPouringSuccess(pouring));
    } catch (error) {
      // произошла ошибка
      print(error);
      callback(LastPouringFailure(error.toString()));
    }
  }

}

