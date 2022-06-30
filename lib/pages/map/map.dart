
import 'package:drinkwaterpro/models/device.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/controllers/device_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drinkwaterpro/pages/map/qr.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

// не забываем расширяться от StateMVC
class _MapPageState extends StateMVC {

  // ссылка на наш контроллер
  late DeviceController _controller;

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _MapPageState() : super(DeviceController()) {
    _controller = controller as DeviceController;
  }

  //late YandexMapController controllerY;
  Completer<GoogleMapController> _controllerY = Completer();

  Future<bool> get locationPermissionNotGranted async => !(await Permission.location.request().isGranted);

  // после инициализации состояние
  // мы запрашивает данные у сервера
  @override
  void initState() {
    super.initState();
    _controller.init();
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
    );
  }

  Widget _buildContent() {
    final panelHeightClosed = 25.0;
    final panelHeightOpened= MediaQuery.of(context).size.height * 0.5;
    // первым делом получаем текущее состояние
    final state = _controller.currentState;
    if (state is DeviceResultLoading) {
      // загрузка
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is DeviceResultFailure) {
      // ошибка
      return Center(
        child: Text(
            state.error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.red)
        ),
      );
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
        panelBuilder: (controller) => MapPanelWidget(
          controller: controller,
          controller1: _controller,
          devices: devices,

        ),
        maxHeight: panelHeightOpened,
        minHeight: 100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(90)),
        parallaxEnabled: true,
        parallaxOffset: .5,
        color: Colors.transparent,
        body:  Container(
          child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: Set<Marker>.of(_controller.markers(devices)),
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
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                primary: Colors.transparent,
                padding: const EdgeInsets.all(0.0),
                elevation: 5,
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

}



class MapPanelWidget extends StatelessWidget {
  final ScrollController controller;
  final DeviceController controller1;
  final List<Device> devices;
  const MapPanelWidget({Key? key, required this.controller, required this.controller1, required this.devices}) : super(key: key);
  // отображаем список устройств

  @override
  Widget build(BuildContext context) => Container(
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
        controller: controller,

        //shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        itemCount: devices.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
            child:  Column(
              children: [
                InkWell(
                  onTap: () {
                    print(devices[index].id);
                  },
                  child:  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Автомат",
                              style:
                              TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              )),
                          SizedBox(height: 7,),
                          Text(devices[index].deviceAddress.toString(),
                              style:
                              TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black45
                              )),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          Container(

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
  );

}





