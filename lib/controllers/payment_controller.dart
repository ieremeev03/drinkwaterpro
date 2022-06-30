
import '../data/repository.dart';
import '../data/database.dart';
import '../models/payment.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;

class PaymentController extends ControllerMVC {
  // создаем наш репозиторий

  final Repository repo = Repository();

  final DatabaseHandler handler = DatabaseHandler();

  // конструктор нашего контроллера
  PaymentController();

  // первоначальное состояние - загрузка данных
  GetPaymentMethodResult currentState = GetPaymentMethodLoading();

  void init() async {
    try {
      // получаем данные из репозитория
      final token_api = await handler.getParam('api_token');
      print('init()');
      final paymentMethodList = await repo.getPaymentMethods(token_api);
      // если все ок то обновляем состояние на успешное
      setState(() => currentState = GetPaymentMethodResultSuccess(paymentMethodList));
    } catch (error) {

    }
  }




  void addPaymentMethod(void Function(Checkout) callback) async {
    try {
      print('PAYMENT: Добавление метода оплаты');
      final token_api = await handler.getParam('api_token');
      final user = await  handler.userInfo();
      final token_ya = await repo.checkout(user.phone);
      final pay = await repo.auth(token_ya,1,'Авторизация карты');
      final add_method = await repo.addPaymentMethod(pay,token_api);
      // сервер вернул результат
      callback(CheckoutSuccess(add_method));
    } catch (error) {
      // произошла ошибка
      print(error);
      callback(CheckoutFailure());
    }
  }

  void pay(uuid, summ, liters, void Function(Pay) callback) async {
    try {
      final token_api = await handler.getParam('api_token');
      if (uuid!='0') {
        final pay = await repo.payCard(
            uuid, summ, 'Оплата чистой воды ' + liters.toString() + 'л.');
      } else {
        final pay = await repo.payBonus(token_api,summ);
      }
      final payOrderServer = await repo.setPayServer(token_api, globals.order, globals.summ, uuid);

      globals.currentDeviceId = 0;
      globals.currentDevicePrice = 0;
      globals.liters = 0;
      globals.summ = 0;
      globals.order = 0;
      // сервер вернул результат
      callback(PaySuccess());
    } catch (error) {
      // произошла ошибка
      print(error);
      callback(PayFailure());
    }
  }

}


