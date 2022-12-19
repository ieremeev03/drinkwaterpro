
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


class PolicePage extends StatefulWidget {

  @override
  _PolicePageState createState() => _PolicePageState();
}

// не забываем расширять StateMVC
class _PolicePageState extends StateMVC {
  String data = "";


  @override
  void initState() {
    super.initState();
    getFileData('assets/police.txt').then((value) {
      setState(() {
        data = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.white70,
          centerTitle: true,
          //elevation: 5,
          // bottomOpacity: 0.3,
          title: Text("Политика конфиденциальности", style: kStyleTextPageTitle),

        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Text(data),
          ),
        ),
      );

  }


  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }



}