
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

import 'dart:convert';

import 'dart:ui';

class PouringPage extends StatefulWidget {
  @override
  _PouringPageState createState() => _PouringPageState();
}

final idempotenceKey = 'some_unique_idempotence_key' +
    DateTime.now().microsecondsSinceEpoch.toString();
const shopId = '670615';
const clientAppKey = 'live_y0MsUh-8xeHWgNE8xis6GultGLR4hs5D78SoQe7FqhY';
const secretKey = 'your secret key';

// не забываем расширяться от StateMVC
class _PouringPageState extends StateMVC with TickerProviderStateMixin  {

  late AnimationController _controllerAnimated;
  late AnimationController _controllerAnimated2;
  late Animation<double> _animation;
  late Animation<Size> _myAnimation;

  // ссылка на наш контроллер
  late PouringController _controller;
  PaymentController? _controllerPay;
  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _PouringPageState() : super(PouringController()) {
    _controller = controller as PouringController;
  }


  int liters = 19;
  int price = globals.currentDevicePrice;
  int summ =0;

  final Tween<double> turnsTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _controller.init();
    _controllerPay = PaymentController();



    _controllerAnimated=AnimationController(vsync:this,duration: Duration(seconds: 2));
    _controllerAnimated2=AnimationController(vsync:this,duration: Duration(seconds: 3));
    _animation=CurvedAnimation(parent: _controllerAnimated2, curve: Curves.bounceOut,);
    _myAnimation = Tween<Size>(
        begin: Size(50, 50),
        end:  Size(200, 200)
    ).animate(
        CurvedAnimation(parent: _controllerAnimated, curve: Curves.bounceIn)
    );

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
        title: Text('Налить воду', style: kStyleTextPageTitle,),

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
          Spacer(),
          Image.asset(
                             'assets/img/logo.png',
                            // width: _myAnimation.value.width,
                             //height: _myAnimation.value.height,
                           ),




          // RotationTransition(
          //   turns: _animation,
          //   child:  Image.asset('assets/img/logo.png'),
          // ),



          SizedBox(height: 60,),
          Spacer(),



            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                primary: Colors.transparent,
                padding: const EdgeInsets.all(0.0),
                elevation: 5,
              ),
              onPressed: () async {
                _controller.getLastPouring(
                        (status) {
                      if (status is LastPouringSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Налив получен"))
                        );

                        _controllerPay!.pay(globals.currentPaymentMethod, globals.summ, globals.liters, (statusPay) {
                          if (statusPay is PaySuccess) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(),
                              ),
                                  (Route<dynamic> route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Ошибка оплаты"))
                            );
                          }
                        });

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Ошибка получения налива"))
                        );
                      }
                    });
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18.0)) ,
                  gradient: LinearGradient(colors: [
                    Color.fromRGBO(68, 191, 254, 1),
                    Color.fromRGBO(25, 159, 227, 1),
                  ]),
                ),
                child: Container(
                    width: 150,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)) ,
                    ) ,
                    padding: const EdgeInsets.all(15),
                    constraints: const BoxConstraints(minWidth: 88.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Я все', textAlign: TextAlign.center, style: kStyleButtonTextNew,),
                        SizedBox(width: 7,),
                        FaIcon(FontAwesomeIcons.clockRotateLeft,size: 15.0, color: Colors.white,),

                      ],)



                ),
              ),
            ),



          Spacer(),
          Center(

            child: Text(
              '*   Деньги списываются только после окончания налива воды',
              textAlign: TextAlign.center,
              style: kStyleTextDefault15,),
          ),
          Spacer(),
        ],
      ),
    );
  }

}





