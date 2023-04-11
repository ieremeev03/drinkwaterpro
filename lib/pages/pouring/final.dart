import 'dart:io';

import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'package:drinkwaterpro/pages/map/map.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/payment.dart';
import '../../models/pouring.dart';
import '../../controllers/pouring_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:http_client/console.dart';
import 'package:drinkwaterpro/pages/payment/method.dart';
import 'package:drinkwaterpro/pages/history/history_list_page.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drinkwaterpro/pages/pouring/water-ani-3.dart';


import 'dart:convert';

import 'dart:ui';

class PouringFinalPage extends StatefulWidget {
  @override
  _PouringFinalPageState createState() => _PouringFinalPageState();
}

class _PouringFinalPageState extends StateMVC with TickerProviderStateMixin {


  // ссылка на наш контроллер
  late PouringController _controller;
  PaymentController? _controllerPay;

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _PouringFinalPageState() : super(PouringController()) {
    _controller = controller as PouringController;
  }



  @override
  void initState() {
    super.initState();

    _controllerPay = PaymentController();

  }

  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Налить воду',
          style: kStyleTextPageTitle,
        ),
      ),
      body: _buildContent(),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildContent() {
    final state = _controller.lastPouring;

    return Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Text("Вкусная питьевая вода теперь в вашей бутылке", style: kStyle17SizeBlue600,  textAlign: TextAlign.center, ),
            Waterani3(width: 200, height: 200,),
            Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  fixedSize: MaterialStateProperty.all(const Size(150, 60)),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )
                  )
              ),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  gradient: LinearGradient(colors: [
                    Color.fromRGBO(68, 191, 254, 1),
                    Color.fromRGBO(25, 159, 227, 1),
                  ]),
                ),
                child: Container(
                    width: 150,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    padding: const EdgeInsets.all(15),
                    constraints: const BoxConstraints(minWidth: 88.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Спасибо',
                          textAlign: TextAlign.center,
                          style: kStyleButtonTextNew,
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      );

  }

  String num2liters(num) {
    num = num%100;
    if(num>19) {num=num%10;}
    switch (num) {
      case 1: return "литр";
      case 2: case 3: case 4: return "литра";
      default: return "литров";
    }
  }

  String num2rub(num) {
    num = num%100;
    if(num>19) {num=num%10;}
    switch (num) {
      case 1: return "рубль";
      case 2: case 3: case 4: return "рубля";
      default: return "рублей";
    }
  }

}
