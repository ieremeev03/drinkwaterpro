


import 'package:drinkwaterpro/pages/map/map.dart';
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'package:drinkwaterpro/models/payment.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/home/home_page.dart';
import 'package:drinkwaterpro/pages/history/history_list_page.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:drinkwaterpro/pages/auth/sms.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
//import 'package:flutter_yookassa_sdk/flutter_yookassa_sdk.dart';



class AddPayPage extends StatefulWidget {

  @override
  _AddPayPageState createState() => _AddPayPageState();
}

// не забываем расширять StateMVC
class _AddPayPageState extends StateMVC {

  // _controller может быть null
  PaymentController? _controller;

  // получаем PostController
  _AddPayPageState() : super(PaymentController()) {
    _controller = controller as PaymentController;
  }

  // TextEditingController'ы позволят нам получить текст из полей формы
  final TextEditingController phoneController = TextEditingController();
  String _phonecompleteNumber = '';

  // _formState пригодится нам для валидации
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Налить воду", style: kStyleTextPageTitle,)
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(15),
          child: _buildContent(),
        ),
      );
  }

  Widget _buildContent() {
    return  Padding(
      padding: const EdgeInsets.fromLTRB(60, 60, 60, 60),
      child: Column(

        children: [
          Image.asset('assets/img/add_pay.png'),
          Spacer(),
          Center(child: Text('Чтобы налить воду, вам нужно привязать карту оплаты', textAlign: TextAlign.center,  style: kStyleTextDefault)),
          SizedBox(height: 30,),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Сразу платить не надо, мы",
                  style: kStyleTextDefault15,
                  children: <TextSpan>[
                    TextSpan(text: " подарим вам 100 рублей ", style: kStyleInputTextSecond),
                    TextSpan(text: " и вы сможете налить воду бесплатно "),

                  ],
                )
            ),
          ),

          Spacer(),

          Directionality(
            textDirection: TextDirection.rtl,
            child: ElevatedButton.icon(
              icon: FaIcon(FontAwesomeIcons.angleRight,size: 15.0, color: Colors.white,),
              style: flatButtonStyle,
              onPressed: () {

                _controller!.addPaymentMethod( (status) {
                  if (status is CheckoutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Платеж создан"))
                    );


                    setState(() {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ), (Route<dynamic> route) => false,);
                    });

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Ошибка добавления метода оплаты"))
                    );
                  }
                });
              },
              label:  Text('Привязать карту'),
            ),
          ),

          Spacer(),
          TextButton(
              onPressed: () {
                        setState(() {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ), (Route<dynamic> route) => false,);
                        });
              },
              child: Text('Нет, не сейчас')
          )
        ],
      ),

    );
  }




}