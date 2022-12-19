import 'package:drinkwaterpro/pages/auth/mobile.dart';
import 'package:drinkwaterpro/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:drinkwaterpro/models/tab.dart';

import 'package:drinkwaterpro/controllers/home_controller.dart';

import 'bottom_navigation.dart';
import 'tab_navigator.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/models/user.dart';
import 'package:drinkwaterpro/data/repository.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';




class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends StateMVC {
  // ссылка на наш контроллер
  late HomeController _con;
  final Repository repo = new Repository();
  //StreamSubscription<FGBGType> subscription;
  final streamController = StreamController(
    onPause: () => print('Paused'),
    onResume: () => print('Resumed'),
    onCancel: () => print('Cancelled'),
    onListen: () => print('Listens'),
  );



  _HomePageState() : super(HomeController()) {
    _con = controller as HomeController;


  }




  @override
  void initState() {
    super.initState();
    _con.init();
    //repo.add_log('init home');
    WidgetsBinding.instance.addPostFrameCallback((_){
      //repo.add_log('addPostFrameCallback');
      _asyncMethod();
    });



  }

  _asyncMethod() async {
    FirebaseMessaging.instance.getToken().then((value) {
      repo.add_log("Message token is:", data: value.toString());
      print("Message token is: $value");
      globals.fmcToken = value.toString();
      repo.getSettings();
    }, onError: (err) {
      repo.add_log("getToken onError is: ");
      print("getToken onError is: $err");
    }).catchError((onError) {
      repo.add_log("getToken catchError is: " );
      print("getToken catchError is: $onError");
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(

      // здесь реализована следующая логика:
      // когда мы находимся на первом пункте меню (посты)
      // и нажимаем кнопку Back, то сразу выходим из приложения
      // в противном случае выбранный элемент меню переключается
      // на предыдущий
      onWillPop: () async {


        await FirebaseAnalytics.instance.setUserId(id: globals.userPhone.toString());
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