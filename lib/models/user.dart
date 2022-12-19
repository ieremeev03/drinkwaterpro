
// сначала создаем объект самого поста
import 'dart:convert';
import 'dart:developer';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

User userFromMap(String str) => User.fromMap(json.decode(str));

String userToMap(User data) => json.encode(data.toMap());

class User {
  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.city,
    this.birthday,
    this.timezone,
    this.srv,

  });

  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? city;
  String? birthday;
  String? timezone;
  int? srv;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    city: json["city"],
    birthday: json["birthday"],
    timezone: json["timezone"],
    srv: json["srv"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "city": city,
    "birthday": birthday,
    "timezone": timezone,
    "srv": srv,

  };


  factory User.fromMap(Map<dynamic, dynamic> json) => User(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    city: json["city"],
    birthday: json["birthday"],
    timezone: json["timezone"],
    srv: json["srv"],

  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "city": city,
    "birthday": birthday,
    "timezone": timezone,
    "srv": srv,

  };
}





class UserInfo {
  final List<User> user = [];
}

class isLogin {
  bool state = false;
  isLogin.state(){
    state = true;
  }
}

// у нас будут только два состояния
abstract class SignIn {}
// успешное добавление
class SignInSuccess extends SignIn {}
// ошибка
class SignInFailure extends SignIn {}

// у нас будут только два состояния
abstract class SendCode {}

// успешное добавление
class SendCodeSuccess extends SendCode {
  final Map<String, dynamic> token;
  SendCodeSuccess(this.token);
}

// ошибка
class SendCodeFailure extends SendCode {
  final String error;
  SendCodeFailure(this.error);
}


abstract class LoginResult {}

// указывает на успешный запрос
class LoginResultSuccess extends LoginResult {
  final bool userLogin;
  LoginResultSuccess(this.userLogin);
}

// произошла ошибка
class LoginResultFailure extends LoginResult {
  final String error;
  LoginResultFailure(this.error);
}

// загрузка данных
class LoginResultLoading extends LoginResult {
  LoginResultLoading();
}

abstract class ProfileResult {}

// указывает на успешный запрос
class ProfileResultSuccess extends ProfileResult {
  final User userInfo;
  ProfileResultSuccess(this.userInfo);
}

// произошла ошибка
class ProfileResultFailure extends ProfileResult {
  final String error;
  ProfileResultFailure(this.error);
}

// загрузка данных
class ProfileResultLoading extends ProfileResult {
  ProfileResultLoading();
}

abstract class EditProfile {}

// успешное редактирование
class EditProfileSuccess extends EditProfile {
  final User user;
  EditProfileSuccess(this.user);
}

// ошибка
class EditProfileFailure extends EditProfile {
  final String error;
  EditProfileFailure(this.error);
}