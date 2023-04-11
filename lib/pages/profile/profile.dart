import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../models/user.dart';
import '../../controllers/profile_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/auth/mobile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:drinkwaterpro/pages/home/home_page.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drinkwaterpro/pages/payment/edit_method.dart';
import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'package:drinkwaterpro/pages/splash.dart';
import 'package:drinkwaterpro/pages/profile/about.dart';



class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

// не забываем расширяться от StateMVC
class _ProfilePageState extends StateMVC {

  // ссылка на наш контроллер
  late ProfileController _controller;

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _ProfilePageState() : super(ProfileController()) {
    _controller = controller as ProfileController;
  }

  PaymentController? _controllerPay;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();





  // после инициализации состояние
  // мы запрашивает данные у сервера
  @override
  void initState() {
    print("Отображать сервисное окно: "+globals.service.toString());
    _controllerPay?.init();
    super.initState();
    _controller.init();

  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление учетной записи'),
          content: const Text('Вы действительно хотите выйти и удалить свою учетную запись? \n\n'
              'Внимание! История ваших покупок также будет удалена'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Удалить', style: kStyleTextDefaultRed ),
              onPressed: () {
                globals.isLoggedIn = false;

                _controller.remove();
                _controller.logout();

                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );

              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Профиль', style: kStyleTextPageTitle,),
        actions: [
          PopupMenuButton(
            // add icon, by default "3 dot" icon
             icon: Icon(Icons.more_horiz),
              position: PopupMenuPosition.under,
              itemBuilder: (context){
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("О приложении", style: kStyleTextDefault,),
                  ),

                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Выйти", style: kStyleTextDefault,),
                  ),

                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Удалить учетную запись", style: kStyleTextDefaultRed,),
                  ),
                ];
              },
              onSelected:(value){
                if(value == 0){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutPage(),
                      ));

                }else if(value == 1){
                  globals.isLoggedIn = false;
                  _controller.logout();

                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
                else if(value == 2){
                  _dialogBuilder(context);
                }
              }
          ),


        ],
      ),
      body: _buildContent(),


    );
  }

  Widget _buildContent() {
    // первым делом получаем текущее состояние
    final state = _controller.currentState;
    if (state is ProfileResultLoading) {
      // загрузка
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is ProfileResultFailure) {
      // ошибка
      return Center(
        child: Text(
            state.error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.red)
        ),
      );
    } else {
      // отображаем список наливов
      final user = (state as ProfileResultSuccess).userInfo;

      phoneController.text = formatAsPhoneNumber(
        user.phone.toString(),
        allowEndlessPhone: false,
      ) ??
          '';
      nameController.text = user.firstName.toString();
      emailController.text = user.email.toString();
      cityController.text = user.city.toString();

      return SingleChildScrollView(
        child:  Container(
            padding: const EdgeInsets.fromLTRB(20,40,20,20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextFormField(
                  controller: nameController,
                  decoration: kStyleFormNoBorderName,
                  style: kStyleTextDefault15,
                ),
                SizedBox(height: 5,),
                Divider(),
                SizedBox(height: 10,),
                TextFormField(
                  controller: cityController,
                  decoration: kStyleFormNoBorderCity,
                  style: kStyleTextDefault15,

                ),
                SizedBox(height: 5,),
                Divider(),
                SizedBox(height: 10,),
                TextFormField(
                  controller: emailController,
                  decoration: kStyleFormNoBorderEmail,
                  style: kStyleTextDefault15,

                ),
                SizedBox(height: 5,),
                Divider(),
                SizedBox(height: 10,),
                TextFormField(
                  enabled: false,
                  controller: phoneController,
                  decoration: kStyleFormNoBorderPhone,
                  style: kStyleTextDefault15,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    PhoneInputFormatter()
                  ],
                ),
                SizedBox(height: 5,),
                Divider(),
                SizedBox(height: 10,),
                Text('Мeтод оплаты',  style:  TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                )),
                SizedBox(height: 5,),
                paymentMethod(),
                SizedBox(height: 15,),
                Center(
                  child:
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                        fixedSize: MaterialStateProperty.all(const Size(200, 60)),
                        padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            )
                        )
                    ),
                    onPressed: () {

                      //Navigator.of(context).pushNamed('/map');

                      print(cityController.text);

                      _controller.editProfile(
                          user.id!,
                          nameController.text,
                          cityController.text,
                          emailController.text,
                              (status) {
                            if (status is EditProfileSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Профиль обновлен"))
                              );

                            } else {
                              // в противном случае сообщаем об ошибке
                              // SnackBar - всплывающее сообщение
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Ошибка обновления профиля"))
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
                              const Text('Обновить', textAlign: TextAlign.center, style: kStyleButtonTextNew,),
                              SizedBox(width: 7,),
                              FaIcon(FontAwesomeIcons.rotate,size: 15.0, color: Colors.white,),

                            ],)



                      ),
                    ),
                  ),
                ),

                Center(child:
                Column(children: [

                  TextButton(
                      onPressed: () {
                        final Uri _emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'support@drinkwater.pro',
                          queryParameters: {'subject': "Вопрос по приложению", 'body': ""},
                        );

                        final String _emailUriString = _emailLaunchUri
                            .toString()
                            .replaceAll('+', '\%20');

                        launch(_emailUriString.toString());
                      },
                      child: Text('support@drinkwater.pro')
                  ),
                ],),),








              ],
            )
        ),
      );

    }
  }

  Widget paymentMethod() {

    if(globals.currentPaymentMethod.toString() == '') {
      return  Row(children: [
        Text('Бонусный счет', style: kStyleTextDefault15,),
        Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPaymentMethodPage(),
                ));

            setState(() {
             print('метод '+ globals.currentPaymentMethod.toString());
            });
          },
          child:  Padding(
            padding: EdgeInsets.only(left:15, right: 15),
            child:  Icon(Icons.edit, size: 15, color: Colors.grey,),
        ),)

      ],);
    } else {
      return  Row(children: [
        Text('Банковская карта', style: kStyleTextDefault15,),
        Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPaymentMethodPage(),
                ));

            setState(() {
              print('метод '+ globals.currentPaymentMethod.toString());
            });
          },
          child:  Padding(
            padding: EdgeInsets.only(left:15, right: 15),
            child:  Icon(Icons.edit, size: 15, color: Colors.grey,),
          ),)

      ],);
    }


  }

}



