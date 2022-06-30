import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../models/user.dart';
import '../../controllers/profile_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/auth/mobile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:drinkwaterpro/pages/home/home_page.dart';


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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // после инициализации состояние
  // мы запрашивает данные у сервера
  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Профиль', style: kStyleTextPageTitle,),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 15, 15, 10),
            child: GestureDetector(
                onTap: () {
                  _controller.logout();
                  print('logout');

                  Future.delayed(const Duration(milliseconds: 1000), () {

                    setState(() {
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),(Route<dynamic> route) => false,);
                    });

                  });
                },
                child: FaIcon(FontAwesomeIcons.rightFromBracket,size: 20.0, color: Colors.black,)),

          )

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

      return Container(
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

            Spacer(),

            Center(
              child:

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  primary: Colors.transparent,
                  padding: const EdgeInsets.all(0.0),
                  elevation: 5,
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
            Container(
              height: 40,
            )
          ],
        )
      );
    }
  }
}



