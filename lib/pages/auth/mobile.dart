
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/controllers/login_controller.dart';
import 'package:drinkwaterpro/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/history/history_list_page.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:drinkwaterpro/pages/auth/sms.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

// не забываем расширять StateMVC
class _LoginPageState extends StateMVC {

  // _controller может быть null
  LoginController? _controller;

  // получаем PostController
  _LoginPageState() : super(LoginController()) {
    _controller = controller as LoginController;
  }

  // TextEditingController'ы позволят нам получить текст из полей формы
  final TextEditingController phoneController = TextEditingController();
  String _phonecompleteNumber = '';

  // _formState пригодится нам для валидации
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (globals.isLoggedIn==true) {
      return HistoryListPage();
    } else {
      return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.white70,
          centerTitle: true,
          //elevation: 5,
         // bottomOpacity: 0.3,
          title: Text("Авторизация", style: kStyleTextPageTitle),

        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: _buildContent(),
        ),
      );
    }
  }

  Widget _buildContent() {
   return  Padding(
     padding: const EdgeInsets.fromLTRB(15, 35, 15, 60),
     child: Column(
       children: [
         Form(
           key: _formKey,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text(
                 'Ваш номер телефона',
                 style: kStyleLabelForm,
                 textAlign: TextAlign.left,
               ),
               SizedBox(height: 20),

               Container(
                 padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                 decoration: BoxDecoration(
                    border: Border.all(
                        color: Color.fromRGBO(215, 241, 255, 1), width: 1.0
                    ),


                     borderRadius:  const BorderRadius.all(const Radius.circular(15.0)),
                     gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment (0,1),
                         colors: [
                           Color.fromRGBO(237, 249, 255, 1),
                           Color.fromRGBO(223, 244, 255, 1) ]
                     )

                 ),

                 child:  IntlPhoneField(
                   inputFormatters: [
                     MaskedInputFormatter('(000)-000-00-00')
                   ],
                   //dropdownIconPosition: IconPosition.trailing,
                   dropdownIcon: Icon(FontAwesomeIcons.angleDown,size: 15.0, color: Color.fromRGBO(36, 60, 70, 1)),
                   disableLengthCheck: true,
                   dropdownTextStyle: kStyleInputText,
                   decoration: InputDecoration(
                     labelText: '',
                     border: OutlineInputBorder(
                       borderSide: BorderSide.none,
                     ),
                   ),

                   style: kStyleInputText,
                   controller: phoneController,
                   invalidNumberMessage: 'Введите правильный номер телефона',
                   initialCountryCode: 'RU',
                   onChanged: (phone) {
                     _phonecompleteNumber = phone.completeNumber;
                     print(phone.completeNumber);
                   },
                 )
                 ,),


             ],
           ),
         ),
         Spacer(),

         ElevatedButton(
           style: ElevatedButton.styleFrom(
             shadowColor: Colors.transparent,
             primary: Colors.transparent,
             padding: const EdgeInsets.all(0.0),
             elevation: 5,
           ),
           onPressed: () {
             // сначала запускаем валидацию формы
             if (_formKey.currentState!.validate()) {
               // запрос на существование пользователя
               // получаем текст через TextEditingController
               final phone = _phonecompleteNumber;
               print('Форма: '+ _phonecompleteNumber);

               _controller!.sendSMS(phone, (status) {
                 if (status is SignInSuccess) {
                   Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => SmsPage(),
                       ));

                 } else {
                   // в противном случае сообщаем об ошибке
                   // SnackBar - всплывающее сообщение
                   ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Пользователь не найден"))
                   );
                 }
               });
             }
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
               width: 180,
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



         SizedBox(height: 40,),


         Center(
           child: RichText(
               textAlign: TextAlign.center,
               text: TextSpan(
                 text: "*  Нажимая «Продолжить» вы соглашаетесь c",
                 style: kStyleTextDefault15,
                 children: <TextSpan>[
                   TextSpan(text: " политикой конфиденциальности ", style: kStyleInputTextSecond),


                 ],
               )
           ),
         ),
       ],
     ),

   );
  }




}