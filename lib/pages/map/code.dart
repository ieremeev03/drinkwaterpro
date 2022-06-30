
import 'package:drinkwaterpro/pages/history/history_list_page.dart';
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/controllers/device_controller.dart';
import 'package:drinkwaterpro/models/user.dart';
import 'package:drinkwaterpro/models/device.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/pages/home/home_page.dart';
import 'package:drinkwaterpro/pages/payment/add_pay.dart';
import 'package:drinkwaterpro/pages/map/map.dart';
import 'package:drinkwaterpro/data/database.dart';
import 'package:drinkwaterpro/pages/payment/method.dart';


class CodePage extends StatefulWidget {

  @override
  _CodePageState createState() => _CodePageState();
}


class _CodePageState extends StateMVC {
  String _code="";
  String signature = "{{ app signature }}";
  final DatabaseHandler handler = DatabaseHandler();

  @override

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void sendCode(String code) {
    _controller.getDevice(code,  (status) {
      if (status is DeviceInfoSuccess) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentMethodPage()));
      } else {
        // в противном случае сообщаем об ошибке
        // SnackBar - всплывающее сообщение
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ошибка получения данных аппарата"))
        );
      }
    });
  }

  late DeviceController _controller;

  _CodePageState() : super(DeviceController()) {
    _controller = controller as DeviceController;
  }



  final TextEditingController smsController = TextEditingController();
  String _sms_code = '';

  // _formState пригодится нам для валидации
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white70,
        title: Text('Ввести код вручную', style: kStyleTextPageTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {

    return  Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Pinput(
            defaultPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: kStyleInputText,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment (0,1),
                    colors: [
                      Color.fromRGBO(237, 249, 255, 1),
                      Color.fromRGBO(223, 244, 255, 1) ]
                ),
                border: Border.all(color: Color.fromRGBO(215, 241, 255, 1)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            submittedPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: kStyleInputText,
              decoration: BoxDecoration(
                color: Color.fromRGBO(215, 241, 255, 1),
                border: Border.all(color: Color.fromRGBO(215, 241, 255, 1)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onCompleted: (pin) {
              _code = pin;
            },
          ),




          SizedBox(height: 30,),
          Center(
            child: RichText(
                text: TextSpan(
                  text: "Не находишь код?",
                  style: kStyleTextDefault15,
                  children: <TextSpan>[
                    TextSpan(text: " Жми сюда ", style: kStyleInputTextSecond),
                  ],
                )
            ),
          ),
          SizedBox(height: 60,),



          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              primary: Colors.transparent,
              padding: const EdgeInsets.all(0.0),
              elevation: 5,
            ),
            onPressed: () {
                print(_code);

                sendCode(_code);
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
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)) ,
                  ) ,
                  padding: const EdgeInsets.all(15),
                  constraints: const BoxConstraints(minWidth: 88.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Продолжить', textAlign: TextAlign.center, style: kStyleButtonTextNew,),
                      SizedBox(width: 7,),
                      FaIcon(FontAwesomeIcons.angleRight,size: 17.0, color: Colors.white,),

                    ],)



              ),
            ),
          ),





        ],
      ),
    );
  }

}


