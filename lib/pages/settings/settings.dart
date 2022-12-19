import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>{

  final client = MqttServerClient('lk.drinkwater.pro', globals.userPhone);
  var pongCount = 0; // Pong counter
  final confTopic = globals.currentDeviceUuid+'/config';
  final cmdTopic = globals.currentDeviceUuid+'/cmd';
  final statusTopic = globals.currentDeviceUuid+'/status';
  final sensorTopic = globals.currentDeviceUuid+'/sensors';
  var params;
  var statuses;
  var sensors;

  @override
  void initState() {
    print('connect');
    super.initState();
    mqtt();
  }

  @override
  void dispose() {
    print('disconnect');
    disconnect_Mqtt();
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
                  Text("Запросить статус", style: kStyleInputProfileBold,),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        final builder = MqttClientPayloadBuilder();
                        builder.addString('status');
                        client.publishMessage(cmdTopic, MqttQos.atLeastOnce, builder.payload!);
                      },
                      icon: FaIcon(FontAwesomeIcons.cloudArrowDown, size: 30.0, color: Colors.blue,))
                ],),
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
                                onPressed: () {
                                  final builder = MqttClientPayloadBuilder();
                                  builder.addString('inventory');
                                  client.publishMessage(cmdTopic, MqttQos.atLeastOnce, builder.payload!);

                                  Navigator.pop(context, 'Ok');

                                  },
                                child: const Text('Да'),
                              ),
                            ],
                          ),),
                      icon: FaIcon(FontAwesomeIcons.coins, size: 30.0, color: Colors.blue,))
                ],),
                Row(children: [
                  Text("Перезагрузка", style: kStyleInputProfileBold,),
                  Spacer(),
                  IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Перезагрузить аппарат'),
                          content: const Text('Вы уверены?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () {
                                final builder = MqttClientPayloadBuilder();
                                builder.addString('reboot');
                                client.publishMessage(cmdTopic, MqttQos.atLeastOnce, builder.payload!);

                                Navigator.pop(context, 'Ok');

                              },
                              child: const Text('Да'),
                            ),
                          ],
                        ),),
                      icon: FaIcon(FontAwesomeIcons.rotateLeft, size: 30.0, color: Colors.blue,))
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

                    final builder = MqttClientPayloadBuilder();
                    builder.addString(jsonEncode(params));
                    client.publishMessage(confTopic, MqttQos.atLeastOnce, builder.payload!);

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



    client.subscribe(confTopic, MqttQos.atMostOnce);
    client.subscribe(statusTopic, MqttQos.atMostOnce);
    client.subscribe(sensorTopic, MqttQos.atMostOnce);

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
      if(c[0].topic == confTopic) {
        setState(() {
          params = jsonDecode(pt.toString());
          print(params);
        });
      }

      if(c[0].topic == statusTopic) {
        setState(() {
          statuses = jsonDecode(pt.toString());
          print(statuses);
        });
      }

        if(c[0].topic == sensorTopic) {
          setState(() {
            sensors = jsonDecode(pt.toString());
            print(sensors);
          });

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
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  /// Pong callback
  void pong() {
    //print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
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