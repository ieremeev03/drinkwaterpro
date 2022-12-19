import 'dart:io';

import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'package:drinkwaterpro/pages/pouring/pouring.dart';
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
import 'package:percent_indicator/percent_indicator.dart';

import 'dart:convert';

import 'dart:ui';
import 'dart:async';

class PouringOzonPage extends StatefulWidget {
  @override
  _PouringOzonPageState createState() => _PouringOzonPageState();
}

class _PouringOzonPageState extends StateMVC with TickerProviderStateMixin {
  late AnimationController _controllerAnimated;
  late AnimationController _controllerAnimated2;
  late Animation<double> _animation;
  late Animation<Size> _myAnimation;

  // ссылка на наш контроллер
  late PouringController _controller;
  PaymentController? _controllerPay;

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _PouringOzonPageState() : super(PouringController()) {
    _controller = controller as PouringController;
  }

  final Tween<double> turnsTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );
  int percent = 0;

  @override
  void initState() {
    _controller.startOzon(globals.currentDeviceId);
    final timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      print(percent);
      percent+=10;
      setState((){});
      if (percent == 100 ) {
        timer.cancel();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PouringPage(),
            ),(Route<dynamic> route) => false,);
      }
    });

    super.initState();

    _controllerPay = PaymentController();

    _controllerAnimated =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _controllerAnimated2 =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animation = CurvedAnimation(
      parent: _controllerAnimated2,
      curve: Curves.bounceOut,
    );
    _myAnimation = Tween<Size>(begin: Size(50, 50), end: Size(200, 200))
        .animate(CurvedAnimation(
        parent: _controllerAnimated, curve: Curves.bounceIn));

    // _myAnimation.addStatusListener((status) {
    //   //print(status);
    //   if (status == AnimationStatus.completed) {
    //     _controllerAnimated.reverse();
    //   } else if (status == AnimationStatus.dismissed) {
    //     _controllerAnimated.forward();
    //   }
    // });
    // _controllerAnimated.forward();
    // _controllerAnimated2.repeat();
  }

  @override
  void dispose() {
    _controllerAnimated.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Озонирование',
          style: kStyleTextPageTitle,
        ),
      ),
      body: _buildContent(),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 60, 50, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SvgPicture.asset(
            'assets/img/ozon.svg',
            width: 250,
          ),
          SizedBox(
            height: 60,
          ),

         Text("Обеззараживаем бутылку", style: kStyle17SizeBlue600),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Озонирование ", style: kStyleTextDefault15,),
              Text(percent.toString()+'%', style: kStyleInputTextSecond600,),



            ],),
         SizedBox(height: 20,),

         LinearPercentIndicator(
           barRadius: Radius.circular(3),
            animation: true,
            lineHeight: 7.0,
            animationDuration: 10000,
            percent: 1,
            backgroundColor: Color.fromRGBO(191, 229, 250, 1),
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Color.fromRGBO(68, 191, 254, 1),

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
}
