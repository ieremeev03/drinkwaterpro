import 'dart:ui';
import 'dart:io';
import 'package:async/async.dart';
import 'dart:async';

import 'package:drinkwaterpro/controllers/payment_controller.dart';
import 'package:drinkwaterpro/pages/pouring/final.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/payment.dart';
import '../../models/pouring.dart';
import '../../controllers/pouring_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:http_client/console.dart';
import 'package:drinkwaterpro/pages/payment/method.dart';
import 'package:drinkwaterpro/pages/history/history_list_page.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drinkwaterpro/pages/pouring/water-ani-1.dart';
import 'package:drinkwaterpro/pages/pouring/water-ani-2.dart';
import 'dart:convert';
import 'package:drinkwaterpro/data/repository.dart';
import 'package:drinkwaterpro/pages/map/map.dart';



import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class PouringPage extends StatefulWidget {
  @override
  _PouringPageState createState() => _PouringPageState();
}

final idempotenceKey = 'some_unique_idempotence_key' +
    DateTime.now().microsecondsSinceEpoch.toString();
const shopId = '670615';
const clientAppKey = 'live_y0MsUh-8xeHWgNE8xis6GultGLR4hs5D78SoQe7FqhY';
const secretKey = 'your secret key';
final Repository repo = Repository();
Duration _timerDuration = new Duration(seconds: 60);

// не забываем расширяться от StateMVC
class _PouringPageState extends StateMVC with TickerProviderStateMixin  {

  // ссылка на наш контроллер
  late PouringController _controller;
  PaymentController? _controllerPay;
  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _PouringPageState() : super(PouringController()) {
    _controller = controller as PouringController;
  }


  String liters = "0.0";
  int price = globals.currentDevicePrice;
  int summ =0;

  bool _isPouring = false;

  final client = MqttServerClient('lk.drinkwater.pro', globals.userPhone);
  var pongCount = 0; // Pong counter
  RestartableTimer? timer;



  @override
  void initState() {
    super.initState();
    //_controller.init();
    _controllerPay = PaymentController();
    timer = RestartableTimer(
        const Duration(seconds: 60),
            () {
          disconnect_Mqtt();
          _controller.lockDevice(globals.currentDeviceId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  PouringFinalPage(),
            ),
          );
        },);
    mqtt();

  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
    disconnect_Mqtt();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Налить воду', style: kStyleTextPageTitle,),

      ),
      body: _buildContent(),
      backgroundColor: Colors.white,
    );
  }



  Widget _buildContent() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 40, 50, 20),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Набирайте воду", style: kStyle17SizeBlue600),
          SizedBox(height: 20,),
          Text("Нажмите кнопку старт", style: kStyleTextDefault15),
          SizedBox(height: 30,),
          Stack(children: [
            Center(child:   pouring_svg(),),

            Padding(
                padding: EdgeInsets.fromLTRB(0, 180, 0, 0),
            child: Center(child: Column(

              children: [
                Text(liters, style: kStyle48SizeBlue,),

                Text("вы налили", style: kStyle18SizeBlue,),

              ],),),
             )
          ],),

          Spacer(),
          Row(
            children: [
              Spacer(),
              start_btn(),
              Spacer(flex: 4,),
              stop_btn(),
              Spacer(),

            ],
          ),


         Spacer()

        ],
      ),
    );
  }

  Widget start_btn() {
    timer?.reset();
    if (!_isPouring) {
      return  GestureDetector(
        onTap: (){
          print('start');
          //pouring = true;
          setState((){_isPouring = true;});
          _controller.startPouring(globals.currentDeviceId);
        },
        child:  SvgPicture.asset(
        'assets/img/start_a.svg',
        width: 80,
      )
      );
    }  else {
      return  GestureDetector(

          child:  SvgPicture.asset(
            'assets/img/start_d.svg',
            width: 80,
          )
      );

    }


  }

  Widget stop_btn() {
    timer?.reset();
    if (!_isPouring) {
      return  GestureDetector(
          onTap: (){
            print('final');
            disconnect_Mqtt();
            _controller.lockDevice(globals.currentDeviceId);
            //pouring = true;

            setState((){  });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => PouringFinalPage(),
                ),(Route<dynamic> route) => false,);
          },
          child:  SvgPicture.asset(
            'assets/img/final_a.svg',
            width: 80,
          )
      );
    }  else {
      return  GestureDetector(
          onTap: (){

            print('stop');
            //pouring = true;
            setState((){_isPouring = false;});
            _controller.stopPouring(globals.currentDeviceId);
          },
          child:  SvgPicture.asset(
            'assets/img/stop_a.svg',
            width: 80,
          )
      );

    }


  }

  Widget pouring_svg() {
    if (_isPouring) {
      return Waterani2(width: 200, height: 200,);
    }else{
      return Waterani1(width: 200, height: 200,);
    }

  }


  Future<int> mqtt() async {
    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// There is also an alternate websocket implementation for specialist use, see useAlternateWebSocketImplementation
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.
    /// You can also supply your own websocket protocol list or disable this feature using the websocketProtocols
    /// setter, read the API docs for further details here, the vast majority of brokers will support the client default
    /// list so in most cases you can ignore this.
    /// Set logging on if needed, defaults to off
    client.logging(on: false);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();
    client.port = 1883;
    /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
    client.keepAlivePeriod = 20;

    /// The connection timeout period can be set if needed, the default is 5 seconds.
    client.connectTimeoutPeriod = 2000; // milliseconds

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    client.onSubscribed = onSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the broker.
    client.pongCallback = pong;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password and clean session,
    /// an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect('0022','123456');
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }

    /// Ok, lets try a subscription
    print('EXAMPLE::Subscribing to the test/lol topic');
    final topic_liters = globals.currentDeviceUuid+'/sensor/liters';
    final topic_start = globals.currentDeviceUuid+'/cmd/startTmp';
    client.subscribe(topic_liters, MqttQos.atMostOnce);
    client.subscribe(topic_start, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      ///
      ///
      if(c[0].topic == topic_liters) {
        print(pt);
        timer?.reset();
        setState((){liters = pt.toString();});

      }

      if(c[0].topic == topic_start) {
        print(pt);
        timer?.reset();

        if (pt.toString() == "1") {
          setState((){_isPouring = true;});
        } else {
          setState((){_isPouring = false;});
        }
      }
      //

    });

    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the broker.
    client.published!.listen((MqttPublishMessage message) {
      print(
          'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });



    return 0;
  }

  void disconnect_Mqtt() {
    print('EXAMPLE::Disconnecting');
    client.disconnect();
    print('EXAMPLE::Exiting normally');
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      print(
          'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
    if (pongCount == 3) {
      print('EXAMPLE:: Pong count is correct');
    } else {
      print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
    repo.add_log('MQTT: Отключен');
  }

  /// The successful connect callback
  void onConnected() {
    repo.add_log('MQTT: Подключен');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }

}





