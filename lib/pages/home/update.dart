
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/pages/history/history_detail_page.dart';
import 'dart:io';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../models/pouring.dart';
import '../../controllers/history_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/history/water-ani-4.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drinkwaterpro/pages/home/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

//final List<Pouring> Pourings = <Pouring>[Pouring("Мира 113", 5, 15, '21 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022'), Pouring("Ленина 66", 19, 53, '22 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022'), Pouring("Мира 113", 5, 15, '21 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022'), Pouring("Ленина 66", 19, 53, '22 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022') ];


class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

// не забываем расширяться от StateMVC
class _UpdatePageState extends StateMVC {

  // после инициализации состояние
  // мы запрашивает данные у сервера
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white70,
        centerTitle: true,
        title:  Text('Обновление', style: kStyleTextPageTitle,),
      ),
      body: _buildContent(),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildContent() {

    return Column(

      children: [
        Spacer(),
        Waterani4(width: 200, height: 200,),
        Center(
          child: Text(
              globals.updateMessage,
              textAlign: TextAlign.center,
              style: kStyleLabelForm
          ),
        ),
        Spacer(),
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

            if (Platform.isAndroid || Platform.isIOS) {
              final url = Uri.parse(
                Platform.isAndroid
                    ? "https://play.google.com/store/apps/details?id=pro.enaza.drinkwater"
                    : "https://apps.apple.com/ru/app/%D0%BD%D0%B0%D0%BB%D0%B5%D0%B9-%D0%B2%D0%BE%D0%B4%D1%8B/id1627990072",
              );
              launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              );
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
        Spacer(),
      ],);
  }


}



