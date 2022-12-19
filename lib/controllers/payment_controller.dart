
import '../data/repository.dart';
import '../data/database.dart';
import '../models/payment.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:firebase_analytics/firebase_analytics.dart';

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
      final paymentMethodList = await repo.getPaymentMethods(token_api);
      // если все ок то обновляем состояние на успешное
      setState(() => currentState = GetPaymentMethodResultSuccess(paymentMethodList));
    } catch (error) {

    }
  }




  void addPaymentMethod(void Function(Checkout) callback) async {
    final add_method;
    try {
      print('PAYMENT: Добавление метода оплаты');
      repo.add_log('PAYMENT: Добавление метода оплаты');
      final token_api = await handler.getParam('api_token');
      final user = await  handler.userInfo();
      final token_ya = await repo.checkout(user.phone);
      final pay = await repo.auth(token_ya,1,'Авторизация карты');
      final info = await repo.info(pay['id']);
      repo.add_log('PAYMENT: статус платежа за авторизацию: '+info['status']);

      if (info['status']=='succeeded') {
        add_method = await repo.addPaymentMethod(pay, token_api);
        callback(CheckoutSuccess(add_method));
      } else {

        callback(CheckoutFailure());
      }
      // сервер вернул результат

    } catch (error) {
      // произошла ошибка
      print(error);
      callback(CheckoutFailure());
    }
  }

  void removePaymentMethod(String uuidPayment) async {
    final add_method;
    try {
      print('PAYMENT: Удаление метода оплаты');
      repo.add_log('PAYMENT: Удаление метода оплаты');
      final token_api = await handler.getParam('api_token');
      final user = await  handler.userInfo();
      add_method = await repo.removePaymentMethod(uuidPayment, token_api);

    } catch (error) {
      // произошла ошибка
      print(error);

    }
  }

  void changePaymentMethod(uuid) async {

    try {
      print('PAYMENT: Изменение метода оплаты');
      repo.add_log('PAYMENT: Изменение метода оплаты');
      final token_api = await handler.getParam('api_token');
      repo.changePaymentMethod(uuid, token_api);


    } catch (error) {
      // произошла ошибка
      print(error);

    }
  }


  void pay(uuid, summ, liters, void Function(Pay) callback) async {
    final pay_result_bonus;
    final pay_result;
    String affiliation = 'Банковсккя карта';
    //Map pay_result;
    try {
      final token_api = await handler.getParam('api_token');
      if (uuid!='0') {
        repo.add_log('PAYMENT: Оплата налива с карты');
        pay_result = await repo.payCard(
            uuid, summ, 'Оплата чистой воды ' + liters.toString() + 'л.');

      } else {
        repo.add_log('PAYMENT: Оплата  налива с бонусного счета');
        affiliation = "Бонусный счет";
        pay_result = await repo.payBonus(token_api,summ);
      }

      if ( pay_result['error'] != null && pay_result['error'] == 'error' ) {
        repo.add_log('PAYMENT: Произошла ошибка оплаты. Деньги будут списаны позже');
        globals.payStatus = "Произошла ошибка оплаты. Деньги будут списаны позже.";
        callback(PayFailure());
      } else {
        repo.add_log('PAYMENT: Оплата прошла успешно');

        final jeggingsWithQuantity = AnalyticsEventItem(
          itemName: "Чистая вода",
          price: globals.currentDevicePrice,
          promotionName: 'Оплата чистой воды ' + liters.toString() + 'л.',
          quantity: 1,
        );

        await FirebaseAnalytics.instance.logPurchase(
          transactionId: globals.order.toString(),
          affiliation: affiliation,
          currency: 'RUB',
          value: summ,
          items: [jeggingsWithQuantity],
        );

        final payOrderServer = await repo.setPayServer(
        token_api, globals.order, globals.summ, uuid);

        globals.currentDeviceId = 0;
        globals.currentDevicePrice = 0;
        globals.liters = 0;
        globals.summ = 0;
        globals.order = 0;
        // сервер вернул результат
        callback(PaySuccess());
      }
    } catch (error) {
      // произошла ошибка
      print(error);
      repo.add_log('PAYMENT: ошибка оплаты');
      callback(PayFailure());
    }
  }

}


