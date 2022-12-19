
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
import 'package:drinkwaterpro/pages/history/water-ani-4.dart';

class EditPaymentMethodPage extends StatefulWidget {

  @override
  _EditPaymentMethodPageState createState() => _EditPaymentMethodPageState();
}

// не забываем расширять StateMVC
class _EditPaymentMethodPageState extends StateMVC {

  // _controller может быть null
  PaymentController? _controller;
  final Repository repo = Repository();
  // получаем PostController
  _EditPaymentMethodPageState() : super(PaymentController()) {
    _controller = controller as PaymentController;
  }

  @override
  void initState() {
    super.initState();
    _controller?.init();
  }

  // _formState пригодится нам для валидации
  //final _editKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Карты для оплаты", style: kStyleTextPageTitle,),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: _buildContent(),
      ),
      backgroundColor: Colors.white,
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
        selectedValue = methods[0].uuidPayment.toString();
      }


      return  Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getMethod(methods),
          ],
        ),

      );

    }


  }



  Widget _getMethod(methods) {
    if(methods.length >1) {
      return  ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: methods.length-1,
        separatorBuilder: (BuildContext context, int index) => Divider(color: Color.fromRGBO(110, 110, 110, 1),),
        itemBuilder: (BuildContext context, int index){
          return Container(
            padding: const EdgeInsets.only(left: 14, right: 14),
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Color.fromRGBO(215, 241, 255, 1), width: 1.0
              ),
              borderRadius:  const BorderRadius.all(const Radius.circular(15.0)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment (0,1),
                  colors: [
                    Color.fromRGBO(237, 249, 255, 1),
                    Color.fromRGBO(223, 244, 255, 1) ]
              ),
            ),
            child: Row(
              children: [

                GestureDetector(
                  child: FaIcon(FontAwesomeIcons.circleMinus,size: 20.0, color: Colors.red,),
                  onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Удаление карты оплаты'),
                      content: const Text('Вы уверены?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {



                            Navigator.pop(context, 'Ok');
                            _controller?.removePaymentMethod(methods[index].uuidPayment);

                            setState(() {
                              _controller?.init();
                              final state = _controller?.currentState;
                              //final history = _controller.;
                            });

                          },
                          child: const Text('Да'),
                        ),
                      ],
                    ),),
                ),
                SizedBox(width: 10,),
                Text(methods[index].name, style: kStyle17SizeBlue,),
                Spacer(),
                _getIcon(methods[index].type),
              ],
            ),
          );
        },
      );
    } else {
      return Column(

        children: [
          Waterani4(width: 200, height: 200,),
          SizedBox(height: 30,),
          Center(
            child: Text(
                'Вы не добавили ни одной карты для оплаты',
                textAlign: TextAlign.center,
                style: kStyleLabelForm
            ),
          ),
          SizedBox(height: 80,),
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

              _controller!.addPaymentMethod( (status) {
                if (status is CheckoutSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Карта добавлена"))
                  );


                  setState(() {
                    _controller?.init();
                    final state = _controller?.currentState;
                    //final history = _controller.;
                  });

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ошибка добавления метода оплаты"))
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
                      const Text('Добавить карту', textAlign: TextAlign.center, style: kStyleButtonTextNew,),


                    ],)



              ),
            ),
          ),
          SizedBox(height: 60,),

        ],);
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
}