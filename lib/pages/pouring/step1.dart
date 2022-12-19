import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';

import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'package:drinkwaterpro/pages/pouring/ppm.dart';
import 'package:drinkwaterpro/pages/pouring/ozon.dart';

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


import 'dart:convert';

import 'dart:ui';

class PouringStep1Page extends StatefulWidget {
  @override
  _PouringStep1PageState createState() => _PouringStep1PageState();
}

class _PouringStep1PageState extends StateMVC with TickerProviderStateMixin {

  // ссылка на наш контроллер
  late PouringController _controller;
  PaymentController? _controllerPay;
  Timer? timer;

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _PouringStep1PageState() : super(PouringController()) {
    _controller = controller as PouringController;
  }



  @override
  void initState() {
    super.initState();
    _controller.init();
    _controllerPay = PaymentController();

    timer = RestartableTimer(
      const Duration(seconds: 60),
          () {
        _controller.lockDevice(globals.currentDeviceId);
        Navigator.pop(context);
      },
    );

  }


  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              _controller.lockDevice(globals.currentDeviceId);
              Navigator.pop(context);
            }),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),

          SvgPicture.asset(
            'assets/img/pouring_st1.svg',
            width: 220,
          ),
          SizedBox(
            height: 60,
          ),
          Text("Установите бутылку для воды", style: kStyle17SizeBlue600),
          SizedBox(
            height: 20,
          ),
          Center(
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Температура воды ",
                  style: kStyleTextDefault15,
                  children: <TextSpan>[
                    TextSpan(
                        text: globals.currentDeviceTemp.toString() + '°С',
                        style: kStyleInputTextSecond600),
                  ],
                )),
          ),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text("Чистота (PPM) ", style: kStyleTextDefault15,),
              Text(globals.currentDevicePpm.toString() + ' мг/л', style: kStyleInputTextSecond600Green,),
                SizedBox(width: 5,),
            ],),


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
                    builder: (context) => PouringOzonPage(),
                  ),(_) => false);
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
                        'Готово',
                        textAlign: TextAlign.center,
                        style: kStyleButtonTextNew,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      FaIcon(
                        FontAwesomeIcons.angleRight,
                        size: 15.0,
                        color: Colors.white,
                      ),
                    ],
                  )),
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Center(
            child: Text(
              '*   Деньги списываются только после окончания налива воды',
              textAlign: TextAlign.center,
              style: kStyleTextDefault15,
            ),
          ),
          SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}
