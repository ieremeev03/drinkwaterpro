import 'package:flutter/material.dart';
import '../../models/pouring.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:intl/intl.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;

// элемент списка
class HistoryListItem extends StatelessWidget {

  final Pouring pouring;

  // элемент списка отображает один пост
  HistoryListItem(this.pouring);

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
      child:  Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${pouring.liters!.toStringAsFixed(2)} "+   "л",
                      style:
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      )),
                  SizedBox(height: 10,),
                    Container(
                      width: 220,
                      child: Text(
                      'ул. '+ pouring.address!,
                      style: kStyleTextDefault15,
                      softWrap: true,
                    ),),

                  SizedBox(height: 14,),
                  Text(DateFormat('dd.MM.yyyy hh:mm').format(pouring.date!),
                      style:
                      TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.black38
                      )),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${pouring.summ!.toStringAsFixed(2)} " +  'руб.', style: kStyleInputTextSecond600,),
                  SizedBox(height: 7,),
                  Row(children: [
                    _getTextCard(pouring.last4),
                    SizedBox(width: 10,),
                    _getIcon(pouring.card_type),
                  ],)


                ],
              )

            ],
          )
        ],

      ),
    );
  }

  Widget  _getIcon(type){
    switch (type) {
      case 'Visa':
        return FaIcon(FontAwesomeIcons.ccVisa,size: 20.0, color: kTextDefaultColor,);
        break;

      case 'MasterCard':
        return FaIcon(FontAwesomeIcons.ccMastercard,size: 20.0, color: kTextDefaultColor,);
        break;

      case 'Bonus':
        return FaIcon(FontAwesomeIcons.wallet,size: 20.0, color: kTextDefaultColor,);
        break;

      case null:
        return FaIcon(FontAwesomeIcons.exclamationCircle,size: 20.0, color: kTextRedColor,);
        break;

      default:
        return FaIcon(FontAwesomeIcons.creditCard,size: 20.0, color: kTextDefaultColor,);
    }
  }

  Widget  _getTextCard(last4){
   if (last4 != null && last4 != "") {
     //print(last4);
     return  Text(last4.toString(), style: kStyleTextDefault15);
   } else {
     globals.blockPouring = true;
     return TextButton(
         onPressed: () => null,
         child: Text("", style: TextStyle(color: kTextRedColor), ));
   }
  }

}