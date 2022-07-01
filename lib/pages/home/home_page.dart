import 'package:drinkwaterpro/pages/auth/mobile.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:drinkwaterpro/models/tab.dart';

import 'package:drinkwaterpro/controllers/home_controller.dart';

import 'bottom_navigation.dart';
import 'tab_navigator.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/models/user.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends StateMVC {
  // ссылка на наш контроллер
  late HomeController _con;

  _HomePageState() : super(HomeController()) {
    _con = controller as HomeController;
  }



  @override
  void initState() {
    super.initState();
    _con.init();
  }

  @override
  Widget build(BuildContext context) {
    final state = _con.currentState;

   // print(state);


   if (state is LoginResultLoading)
     {
       return Center(
         child: CircularProgressIndicator(),
       );
     }
    else {
     FlutterNativeSplash.remove();
     final islogin = (state as LoginResultSuccess).userLogin;
      //print(islogin);
      if(islogin) {
        return WillPopScope(
          // логика обработки кнопки back может быть разной
          // здесь реализована следующая логика:
          // когда мы находимся на первом пункте меню (посты)
          // и нажимаем кнопку Back, то сразу выходим из приложения
          // в противном случае выбранный элемент меню переключается
          // на предыдущий: c заданий на альбомы, с альбомов на посты,
          // и после этого только выходим из приложения
          onWillPop: () async {
            if (_con!.currentTab != TabItem.HISTORY) {
              if (_con!.currentTab == TabItem.MAP) {
                _con!.selectTab(TabItem.PROFILE);
              } else {
                _con!.selectTab(TabItem.HISTORY);
              }
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            // Stack размещает один элемент над другим
            // Проще говоря, каждый экран будет находится
            // поверх другого, мы будем только переключаться между ними
            body: Stack(children: <Widget>[

              _buildOffstageNavigator(TabItem.HISTORY),
              _buildOffstageNavigator(TabItem.MAP),
              _buildOffstageNavigator(TabItem.PROFILE),

            ]),

            bottomNavigationBar: MyBottomNavigation(
              currentTab: _con!.currentTab,
              onSelectTab: _con!.selectTab,
            ),
          ),);
      } else {
        return LoginPage();
      }
    }


       print('Проверка авторизации: ' + globals.isLoggedIn.toString());
  }

  // Создание одного из экранов - посты, альбомы или задания
  Widget _buildOffstageNavigator(TabItem tabItem) {

    return Offstage(
      // Offstage работает следующим образом:
      // если это не текущий выбранный элемент
      // в нижнем меню, то мы его скрываем
      offstage: _con!.currentTab != tabItem,
      // TabNavigator мы создадим позже
      child: TabNavigator(
        navigatorKey: _con!.navigatorKeys[tabItem] as GlobalKey<NavigatorState>?,
        tabItem: tabItem,
      ),
    );
  }

}