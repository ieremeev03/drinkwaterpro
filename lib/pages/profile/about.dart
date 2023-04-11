
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
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutPage extends StatefulWidget {

  @override
  _AboutPageState createState() => _AboutPageState();
}

// не забываем расширять StateMVC
class _AboutPageState extends StateMVC {
  String data = "";
  Future<void>? _launched;

  @override
  void initState() {
    super.initState();

  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white70,
        centerTitle: true,
        //elevation: 5,
        // bottomOpacity: 0.3,
        title: Text("О приложении", style: kStyleTextPageTitle),

      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Center(child:
          Column(children: [
            Text(
              'Реквизиты',
              style: kStyleLabelForm,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 15,),
            Text("АО “НАЛЕЙ ВОДЫ”"),
            Text("ИНН: 7447310012"),
            Text("ОГРН: 1227400048842"),
            Text("г. Челябинск, ул. Молодогвардейцев, Д.60-В"),
            TextButton(
                onPressed: () {
                  final Uri toLaunch =
                  Uri(scheme: 'https', host: 'drinkwater.pro', path: 'privacy_policy');

                  _launched = _launchInBrowser(toLaunch);
                },
                child:
            Text("Политика конфиденциальности" , style: kStyleInputTextSecond,))


          ],),)
        ),
      ),
    );

  }


  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }



}