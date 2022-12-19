
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
import 'package:drinkwaterpro/pages/map/code.dart';
import 'package:drinkwaterpro/data/repository.dart';


class NoCodePage extends StatefulWidget {
  const NoCodePage({Key? key}) : super(key: key);

  @override
  _NoCodePageState createState() => _NoCodePageState();
}


class _NoCodePageState extends StateMVC {
  final Repository repo = Repository();


  @override

  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }



  late DeviceController _controller;




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white70,
        title: Text('Где найти код?', style: kStyleTextPageTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {

    return  Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 10,),
          Text("На автомате есть \n наклейка, внизу которой \n указан код.", style: kStyle17SizeBlack600, textAlign: TextAlign.center,),
          Spacer(),

          Align(
            alignment: Alignment.center,
            child:  Image.asset('assets/img/no_code.png', scale: 0.5,),

          ),




          Spacer(),


          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                shadowColor: MaterialStateProperty.all(Colors.transparent),
                fixedSize: MaterialStateProperty.all(const Size(250, 60)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )
                )
            ),
            onPressed: () {

              Navigator.of(context).pop();


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
                  width: 250,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)) ,
                  ) ,
                  padding: const EdgeInsets.all(15),
                  constraints: const BoxConstraints(minWidth: 88.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Закрыть', textAlign: TextAlign.center, style: kStyleButtonTextNew,),

                    ],)



              ),
            ),
          ),









        ],
      ),
    );
  }

}


