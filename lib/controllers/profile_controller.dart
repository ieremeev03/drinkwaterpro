
import '../data/repository.dart';
import '../models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/data/database.dart';

class ProfileController extends ControllerMVC {
  // создаем наш репозиторий
  final Repository repo = new Repository();
  final DatabaseHandler handler = DatabaseHandler();
  // конструктор нашего контроллера
  ProfileController();

  // первоначальное состояние - загрузка данных
  ProfileResult currentState = ProfileResultLoading();

  void init() async {
    try {
      // получаем данные из репозитория
      print('USER: получаем данные из репозитория');
      final userInfo = await handler.userInfo();
      // если все ок то обновляем состояние на успешное
      setState(() => currentState = ProfileResultSuccess(userInfo));
    } catch (error) {
      // в противном случае произошла ошибка
      setState(() => currentState = ProfileResultFailure("Произошла ошибка"));
    }
  }

  void logout() {
    print('USER: Выходим из профиля');
    handler.removeLoginUser();
  }

  void remove() async {
    print('USER: удаление учетной записи');
    final token = await handler.getParam('api_token');
    final result = await repo.removeProfile(token);
  }

  void editProfile(int id, String name, String city, String email, void Function(EditProfile) callback) async {
    try {
      print("Обновляем профиль репо");
      final token = await handler.getParam('api_token');
      print('token ' + token);
      final result = await repo.editProfile(token, id, name, city, email, );
      // сервер вернул результат
      //print(111);
      editUser(result);
      callback(EditProfileSuccess(result));
    } catch (error) {
      // произошла ошибка
      callback(EditProfileFailure("Ошибка получения информации"));
    }
  }

  void editUser(User user) async {
    print("USER: обновляем в базе");
    handler.removeLoginUser();
    handler.insertUser(user);
  }

}

