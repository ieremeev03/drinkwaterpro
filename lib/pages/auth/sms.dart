
import 'package:drinkwaterpro/pages/history/history_list_page.dart';
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/controllers/login_controller.dart';
import 'package:drinkwaterpro/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/pages/home/home_page.dart';
import 'package:drinkwaterpro/pages/payment/add_pay.dart';
import 'package:drinkwaterpro/pages/map/map.dart';
import 'package:drinkwaterpro/data/database.dart';


class SmsPage extends StatefulWidget {

  @override
  _SmsPageState createState() => _SmsPageState();
}


class _SmsPageState extends StateMVC {
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

  LoginController? _controller;

  _SmsPageState() : super(LoginController()) {
    _controller = controller as LoginController;
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
        title: Text('Авторизация', style: kStyleTextPageTitle),
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
            _controller!.sendCode(globals.userPhone, pin, (status) {
              if (status is SendCodeSuccess) {

                if(status.token['paymmentMethod'] > 0) {
                  print('USERS: Методы есть');

                  Future.delayed(const Duration(milliseconds: 1000), () {

                    setState(() {
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),(Route<dynamic> route) => false,);
                    });

                  });

                } else {
                  print('USERS: Методы отсутствуют');
                  Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(
                      builder: (context) => AddPayPage(),
                    ),(Route<dynamic> route) => false,);

                }

                /*

*/

              } else {
                // в противном случае сообщаем об ошибке
                // SnackBar - всплывающее сообщение
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Неверный смс код"))
                );
              }
            });
          },
          ),




          SizedBox(height: 30,),
          Center(
            child: RichText(
                text: TextSpan(
                  text: "Не пришёл код?",
                  style: kStyleTextDefault15,
                  children: <TextSpan>[
                    TextSpan(text: " Отправить заново ", style: kStyleInputTextSecond),
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
                  width: 270,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)) ,
                  ) ,
                  padding: const EdgeInsets.all(15),
                  constraints: const BoxConstraints(minWidth: 88.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Получить код по звонку', textAlign: TextAlign.center, style: kStyleButtonTextNew,),
                      SizedBox(width: 7,),
                      FaIcon(FontAwesomeIcons.phone,size: 17.0, color: Colors.white,),

                    ],)



              ),
            ),
          ),





        ],
      ),
    );
  }

}
