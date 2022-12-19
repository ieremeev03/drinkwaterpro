
import 'package:flutter/material.dart';
import 'package:drinkwaterpro/pages/history/history_detail_page.dart';
import 'history_list_item.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../models/pouring.dart';
import '../../controllers/history_controller.dart';
import 'package:drinkwaterpro/pages/style.dart';
import 'package:drinkwaterpro/pages/history/water-ani-4.dart';

//final List<Pouring> Pourings = <Pouring>[Pouring("Мира 113", 5, 15, '21 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022'), Pouring("Ленина 66", 19, 53, '22 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022'), Pouring("Мира 113", 5, 15, '21 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022'), Pouring("Ленина 66", 19, 53, '22 марта 2022'), Pouring("Мира 113", 10, 30, '20 марта 2022') ];


class HistoryListPage extends StatefulWidget {
  @override
  _HistoryListPageState createState() => _HistoryListPageState();
}

// не забываем расширяться от StateMVC
class _HistoryListPageState extends StateMVC {

  // ссылка на наш контроллер
  late HistoryController _controller;

  // передаем наш контроллер StateMVC конструктору и
  // получаем на него ссылку
  _HistoryListPageState() : super(HistoryController()) {
    _controller = controller as HistoryController;
  }

  // после инициализации состояние
  // мы запрашивает данные у сервера
  @override
  void initState() {
    super.initState();
    _controller.init();
    print('reload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white70,
        centerTitle: true,
        title:  Text('История', style: kStyleTextPageTitle,),
      ),
      body: _buildContent(),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildContent() {
   // _controller.init();
    // первым делом получаем текущее состояние
    final state = _controller.currentState;

    if (state is HistoryResultLoading) {
      // загрузка
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is HistoryResultFailure) {
      // ошибка
      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        //Indicator Display Time Distance Top Position
        displacement: 40,
          child:  Column(

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
            ],),
        onRefresh: () async {
          setState(() {
            _controller.init();
            final state = _controller.currentState;
            //final history = _controller.;
          });
        },
      );
    } else {
      // отображаем список наливов
      final history = (state as HistoryResultSuccess).pouringList.pourings;
      return Padding(
        padding: EdgeInsets.all(20),
        child:
        RefreshIndicator(
          //Indicator color
          color: Theme.of(context).primaryColor,
          //Indicator Display Time Distance Top Position
          displacement: 40,
          child: ListView.separated(
            itemCount: history.length,
            separatorBuilder: (BuildContext context, int index) => Divider(color: Color.fromRGBO(110, 110, 110, 1),),
            itemBuilder: (context, index) {
              return HistoryListItem(history[index]);
            },
          ),
          //Drop-down refresh callback
          onRefresh: () async {
            setState(() {
                _controller.init();
                final state = _controller.currentState;
                //final history = _controller.;
            });
          },
        ),



      );
    }
  }


}



