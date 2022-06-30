
// сначала создаем объект самого поста
import 'dart:convert';
import 'dart:developer';

class Pouring {
  // все поля являются private
  // это сделано для инкапсуляции данных
  final int? _id;
  final String? _address;
  final double? _liters;
  final double? _summ;
  final bool? _cashless;
  final String? _card_type;
  final String? _last4;
  final DateTime? _date;


  // создаем getters для наших полей
  // дабы только мы могли читать их
  int? get id => _id;
  String? get address => _address;
  double? get liters => _liters;
  double? get summ => _summ;
  bool? get cashless => _cashless;
  String? get card_type => _card_type;
  String? get last4 => _last4;
  DateTime? get date => _date;

  // добавим новый конструктор для поста
  Pouring(this._id, this._address, this._liters, this._summ, this._cashless,this._card_type,this._last4, this._date);


  // toJson() превращает Post в строку JSON
  String toJson() {
    return json.encode({
      "address": _address,
      "liters": _liters,
      "summ": _summ,
      "cashless": _cashless,
      "card_type": _card_type,
      "last4": _last4,
      "date": _date,

    });
  }

  // Dart позволяет создавать конструкторы с разными именами
  // В данном случае Post.fromJson(json) - это конструктор
  // здесь мы принимаем объект поста и получаем его поля
  // обратите внимание, что dynamic переменная
  // может иметь разные типы: String, int, double и т.д.
  Pouring.fromJson(Map<String, dynamic> json) :
        this._id = json["id"],
        this._address = json["address"],
        this._liters = json["liters"].toDouble()!,
        this._summ = json["summ"],
        this._cashless = json["cashless"],
        this._card_type = json["card_type"],
        this._last4 = json["last4"],
        this._date = json["date"];

}

// PostList являются оберткой для массива постов
class PouringList {
  final List<Pouring> pourings = [];

  PouringList.fromJson(List<dynamic> jsonItems) {
     for (var jsonItem in jsonItems) {
       pourings.add(Pouring(
         jsonItem['id'],
         jsonItem['address'],
         jsonItem['liters'].toDouble(),
         jsonItem['summ'].toDouble(),
         jsonItem['cashless'],
         jsonItem['card_type'],
         jsonItem['last4'],
         DateTime.parse(jsonItem['date']),
       ));

      }
  }
}


// наше представление будет получать объекты
// этого класса и определять конкретный его
// подтип
abstract class HistoryResult {}

// указывает на успешный запрос
class HistoryResultSuccess extends HistoryResult {
  final PouringList pouringList;
  HistoryResultSuccess(this.pouringList);
}

// произошла ошибка
class HistoryResultFailure extends HistoryResult {
  final String error;
  HistoryResultFailure(this.error);
}

// загрузка данных
class HistoryResultLoading extends HistoryResult {
  HistoryResultLoading();
}


abstract class LastPouring {}

// указывает на успешный запрос
class LastPouringSuccess extends LastPouring {
  final Pouring pouring;
  LastPouringSuccess(this.pouring);
}

// произошла ошибка
class LastPouringFailure extends LastPouring {
  final String error;
  LastPouringFailure(this.error);
}