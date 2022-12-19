
import 'package:drinkwaterpro/pages/pouring/pouring.dart';
import 'package:drinkwaterpro/pages/pouring/step1.dart';
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'package:drinkwaterpro/models/payment.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/history/history_list_page.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:drinkwaterpro/pages/auth/sms.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:drinkwaterpro/data/repository.dart';

import 'package:drinkwaterpro/pages/settings/settings.dart';
import 'package:drinkwaterpro/pages/settings/usb.dart';
import 'package:drinkwaterpro/pages/payment/edit_method.dart';

class PaymentMethodPage extends StatefulWidget {
  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

// не забываем расширять StateMVC
class _PaymentMethodPageState extends StateMVC {

  // _controller может быть null
  PaymentController? _controller;
  final Repository repo = Repository();
  // получаем PostController
  _PaymentMethodPageState() : super(PaymentController()) {
    _controller = controller as PaymentController;
  }

  @override
  void initState() {
    super.initState();
    _controller?.init();
    print('load');
  }

  // _formState пригодится нам для валидации
 // final _methodKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Мeтод оплаты", style: kStyleTextPageTitle,),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: _buildContent(),
      ),
    );
  }



  Widget _buildContent() {

    String? selectedValue2;

    // первым делом получаем текущее состояние
    final state = _controller?.currentState;

    if (state is GetPaymentMethodLoading) {
      // загрузка
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {

      String? selectedValue;
      final methods = (state as GetPaymentMethodResultSuccess).methodList.methods;
        if (methods.length > 0) {
          for (var method in methods) {
              if(method.active == 1)  selectedValue = method.uuidPayment.toString();
           }

        }


      return  Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Методы оплаты',
                  style: kStyleLabelForm,
                  textAlign: TextAlign.left,
                ),
                Spacer(),
                changeMethod(methods)!,
              ],
            ),

            SizedBox(height: 10),
            DropdownButtonFormField2(
              iconSize: 0,
              iconEnabledColor: Colors.transparent,
              iconDisabledColor: Colors.transparent,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,

              ),
              dropdownDecoration: BoxDecoration(
                borderRadius:  const BorderRadius.all(const Radius.circular(15.0)),
              ),
              isExpanded: true,
              hint: const Text(
                'Добавьте метод оплаты',
                style: TextStyle(fontSize: 14),
              ),
              icon: null,
              buttonHeight: 60,
              //buttonWidth: 160,
              buttonPadding: const EdgeInsets.only(left: 14, right: 14),

              buttonDecoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment (0,1),
                      colors: [
                        Color.fromRGBO(237, 249, 255, 1),
                        Color.fromRGBO(223, 244, 255, 1) ]
                  ),
                border: Border.all(
                    color: Color.fromRGBO(215, 241, 255, 1), width: 1.0
                ),
                borderRadius:  const BorderRadius.all(const Radius.circular(15.0)),

              ),

              dropdownFullScreen: true,

              itemHeight: 40,
              itemPadding: const EdgeInsets.only(left: 14, right: 14),
              dropdownMaxHeight: 200,

              dropdownPadding: null,

              dropdownElevation: 8,
              scrollbarRadius: const Radius.circular(40),
              scrollbarThickness: 6,
              scrollbarAlwaysShow: true,
              items: methods
                  .map((item) => DropdownMenuItem<String>(
                value: item.uuidPayment.toString(),
                child: Row(
                  children: [
                    Text(item.name, style: kStyle17SizeBlue,),
                    Spacer(),
                    _getIcon(item.type),
                  ],
                ),
              ))
                  .toList(),
              validator: (value) {
                if (value == null) {
                  return 'Добавьте метод оплаты';
                }
              },
              value: selectedValue,
              onChanged: (value) {
                selectedValue = value.toString();
                globals.currentPaymentMethod = selectedValue;
                if(value != "0") {
                  _controller!.changePaymentMethod(selectedValue);
                }
                print(selectedValue);
              },
              onSaved: (value) {
                selectedValue = value.toString();
                globals.currentPaymentMethod = selectedValue;
                print(selectedValue);
              },
            ),

            SizedBox(height: 25),



            TextButton(
              onPressed: () {

                _controller!.addPaymentMethod( (status) {
                  if (status is CheckoutSuccess) {
                    setState(() {
                      print(status.payment);
                      methods.add(status.payment);
                      selectedValue = status.payment.uuidPayment.toString() as String;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Ошибка добавления метода оплаты"))
                    );
                  }
                });

              },

              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.circlePlus,size: 15.0, color: Colors.blue,),
                  SizedBox(width: 10,),
                  Text('Добавить карту', style: kStyleInputTextSecond,),
                ],
              ),
            ),

            Divider(),
            SizedBox(height: 30,),
            Row(
              children: [
                Container(
                    width: 200,
                    child: Text('Теперь вы можете наливать воду. Чтобы начать нажмите кнопку старт на автомате', style: kStyleTextDefault15,)),
                Spacer(),
                Column(
                  children: [
                    Text('1 литр', style: kStyle21SizeBlue,),
                    SizedBox(height: 5,),
                    Text(globals.currentDevicePrice.toString() + " " +  num2word(globals.currentDevicePrice, ["рубль", "рубля","рублей"]), style: kStyle17SizeBlue,),
                  ],
                ),

              ],
            ),


           /* SizedBox(height: 30,),
            Divider(),
            Row(children: [
              Column(children: [
                Text("Температура воды:", style: kStyleTextDefault15),
                Text(globals.currentDeviceTemp.toString(), style: kStyle16SizeBlue,)
              ],),
              Spacer(),
              Column(children: [
                Text("Качество воды:", style: kStyleTextDefault15),
                Text(globals.currentDevicePpm.toString(), style: kStyle16SizeBlue,)
              ],)

            ],),*/
            Spacer(),
            getServiceButton(),
            Spacer(),
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
                    globals.currentPaymentMethod = selectedValue;
                    print(selectedValue);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PouringStep1Page(),
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
                            const Text('Налить воды', textAlign: TextAlign.center, style: kStyleButtonTextNew,),
                            SizedBox(width: 7,),
                            FaIcon(FontAwesomeIcons.droplet,size: 15.0, color: Colors.white,),

                          ],)



                    ),
                  ),
                ),



            ),

            Spacer(),
          ],
        ),

      );

    }


  }


  Widget  _getIcon(type){
    switch (type) {
        case 'Visa':
        return FaIcon(FontAwesomeIcons.ccVisa,size: 30.0, color: Colors.blue,);
        break;

        case 'MasterCard':
        return FaIcon(FontAwesomeIcons.ccMastercard,size: 30.0, color: Colors.blue,);
        break;

      case 'Bonus':
        return FaIcon(FontAwesomeIcons.wallet,size: 30.0, color: Colors.blue,);
        break;

      default:
        return FaIcon(FontAwesomeIcons.creditCard,size: 30.0, color: Colors.blue,);
    }
 }

 String num2word(num, words) {
    num = num%100;
    if(num>19) {num=num%10;}
    switch (num) {
      case 1: return words[0];
      case 2: case 3: case 4: return words[1];
      default: return words[2];
    }
 }

 Widget? changeMethod(methods) {
    print(methods.length);
    if (methods.length > 1) {
      return TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPaymentMethodPage(),
                ));
          },
          child: Text('Изменить', style: kStyle16SizeBlueUnderline,));
    } else {
      return Text('');
    }
 }

  Widget getServiceButton(){
    if(globals.service==1){
      return Row(children: [
        Spacer(),
        IconButton(
            iconSize: 60,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsUsbPage(),
                  ));
            },
            icon: FaIcon(FontAwesomeIcons.usb, size: 30.0, color: Colors.blue,)),
        Spacer(),
        IconButton(
            iconSize: 60,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ));
            },
            icon: FaIcon(FontAwesomeIcons.screwdriverWrench, size: 30.0, color: Colors.blue,)),
        Spacer(),
      ],);
    } else {
      return SizedBox(height: 0,);
    }
  }

}