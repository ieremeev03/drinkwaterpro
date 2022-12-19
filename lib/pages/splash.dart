import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/auth/mobile.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/pages/home/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:drinkwaterpro/data/repository.dart';



class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin{
 late VideoPlayerController _controller;
  bool _visible = false;
 final Repository repo = new Repository();
 late AnimationController _Vcontroller;
 late Animation _VAnimation;
 late Animation animation;
 late Animation changeColor;

 late AnimationController _Lcontroller;
 late Animation _LAnimation;

 late AnimationController _L2controller;
 late Animation _L2Animation;

 late AnimationController _L3controller;
 late Animation _L3Animation;


 @override
  void initState() {
    super.initState();

    print('init ' + globals.isLoggedIn.toString());

    FirebaseMessaging messaging = FirebaseMessaging.instance;





    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

   /* if(globals.isLoggedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ), (e) => false);
    }*/

    _controller = VideoPlayerController.asset("assets/voda_splashscreen.mp4");
    _controller.initialize().then((_) {
      _controller.setLooping(true);


      Timer(Duration(milliseconds: 100), () {
        setState(() {

          if(globals.isLoggedIn) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ), (e) => false);
          }
          _controller.play();
          _visible = true;
        });
      });
    });

    //анимация видео
    _Vcontroller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this);

    _VAnimation = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(new CurvedAnimation(
        parent: _Vcontroller,
        curve: Curves.linear
    ));
    _VAnimation.addListener(() => setState(() {}));
    _Vcontroller.forward();


    _Vcontroller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 2000), () {
        _Vcontroller.reverse();
        Future.delayed(const Duration(milliseconds: 1000), () {_Lcontroller.forward(); });


        });

      }
    });
    //анимация лого
    _Lcontroller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this);

    _LAnimation = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(new CurvedAnimation(
        parent: _Lcontroller,
        curve: Curves.linear
    ));


    _L2controller = AnimationController(
        duration: Duration(seconds: 2),
        vsync: this);

    _L2Animation = new IntTween(
      begin: 0,
      end: 50,
    ).animate(new CurvedAnimation(
        parent: _L2controller,
        curve: Curves.elasticInOut
    ));

    _LAnimation.addListener(() => setState(() {}));

    _L2Animation.addListener(() => setState(() { }));

    _Lcontroller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {

      _L2controller.forward();

      }
    });

    _L2controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _L3controller.forward();
      }
    });

    //анимация надписи
    _L3controller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this);

    _L3Animation = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(new CurvedAnimation(
        parent: _L3controller,
        curve: Curves.linear
    ));

    _L3Animation.addListener(() => setState(() { }));

    _L3controller.addStatusListener((status)  {
      if (status == AnimationStatus.completed) {


        Future.delayed(const Duration(milliseconds: 2000), () {

          print(globals.isLoggedIn);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ), (e) => false);


        });
      }
    });
 }

  @override
  void dispose() {

    _controller.dispose();
    _Vcontroller.dispose();
    _Lcontroller.dispose();
    _L2controller.dispose();
    _L3controller.dispose();
    if (_controller != null) {


    }

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: _VAnimation.value,
              child: VideoPlayer(_controller)
            ),

             Positioned(
               top: MediaQuery.of(context).size.height/2 - 100 -_L2Animation.value,
               left: MediaQuery.of(context).size.width/2 - 75,
               child:
             Opacity(
                 opacity: _LAnimation.value,
                 child: Center(child: Image.asset('assets/img/logo.png', height: 150,),)
             ),),

            Positioned(
              top: MediaQuery.of(context).size.height/2 ,
              //left: MediaQuery.of(context).size.width/2,
              child:
              Container(

                width: MediaQuery.of(context).size.width,
                child: Opacity(
                    opacity: _L3Animation.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 60), child: Center(child: Text('Добро пожаловать!' ,style: kStyle17SizeBlue600,)),),
                        Text('Мы рады вас видеть 🤗', style: kStyleTextDefault13,)
                      ],)
                ),)

            ),







            //
          ],
        ),
      ),
    );
  }
}