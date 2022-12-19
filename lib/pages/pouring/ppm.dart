import 'dart:io';

import 'package:drinkwaterpro/controllers/payment_controller.dart';
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
import 'package:percent_indicator/percent_indicator.dart';

import 'dart:convert';

import 'dart:ui';

class PouringPPMPage extends StatefulWidget {
  @override
  _PouringPPMPageState createState() => _PouringPPMPageState();
}

class _PouringPPMPageState extends StateMVC with TickerProviderStateMixin {




  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _PouringPPMPageState() : super(PouringController()) {

  }


  @override
  void initState() {
    super.initState();

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
          'Что такое PPM?',
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
          Text("PPM показывает количество различных частиц в воде, \n мг/литр", style: kStyle17SizeBlue600, textAlign: TextAlign.center,),
          SizedBox(height: 45,),
          Row(children: [
            Text("0 - 50", style: TextStyle(color: Color.fromRGBO(91, 219, 33, 1)),),
            Spacer(),
            Text("идеальная питьевая вода", style: kStyleTextDefault, ),
          ],),
          SizedBox(height: 10,),

          LinearPercentIndicator(
            barRadius: Radius.circular(3),
            padding: EdgeInsets.zero,
            animation: true,
            lineHeight: 7.0,
            animationDuration: 500,
            percent: .25,
            backgroundColor: Color.fromRGBO(191, 229, 250, 1),
            //linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Color.fromRGBO(90, 216, 31, 1),


          ),


          SizedBox(
            height: 60,
          ),

          Row(children: [
            Text("50 - 100", style: TextStyle(color: Color.fromRGBO(238, 223, 88, 1)),),
            Spacer(),
            Text("питьевая вода из бутылки", style: kStyleTextDefault, ),
          ],),
          SizedBox(height: 10,),

          LinearPercentIndicator(
            barRadius: Radius.circular(3),
            padding: EdgeInsets.zero,
            animation: true,
            lineHeight: 7.0,
            animationDuration: 500,
            percent: .35,
            backgroundColor: Color.fromRGBO(191, 229, 250, 1),
            //linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Color.fromRGBO(238, 223, 88, 1),


          ),


          SizedBox(
            height: 40,
          ),

          Row(children: [
            Text("100 - 300", style: TextStyle(color: Color.fromRGBO(255, 207, 86, 1)),),
            Spacer(),
            Text("питьевая вода из под крана", style: kStyleTextDefault, ),
          ],),
          SizedBox(height: 10,),

          LinearPercentIndicator(
            barRadius: Radius.circular(3),
            padding: EdgeInsets.zero,
            animation: true,
            lineHeight: 7.0,
            animationDuration: 500,
            percent: .85,
            backgroundColor: Color.fromRGBO(191, 229, 250, 1),
            //linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Color.fromRGBO(255, 207, 86, 1),


          ),


          SizedBox(
            height: 40,
          ),

          Row(children: [
            Text("300 и более", style: TextStyle(color: Color.fromRGBO(254, 92, 103, 1)),),
            Spacer(),
            Text("техническая вода", style: kStyleTextDefault, ),
          ],),
          SizedBox(height: 10,),

          LinearPercentIndicator(
            barRadius: Radius.circular(3),
            padding: EdgeInsets.zero,
            animation: true,
            lineHeight: 7.0,
            animationDuration: 500,
            percent: 1,
            backgroundColor: Color.fromRGBO(191, 229, 250, 1),
            //linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Color.fromRGBO(254, 92, 103, 1),


          ),
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

              Navigator.pop(context);
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
                        'Понятно',
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

        ],
      ),
    );
  }
}
