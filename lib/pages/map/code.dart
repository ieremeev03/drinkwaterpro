
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
import 'package:drinkwaterpro/pages/payment/method.dart';
import 'package:drinkwaterpro/pages/map/no_code.dart';
import 'package:drinkwaterpro/data/repository.dart';


class CodePage extends StatefulWidget {
  const CodePage({Key? key}) : super(key: key);

  @override
  _CodePageState createState() => _CodePageState();
}


class _CodePageState extends StateMVC {
  final Repository repo = Repository();
  String _code="";
  String signature = "{{ app signature }}";
  final DatabaseHandler handler = DatabaseHandler();
  final focusNode = FocusNode();
  final pinController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void sendCode(String code) {
    repo.add_log("DEVICE: Введен код вручную", data: code);
    _controller.getDevice(code,  (status) {
      if (status is DeviceInfoSuccess) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentMethodPage()));
      } else {
        // в противном случае сообщаем об ошибке
        // SnackBar - всплывающее сообщение
        formKey.currentState!.validate();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Неверный код"))
        );
      }
    });
  }

  late DeviceController _controller;

  _CodePageState() : super(DeviceController()) {
    _controller = controller as DeviceController;
  }



  final TextEditingController smsController = TextEditingController();
  String _sms_code = '';

  // _formState пригодится нам для валидации
  //final _codeKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white70,
        title: Text('Ввести код вручную', style: kStyleTextPageTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {

    return  Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 10,),
          Text("На автомате есть \n наклейка, внизу которой \n указан код.", style: kStyle17SizeBlack600, textAlign: TextAlign.center,),
          Spacer(),
          Form(
            key: formKey,
            child: Pinput(
              autofocus: true,
            controller: pinController,
           // focusNode: focusNode,
            length: 4,
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
            errorPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: kStyleInputTextRed,
              decoration: BoxDecoration(
                color: Color.fromRGBO(254, 92, 103, 0.1),
                border: Border.all(color: Color.fromRGBO(246, 92, 103, 1)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onCompleted: (pin) {
              _code = pin;

              print(_code);
              sendCode(_code);


            },
          ),),





          Spacer(),
          TextButton(
              onPressed: () {

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoCodePage(),
                    ));

              },
              child: Text("Не могу найти код", style: TextStyle(color: kTextBlueColor, fontWeight: FontWeight.w500),)),









        ],
      ),
    );
  }

}


