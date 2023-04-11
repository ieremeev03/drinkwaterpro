
import '../data/repository.dart';
import '../models/pouring.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;

class HistoryController extends ControllerMVC {
  // создаем наш репозиторий
  final Repository repo = new Repository();

  // конструктор нашего контроллера
  HistoryController();

  // первоначальное состояние - загрузка данных
  HistoryResult currentState = HistoryResultLoading();

  void init() async {
    globals.blockPouring = false;
    try {
      // получаем данные из репозитория
      final pouringList = await repo.fetchPourings();
      repo.add_log('POURING: Получение списка наливов');
      // если все ок то обновляем состояние на успешное
      setState(() => currentState = HistoryResultSuccess(pouringList));
    } catch (error) {
      // в противном случае произошла ошибка
      repo.add_log('POURING: Ошибка получения списка наливов');
      setState(() => currentState = HistoryResultFailure("Вы не совершили ни одной покупки."));
    }
  }



}

