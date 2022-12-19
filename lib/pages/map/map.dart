
import 'package:drinkwaterpro/models/device.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/controllers/device_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drinkwaterpro/pages/map/qr.dart';
import 'package:drinkwaterpro/pages/pouring/ppm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'dart:io' show Platform;
import 'package:drinkwaterpro/data/repository.dart';
import 'package:drinkwaterpro/pages/history/water-ani-4.dart';
import 'package:drinkwaterpro/pages/home/block.dart';
import 'package:drinkwaterpro/pages/settings/settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

// не забываем расширяться от StateMVC
class _MapPageState extends StateMVC {

  // ссылка на наш контроллер
  late DeviceController _controller;
  final Repository repo = new Repository();

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _MapPageState() : super(DeviceController()) {
    _controller = controller as DeviceController;
  }
  BitmapDescriptor? _pinLocationIcon;
  //late YandexMapController controllerY;
  Completer<GoogleMapController> _controllerY = Completer();

  var controllerStream = new StreamController<int>();
  int curDev = 0;
  var k1Text;

  Future<bool> get locationPermissionNotGranted async => !(await Permission.location.request().isGranted);


  // Object for PolylinePoints
  late PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};
  ScrollController _scrollcontroller = ScrollController();


  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('inn app message');
  }

  // после инициализации состояние
  // мы запрашивает данные у сервера
  @override
  void initState() {
    //print(locationPermissionNotGranted);
    super.initState();
    setupInteractedMessage();

    _controller.init(context);
    //controllerStream.stream.listen((item) => print(item));
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(21, 30)), 'assets/img/Location.png')
        .then((onValue) {
      _pinLocationIcon = onValue;
    });



  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white70,
        centerTitle: true,
        title: Text('Автоматы поблизости', style: kStyleTextPageTitle,),

      ),
      body: _buildContent(),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildContent() {
    final panelHeightClosed = 25.0;
    final panelHeightOpened= MediaQuery.of(context).size.height * 0.5;
    //final panelHeightOpened= 200.0;
    // первым делом получаем текущее состояние
    final state = _controller.currentState;
    if (state is DeviceResultLoading) {
      // загрузка
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is DeviceResultFailure) {
      // ошибка
      return Column(

        children: [
          Spacer(),
          Waterani4(width: 200, height: 200,),
          Center(
            child: Text(
                state.error,
                textAlign: TextAlign.center,
                style: kStyleLabelForm
            ),
          ),
          Spacer(),
        ],);
    } else {
      // отображаем список наливов
      final devices = (state as DeviceResultSuccess).deviceList.devices;

      return  SlidingUpPanel(
        //backdropEnabled: true,
        //panelSnapping: true,
        //defaultPanelState: PanelState.CLOSED,
        boxShadow: [BoxShadow(
          color: Colors.transparent,
          spreadRadius: 0,
          blurRadius: 0,
          offset: Offset(0, 3), // changes position of shadow
        ),],
        panelBuilder: (_scrollcontroller) => Container(
          margin: EdgeInsets.only(top: 80.0),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),],
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: ListView.separated(
            //scrollDirection: Axis.vertical,
              controller:_scrollcontroller,

              //shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              itemCount: devices.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (context, index)  {

                double distanceInMeters =  Geolocator.distanceBetween(
                  globals.userLat!,
                  globals.userLon!,
                  double.parse(devices[index].latitude),
                  double.parse(devices[index].longitude),
                );

                if (devices[index].id== curDev) {

                 k1Text =  Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(devices[index].range_str, style: kStyleTextDefaultRed,),
                     SizedBox(height: 7,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text("Температура воды: ", style: kStyleTextDefault13,),
                         Text(devices[index].temp.toString() + '°С', style: kStyleInputTextSecond600,),

                       ],),
                     SizedBox(height: 3,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text("Чистота (PPM) ", style: kStyleTextDefault13,),
                         Text(devices[index].ppm.toString() + ' мг/л', style: kStyleInputTextSecond600Green,),
                         SizedBox(width: 5,),

                         GestureDetector(
                           onTap: () {
                             Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => PouringPPMPage(),
                                 ));
                           },
                           child:  FaIcon(
                             FontAwesomeIcons.solidCircleQuestion,
                             size: 15.0,
                             color: Colors.blueAccent,
                           ),),



                       ],),

                   ],);
                 // print(devices[index].id);
                } else {
                  k1Text =  Text(devices[index].range_str, style: kStyleTextDefault
                );
                }

                return Padding(
                  padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
                  child:  Column(
                    children: [
                      InkWell(

                        onTap: () {
                        /*  _controllerY.animateCamera(
                              CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng( double.parse(devices[index].latitude), double.parse(devices[index].longitude))
                                    )
                              )
                          );*/
                        },

                        child:  Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(devices[index].deviceName,
                                    style:
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    )),
                                SizedBox(height: 7,),
                                Text(devices[index].deviceAddress.toString(),
                                    style: kStyleTextDefault),
                                SizedBox(height: 7,),
                                k1Text,



                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {

                                    final dev = AnalyticsEventItem(
                                      itemId: devices[index].id.toString(),
                                      itemName: devices[index].deviceAddress,
                                      price: devices[index].price,
                                    );

                                    await FirebaseAnalytics.instance.logViewItem(
                                      currency: 'RUB',
                                      value: devices[index].price?.toDouble(),
                                      items: [dev],
                                    );

                                    setState(() {
                                      if (polylines.isNotEmpty)
                                        polylines.clear();
                                      if (polylineCoordinates.isNotEmpty)
                                        polylineCoordinates.clear();
                                    });

                                    await _createPolylines(globals.userLat!, globals.userLon!, double.parse(devices[index].latitude), double.parse(devices[index].longitude));

                                    if(globals.debug) repo.add_log("route to device id #" + devices[index].id.toString());

                                  },
                                  child:  Container(

                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment (0,1),
                                            colors: [
                                              Color.fromRGBO(237, 249, 255, 1),
                                              Color.fromRGBO(223, 244, 255, 1) ]
                                        ),
                                        border: Border.all(
                                          color: kNavBorder,
                                        ),
                                        color: kNav,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child:  Image.asset('assets/img/Directions.png', scale: 2.2,),

                                      )

                                  ),
                                ),

                              ],
                            )

                          ],
                        ),
                      )

                    ],

                  ),
                );
              }



          ),
        ),
        defaultPanelState: PanelState.OPEN,
        maxHeight: panelHeightOpened,
        minHeight: 100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(90)),
        parallaxEnabled: true,
        parallaxOffset: .9,
        color: Colors.transparent,
        body:  Container(
          child: GoogleMap(
              polylines: Set<Polyline>.of(polylines.values),
              mapToolbarEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              //buildingsEnabled: true,
              //liteModeEnabled: true,
              mapType: MapType.normal,
              markers: Set<Marker>.of(markers(devices)),
              initialCameraPosition: CameraPosition(
                target: LatLng(37.42796133580664, -122.085749655962),
                zoom: 14.4746,
              ),
            onMapCreated: (GoogleMapController controllerY) async {
              final center = _controller.currentPosition().then((value)  {
                controllerY.animateCamera(CameraUpdate.newCameraPosition(value));
              });
            },
          )

        ),
        header: Container(
          //padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          //margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
          //height: 50,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  fixedSize: MaterialStateProperty.all(const Size(270, 60)),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )
                  )
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QrPage()));
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
                    width: 270,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)) ,
                    ) ,
                    padding: const EdgeInsets.all(15),
                    constraints: const BoxConstraints(minWidth: 88.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Сканировать QR', textAlign: TextAlign.center, style: kStyleButtonTextNew,),
                        SizedBox(width: 7,),
                        FaIcon(FontAwesomeIcons.qrcode,size: 15.0, color: Colors.white,)

                      ],)



                ),
              ),
            ),




          )
        ),
        collapsed: Center(
          child: Container(
            margin: EdgeInsets.only(top: 75.0),
            height: 3,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.grey
            ),
          ),
        ),


      );
    }
  }

  Set<Marker>  markers (List<Device> devices) {
    final Set<Marker> markers = new Set();


    devices.forEach((value)  {
      var latitude = double.parse(value.latitude);
      assert(latitude is double);
      var longitude = double.parse(value.longitude);
      assert(longitude is double);

      if (Platform.isAndroid) {
        _pinLocationIcon = BitmapDescriptor.defaultMarker;
      } else if (Platform.isIOS) {
        _pinLocationIcon = BitmapDescriptor.defaultMarker;
      }

      if ( _pinLocationIcon != null) {
        markers.add( Marker(
          markerId: MarkerId(value.id.toString()),
          position: LatLng(latitude, longitude),
          onTap: () async {

            final dev = AnalyticsEventItem(
              itemId: value.id.toString(),
              itemName: value.deviceAddress,
              price: value.price,
            );

            await FirebaseAnalytics.instance.logViewItem(
              currency: 'RUB',
              value: value.price?.toDouble(),
              items: [dev],
            );

            if(globals.service==1)  {

              _controller.getDevice(value.id.toString(),  (status) {
                if (status is DeviceInfoSuccess) {

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ));

                } else {

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ошибка подключения"))
                  );
                }
              });




            } else {
              setState((){
                curDev = value.id!;
                print(curDev);
              });
              _scrollcontroller.animateTo(
                  _scrollcontroller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut);
            }
          }  ,
          icon: _pinLocationIcon!,
          //icon: BitmapDescriptor.defaultMarker,
        ));
      } else {
        markers.add( Marker(
          markerId: MarkerId(value.id.toString()),
          position: LatLng(latitude, longitude),
          onTap: () async {
            final dev = AnalyticsEventItem(
              itemId: value.id.toString(),
              itemName: value.deviceAddress,
              price: value.price,
            );

            await FirebaseAnalytics.instance.logViewItem(
              currency: 'RUB',
              value: value.price?.toDouble(),
              items: [dev],
            );

            setState((){
              curDev = value.id!;
              print(curDev);
              _scrollcontroller.position.maxScrollExtent;
            });
          } ,

        ));
      }

    });

    return markers;
  }

  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    // Initializing PolylinePoints

    print(startLatitude);
    print(startLongitude);
    print(destinationLatitude);
    print(destinationLongitude);

    String tok = 'AIzaSyChGXUSisd7kq8SlxNv5EUpiADDEXpv5Lo';

    if (Platform.isIOS) {tok = 'AIzaSyD1QvAX3Ic_m40SMJvwimLGcfRbOQ1Qyyg';}
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      tok, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    print(result.errorMessage);

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromRGBO(25, 159, 227, 1),
      points: polylineCoordinates,
      width: 5,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
    setState(() {});
    print(polyline.points.length);
  }

  String num2meters(num) {
    num = num%100;
    if(num>19) {num=num%10;}
    switch (num) {
      case 1: return "метр";
      case 2: case 3: case 4: return "метра";
      default: return "метров";
    }
  }

}



  






