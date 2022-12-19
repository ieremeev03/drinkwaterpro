
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
const Color kTextDefaultColor = Color.fromRGBO(117, 151, 168, 1);
const Color kTextBlueColor = Color.fromRGBO(25, 159, 227, 1);
const Color kTextBlue2Color = Color.fromRGBO(68, 191, 254, 1);
const Color kTextGreenColor = Color.fromRGBO(90, 216, 31, 1);
const Color kTextRedColor = Color.fromRGBO(254, 68, 68, 1);
const Color kTextRed2Color = Color.fromRGBO(254, 92, 103, 1);
const Color kBorderBlueColor = Color.fromRGBO(127, 151, 164, 100);
const Color kNav = Color.fromRGBO(244, 251, 255, 1);
const Color kNavBorder = Color.fromRGBO(224, 244, 255, 1);

//setLiters
const Color kLitersBorder = Color.fromRGBO(224, 244, 255, 1);
const Color kLitersBorderSelected = Color.fromRGBO(197, 232, 250, 1);
const Color kLitersButton = Color.fromRGBO(244, 251, 255, 1);
const Color kLitersButtonSelected = Color.fromRGBO(224, 244, 255, 1);
const kStyleLitersButtonText = TextStyle(
  fontSize: 14,  fontWeight: FontWeight.w600, color: Colors.blue,
);


const kStyleInputProfileBold =  TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

const kStyleLabelProfileBold =  TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

const kStyle21SizeBlue = TextStyle(
    fontSize: 25,  fontWeight: FontWeight.w700, color: kTextBlueColor, letterSpacing:  1
);

const kStyle48SizeBlue = TextStyle(
    fontSize: 60,  fontWeight: FontWeight.w400, color: kTextBlue2Color, letterSpacing:  1
);

const kStyle16SizeBlue = TextStyle(
    fontSize: 16,  fontWeight: FontWeight.w400, color: kTextBlueColor, letterSpacing:  1
);

const kStyle16SizeBlueUnderline = TextStyle(
    fontSize: 15,  fontWeight: FontWeight.w600, color: kTextBlueColor, letterSpacing:  1, decoration: TextDecoration.underline,
);

const kStyle18SizeBlue = TextStyle(
    fontSize: 20,  fontWeight: FontWeight.w400, color: kTextBlueColor, letterSpacing:  1
);

const kStyle17SizeBlue = TextStyle(
    fontSize: 17,  fontWeight: FontWeight.w400, color: kTextBlueColor,
);
const kStyle17SizeBlue600 = TextStyle(
  fontSize: 19,  fontWeight: FontWeight.w600, color: kTextBlueColor,
);

const kStyle17SizeBlack600 = TextStyle(
  fontSize: 19,  fontWeight: FontWeight.w600, color: Colors.black,
);

const kStyleTitleList = TextStyle(
  fontSize: 13,  fontWeight: FontWeight.w600, color: Colors.black,
);

const kStyleTextPageTitle = TextStyle(
    fontSize: 18,  fontWeight: FontWeight.w600, color: Colors.black,
);

const kStyleTextDefault = TextStyle(
  fontSize: 14, fontFamily: 'Gilroy', fontWeight: FontWeight.w400, color: kTextDefaultColor,
);

const kStyleTextDefaultRed = TextStyle(
  fontSize: 14, fontFamily: 'Gilroy', fontWeight: FontWeight.w400, color: kTextRedColor,
);

const kStyleTextDefault16 = TextStyle(
  fontSize: 18, fontFamily: 'Gilroy', fontWeight: FontWeight.w400, color: kTextDefaultColor,
);

const kStyleTextDefault12 = TextStyle(
    fontSize: 12,  fontWeight: FontWeight.w600, color: kTextDefaultColor, letterSpacing:  1
);
const kStyleTextDefault13 = TextStyle(
  fontFamily: 'Gilroy', fontSize: 14,  fontWeight: FontWeight.w400, color: kTextDefaultColor,
);


const kStyleTextDefault14 = TextStyle(
  fontFamily: 'Gilroy', fontSize: 15,  fontWeight: FontWeight.w400, color: kTextDefaultColor,
);

const kStyleTextDefault15 = TextStyle(
  fontFamily: 'Gilroy', fontSize: 16,  fontWeight: FontWeight.w400, color: kTextDefaultColor,
);

const kStyleLabelForm = TextStyle(
  fontSize: 16,  fontWeight: FontWeight.w600, color: kTextDefaultColor,
);

const kStyleInputText = TextStyle(
    fontSize: 22,  fontWeight: FontWeight.w400, color: kTextBlueColor, letterSpacing:  0.7
);

const kStyleInputTextRed = TextStyle(
    fontSize: 22,  fontWeight: FontWeight.w400, color: kTextRed2Color, letterSpacing:  0.7
);

const kStyleInputTextSecond = TextStyle(
  fontSize: 15,  fontWeight: FontWeight.w400, color: kTextBlueColor,
);

const kStyleInputTextSecond600 = TextStyle(
  fontSize: 16,  fontWeight: FontWeight.w600, color: kTextBlueColor,
);

const kStyleInputTextSecond600Green = TextStyle(
  fontSize: 16,  fontWeight: FontWeight.w600, color: kTextGreenColor,
);

const kStyleButtonText= TextStyle(
  fontSize: 16,  fontWeight: FontWeight.w400, color: Colors.white,
);

const kStyleButtonTextNew= TextStyle(
  fontSize: 17,  fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: 0.5
);

final ButtonStyle flatButtonStyle = TextButton.styleFrom(
  textStyle: kStyleButtonText,
  //primary: Colors.blue.shade100,
  minimumSize: Size(50, 50),
  //padding: EdgeInsets.symmetric(horizontal: 36.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);

final ButtonStyle noBgButtonStyle = TextButton.styleFrom(
  textStyle: kStyleButtonText,
  primary: Colors.blue.shade100,
  //minimumSize: Size(50, 50),
  padding: EdgeInsets.symmetric(horizontal: 0),

);

const kStyleFormInputPhone = InputDecoration(


    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),

    labelText: '',
    //prefixStyle: kStyleInputText,
    //floatingLabelBehavior: FloatingLabelBehavior.always,
);

const kStyleFormNoBorder = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
  border: InputBorder.none,
  labelText: '',
);

const kStyleFormNoBorderEmail = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
  border: InputBorder.none,
  labelText: 'Электронная почта',
  labelStyle: kStyleLabelProfileBold,
  suffixIcon: Padding(
      padding: const EdgeInsetsDirectional.only(end: 0.0),
      child: Icon(Icons.edit, size: 15,), // myIcon is a 48px-wide widget.
    )
);

const kStyleFormNoBorderName = InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
    border: InputBorder.none,
    labelText: 'Имя',
    labelStyle: kStyleLabelProfileBold,
    suffixIcon: Padding(
      padding: const EdgeInsetsDirectional.only(end: 0.0),
      child: Icon(Icons.edit, size: 15,), // myIcon is a 48px-wide widget.
    )
);

const kStyleFormNoBorderCity = InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
    border: InputBorder.none,
    labelText: 'Город',
    labelStyle: kStyleLabelProfileBold,
    suffixIcon: Padding(
      padding: const EdgeInsetsDirectional.only(end: 0.0),
      child: Icon(Icons.edit, size: 15,), // myIcon is a 48px-wide widget.
    )
);

const kStyleFormNoBorderPhone = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
  border: InputBorder.none,
  labelText: 'Телефон',
  labelStyle: kStyleLabelProfileBold,
);

const kStyleFormInputCard = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
  border: OutlineInputBorder(
    borderRadius:  const BorderRadius.all(const Radius.circular(15.0)),
  ),
  labelText: '',
  labelStyle: kStyleLabelForm,
  prefixStyle: kStyleInputText,
  floatingLabelBehavior: FloatingLabelBehavior.always,
  //prefixText: '****  6674',
  prefixIcon: FaIcon(FontAwesomeIcons.ccVisa,size: 25.0, color: Colors.blue,),
);