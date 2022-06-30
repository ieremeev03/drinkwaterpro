
import '../data/repository.dart';
import '../data/database.dart';
import '../models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;

class LoginController extends ControllerMVC {
  // создаем наш репозиторий

  final Repository repo = Repository();

  final DatabaseHandler handler = DatabaseHandler();

  // конструктор нашего контроллера
  LoginController();

  // первоначальное состояние - загрузка данных
  LoginResult currentState = LoginResultLoading();

  void init() async {
    try {
      // получаем данные из репозитория
      handler.initializeDB();

      // если все ок то обновляем состояние на успешное
      //setState(() => currentState = LoginResultSuccess(user));
    } catch (error) {
      // в противном случае произошла ошибка
      //setState(() => currentState = LoginResultFailure("Отсутствует подключение к интернету"));
    }
  }

  void sendSMS(String phone, void Function(SignIn) callback) async {
    try {
      final result = await repo.signIn(phone);
      // сервер вернул результат
      callback(SignInSuccess());
      globals.userPhone = phone;
    } catch (error) {
      // произошла ошибка
      callback(SignInFailure());
    }
  }

  void sendCode(String phone, String code, void Function(SendCode) callback) async {
    try {
      print('USER: Отправка смс кода');
      final result = await repo.sendCode(phone, code);
      print('result');
      print(result);
      setToken(result['token']);
      getUserInfo(result['token']);

      callback(SendCodeSuccess(result));
    } catch (error) {
      // произошла ошибка
      callback(SendCodeFailure('Ошибка отправки'));
    }
  }

  void getUserInfo (String token) async {
    try {
      final result = await repo.getUser(token);
      loginUser(result);
    } catch (error) {
      print(error);
    }
  }

  void loginUser(User user) async {
   globals.userId = int.parse(user.id.toString());
   await handler.removeLoginUser();
   await handler.insertUser(user);
  }

  void setToken(String token) async {
    await handler.setParam('api_token', token);
  }

  void isLoginUser() async {
    try {
      globals.isLoggedIn = await handler.isLoginUser();
      print('статус авторизации ' + globals.isLoggedIn.toString());
    }
    catch (error) {
     print(error);
    }
  }


}

