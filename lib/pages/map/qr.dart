import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:drinkwaterpro/pages/profile/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/controllers/device_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/payment/method.dart';
import 'package:drinkwaterpro/models/device.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drinkwaterpro/pages/map/code.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:permission_handler/permission_handler.dart';
import 'package:drinkwaterpro/data/repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class QrPage extends StatefulWidget {
  @override
  _QrPageState createState() => _QrPageState();
}

// не забываем расширяться от StateMVC
class _QrPageState extends StateMVC {
  final Repository repo = Repository();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  String code = '0000';
  QRViewController? controllerQR;
  final TextEditingController codeController = TextEditingController();
  late DeviceController _controller;

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _QrPageState() : super(DeviceController()) {
    _controller = controller as DeviceController;
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controllerQR!.pauseCamera();
    } else if (Platform.isIOS) {
      controllerQR!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.init(context);
    requestPermission();
    repo.add_log('DEVICE: Сканирование QR кода');

  }

  Future<void> requestPermission() async {
    final status = await Permission.camera.request();

    setState(() {
      print(status);
    });
  }

  void _onQRViewCreated(QRViewController controllerQR) {
    this.controllerQR = controllerQR;
    controllerQR.scannedDataStream.listen((scanData)  async {

     String deviceId = "";

      setState(()  {
        result = scanData;
        print(scanData);
        if (result != null)  {
          code = result!.code!;
          final splitted = code.split('=');
          print(splitted[1]);
          controllerQR.dispose();
          repo.add_log('DEVICE: Результат сканирования: ' + splitted[1]);
          sendCode(splitted[1]);
          deviceId = splitted[1];
        }
      });

      await FirebaseAnalytics.instance.logEvent(
        name: "scan_qr",
        parameters: {
          "device_id": deviceId,
        },
      );

    });
  }

  void sendCode(String code) {
    print(code);
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

  @override
  void dispose() {
    controllerQR?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Сканировать QR', style: kStyleTextPageTitle,),
      ),
      body: _buildContent(),


    );
  }

  Widget _buildContent() {




      return Stack(

        children: [
            QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 20,
                borderWidth: 4
              ),
              onQRViewCreated: _onQRViewCreated,
            ),
          Container(
            //margin: EdgeInsets.only(bottom: 400),
            padding: EdgeInsets.fromLTRB(0, 80, 0, 80),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Center(child:
                Text(
                  'Наведите камеру на' ,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                ),
                SizedBox(height: 10,),
                Center(child:
                Text(
                  'наклейку на автомате' ,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                ),
                Spacer(),
                Center(
                    child:

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

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CodePage(),
                            ));


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
                                const Text('Ввести код вручную', textAlign: TextAlign.center, style: kStyleButtonTextNew,),
                                SizedBox(width: 7,),
                                FaIcon(FontAwesomeIcons.keyboard,size: 15.0, color: Colors.white,),

                              ],)



                        ),
                      ),
                    ),


                ),
              ],
            ),
          ),


        ],
      );


        Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                overlay: QrScannerOverlayShape(),
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: (result != null)
                    ? Text(
                    'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                    : Text('Scan a code'),
              ),
            )
          ],
        ),
      );
    }
  }





