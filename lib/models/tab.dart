
import 'package:flutter/material.dart';

// будет хранить основную информацию
// об элементах меню
class DwTab {
  final String? name;
  final MaterialColor? color;
  final IconData? icon;

  const DwTab({this.name, this.color, this.icon});
}

// пригодиться для определения
// выбранного элемента меню
// у нас будет три страницы:
// посты, альбомы и задания
enum TabItem { HISTORY, MAP, PROFILE, AUTH, QR }