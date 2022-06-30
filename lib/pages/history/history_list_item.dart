import 'package:flutter/material.dart';
import '../../models/pouring.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:intl/intl.dart';

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
                  Text("${pouring.liters!} "+   "л",
                      style:
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      )),
                  SizedBox(height: 10,),
                  Text('ул. '+ pouring.address!,
                      style: kStyleTextDefault15),
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
                  Text("${pouring.summ!} " +  'руб.', style: kStyleInputTextSecond600,),
                  SizedBox(height: 7,),
                  Row(children: [
                    Text(pouring.last4.toString(), style: kStyleTextDefault15,),
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

      default:
        return FaIcon(FontAwesomeIcons.creditCard,size: 20.0, color: kTextDefaultColor,);
    }
  }

}