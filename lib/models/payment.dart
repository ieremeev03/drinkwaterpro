import 'dart:convert';



Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

Payment paymentFromMap(String str) => Payment.fromMap(json.decode(str));

String paymentToMap(Payment data) => json.encode(data.toMap());

class Payment {
  Payment( {
    required this.id,
    required this.uuidPayment,
    required this.type,
    required this.name,
    this.active,
  });

  int id;
  String uuidPayment;
  String type;
  String name;
  int? active;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    uuidPayment: json["uuidPayment"],
    type: json["type"],
    name: json["name"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid_payment": uuidPayment,
    "type": type,
    "name": name,
    "active": active,
  };

  factory Payment.fromMap(Map<String, dynamic> json) => Payment(
    id: json["id"],
    uuidPayment: json["uuidPayment"],
    type: json["type"],
    name: json["name"],
    active: json["active"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "uuid_payment": uuidPayment,
    "type": type,
    "name": name,
    "active": active,
  };
}

// PostList являются оберткой для массива постов
class paymentMethodList {
  final List<Payment> methods = [];

  paymentMethodList.fromJson(List<dynamic> jsonItems) {
    print('???');
    for (var jsonItem in jsonItems) {
      methods.add(Payment(
          id: jsonItem['id'],
          uuidPayment: jsonItem['uuidPayment'],
          type: jsonItem['type'],
          name: jsonItem['name'],
          active: jsonItem['active']
      )
      );

    }
  }
}


// у нас будут только два состояния
abstract class PaymentAdd {}
// успешное добавление
class PaymentAddSuccess extends PaymentAdd {}
// ошибка
class PaymentAddFailure extends PaymentAdd {}

// у нас будут только два состояния
abstract class Pay {}
// успешное добавление
class PaySuccess extends Pay {}
// ошибка
class PayFailure extends Pay {}

// у нас будут только два состояния
abstract class Checkout {}
// успешное добавление

class CheckoutSuccess extends Checkout {
  final Payment payment;
  CheckoutSuccess(this.payment);
}
// ошибка
class CheckoutFailure extends Checkout {}


abstract class GetPaymentMethodResult {}

// указывает на успешный запрос
class GetPaymentMethodResultSuccess extends GetPaymentMethodResult {
  final paymentMethodList methodList;
  GetPaymentMethodResultSuccess(this.methodList);
}

// произошла ошибка
class GetPaymentMethodResultFailure extends GetPaymentMethodResult {
  final String error;
  GetPaymentMethodResultFailure(this.error);
}

// загрузка данных
class GetPaymentMethodLoading extends GetPaymentMethodResult {
  GetPaymentMethodLoading();
}