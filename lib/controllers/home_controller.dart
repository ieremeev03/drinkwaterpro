
import 'package:flutter/material.dart';
import '../data/database.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../models/tab.dart';
import '../models/user.dart';
import 'dart:typed_data';

// библиотека mvc_pattern предлагает
// нам специальный класс ControllerMVC,
// который предоставит нам setState метод
class HomeController extends ControllerMVC {

  // ссылка на объект самого контроллера
  static HomeController? _this;
  static HomeController? get controller => _this;
  final DatabaseHandler handler = DatabaseHandler();

  // сам по себе factory конструктор не создает
  // экземляра класса HomeController
  // и используется для различных кастомных вещей
  // в данном случае мы реализуем паттерн Singleton
  // то есть будет существовать единственный экземпляр
  // класса HomeController


  factory HomeController() {
    if (_this == null) _this = HomeController._();
    return _this!;
  }

  HomeController._();

  LoginResult currentState = LoginResultLoading();

  void init() async {
    try {
      // получаем данные из репозитория
      final userLogin = await handler.isLoginUser();
      // если все ок то обновляем состояние на успешное
      setState(() => currentState = LoginResultSuccess(userLogin));
    } catch (error) {
      // в противном случае произошла ошибка
      setState(() => currentState = LoginResultFailure("No Login User"));
    }

  }

  // GlobalKey будет хранить уникальный ключ,
  // по которому мы сможем получить доступ
  // к виджетам, которые уже находяться в иерархии
  // NavigatorState - состояние Navigator виджета
  // знак _ как уже было отмечено указывает на то,
  // что это private переменная, поэтому мы
  // не сможем получить доступ извне к _navigatorKeys
  final _navigatorKeys = {
    TabItem.HISTORY: GlobalKey<NavigatorState>(),
    TabItem.MAP: GlobalKey<NavigatorState>(),
    TabItem.PROFILE: GlobalKey<NavigatorState>(),
  };

  // ключевое слово get указывает на getter
  // мы сможем только получить значение  _navigatorKeys,
  // но не сможем его изменить
  // это называеться инкапсуляцией данных (один из принципов ООП)
  Map<TabItem, GlobalKey> get navigatorKeys => _navigatorKeys;

  // текущий выбранный элемент
  var _currentTab = TabItem.MAP;

  // то же самое и для текущего выбранного пункта меню
  TabItem get currentTab => _currentTab;

  // выбор элемента меню
  // здесь мы делаем функцию selectTab публичной
  // чтобы смогли получить доступ из HomePage
  // обратите внимание, что библиотека mvc_pattern
  // предоставляет нам возможность иметь состояние в контроллере,
  // что очень удобно
  void selectTab(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
  }


  Future<bool> isLogin() async {
    print('Проверка на логин...');
    var state = await handler.isLoginUser();
    print('Результат: ' + state.toString() );
    return state;
  }

}