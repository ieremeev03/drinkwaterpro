import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:usb_serial/usb_serial.dart';

class SettingsUsbPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsUsbPageState();
}

class _SettingsUsbPageState extends State<SettingsUsbPage>{

  var params;
  var statuses;
  var sensors;

  @override
  void initState() {

    super.initState();

  }

  @override
  void dispose() {
    print('disconnect');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Настройки', style: kStyleTextPageTitle,),

        ),
        body: Padding(
            padding: EdgeInsets.all(20),
            child:  SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Статус', style: kStyleTextDefault16),
                    SizedBox(height: 7,),
                    buildStatuses(),
                    buildSensors(),
                    SizedBox(height: 15,),

                    Text('Управление', style: kStyleTextDefault16),
                    SizedBox(height: 7,),
                    Row(children: [
                      Text("Инкассация", style: kStyleInputProfileBold,),
                      Spacer(),
                      IconButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Провести инкассацию'),
                              content: const Text('Вы уверены?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'Cancel'),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'Ok'),
                                  child: const Text('Да'),
                                ),
                              ],
                            ),),
                          icon: FaIcon(FontAwesomeIcons.coins, size: 30.0, color: Colors.blue,))
                    ],),
                    SizedBox(height: 15,),

                    Text('Параметры', style: kStyleTextDefault16),
                    SizedBox(height: 7,),
                    Center(
                      child: buildParams(),
                    ),
                    SizedBox(height: 60,),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          shadowColor: MaterialStateProperty.all(Colors.transparent),
                          fixedSize: MaterialStateProperty.all(const Size(150, 60)),
                          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              )
                          )
                      ),
                      onPressed: () async {
                        print(params);



                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          gradient: LinearGradient(colors: [
                            Color.fromRGBO(68, 191, 254, 1),
                            Color.fromRGBO(25, 159, 227, 1),
                          ]),
                        ),
                        child: Container(
                            width: 150,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(18.0)),
                            ),
                            padding: const EdgeInsets.all(15),
                            constraints: const BoxConstraints(minWidth: 88.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Сохранить',
                                  textAlign: TextAlign.center,
                                  style: kStyleButtonTextNew,
                                ),

                              ],
                            )),
                      ),
                    ),
                  ],)
            )



        )


    );
  }



  Widget buildParams() {
    var listParams = <Widget>[];
    if(params != null ) {
      params.forEach((key,value) {
        listParams.add(new Column(children: [
          Text(value['name'], style: kStyleInputProfileBold,),
          TextFormField(
            key: Key(value['value'].toString()),
            initialValue: value['value'].toString(),
            onChanged: (val) {params[key]['value'] = int.parse(val);},
          ),
          SizedBox(height: 7,)
        ],)

        );
      });
    }


    return new Column(children: listParams);
  }

  Widget buildStatuses() {
    var listStatuses = <Widget>[];
    if(statuses != null ) {
      statuses.forEach((key,value) {
        listStatuses.add(new Column(children: [
          Row(children: [
            Text(value['name'].toString()+ ': ', style: kStyleInputProfileBold,),
            Spacer(),
            Text(value['value'].toString())

          ],),
          SizedBox(height: 7,),
        ],)

        );
      });
    }


    return new Column(children: listStatuses);
  }


  Widget buildSensors() {
    var listSensors = <Widget>[];
    if(sensors != null ) {
      sensors.forEach((key,value) {
        listSensors.add(new Column(children: [
          Row(children: [
            Text(value['name'].toString()+ ': ', style: kStyleInputProfileBold,),
            Spacer(),
            Text(value['value'].toString())

          ],),
          SizedBox(height: 7,),
        ],)

        );
      });
    }


    return new Column(children: listSensors);
  }

}