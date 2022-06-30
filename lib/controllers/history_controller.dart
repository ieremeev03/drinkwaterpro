
import '../data/repository.dart';
import '../models/pouring.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class HistoryController extends ControllerMVC {
  // создаем наш репозиторий
  final Repository repo = new Repository();

  // конструктор нашего контроллера
  HistoryController();

  // первоначальное состояние - загрузка данных
  HistoryResult currentState = HistoryResultLoading();

  void init() async {
    try {
      // получаем данные из репозитория
      final pouringList = await repo.fetchPourings();
      // если все ок то обновляем состояние на успешное
      setState(() => currentState = HistoryResultSuccess(pouringList));
    } catch (error) {
      // в противном случае произошла ошибка
      setState(() => currentState = HistoryResultFailure("Нет интернета"));
    }
  }



}

