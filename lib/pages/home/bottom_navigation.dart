
import 'package:flutter/material.dart';
import '../../models/tab.dart';

// создаем три пункта меню

const Map<TabItem, DwTab> tabs = {
  TabItem.HISTORY : const DwTab(name: "История", color: Colors.lightBlue, icon: Icons.menu_book),
  TabItem.MAP : const DwTab(name: "Карта", color: Colors.lightBlue, icon: Icons.map),
  TabItem.PROFILE : const DwTab(name: "Профиль", color: Colors.lightBlue, icon: Icons.account_circle),
};

class MyBottomNavigation extends StatelessWidget {
  // MyBottomNavigation принимает функцию onSelectTab
  // и текущую выбранную вкладку
  MyBottomNavigation({this.currentTab, this.onSelectTab});

  final TabItem? currentTab;
  // ValueChanged<TabItem> - функциональный тип,
  // то есть onSelectTab является ссылкой на функцию,
  // которая принимает TabItem объект
  final ValueChanged<TabItem>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    // Используем встроенный виджет BottomNavigationBar для
    // реализации нижнего меню
    return BottomNavigationBar(
        selectedItemColor: _colorTabMatching(currentTab),
        selectedFontSize: 11,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab!.index,
        // пункты меню
        items: [
          _buildItem(TabItem.HISTORY),
          _buildItem(TabItem.MAP),
          _buildItem(TabItem.PROFILE),
        ],
        // обработка нажатия на пункт меню
        // здесь мы делаем вызов функции onSelectTab,
        // которую мы получили через конструктор
        onTap: (index) => onSelectTab!(
            TabItem.values[index]
        )
    );
  }

  // построение пункта меню
  BottomNavigationBarItem _buildItem(TabItem item) {
    return BottomNavigationBarItem(
      // указываем иконку
      icon: Icon(
        _iconTabMatching(item),
        color: _colorTabMatching(item),
      ),
      // указываем метку или название
      label: tabs[item]!.name,
    );
  }

  // получаем иконку элемента
  IconData? _iconTabMatching(TabItem item) => tabs[item]!.icon;

  // получаем цвет элемента
  Color? _colorTabMatching(TabItem? item) {
    return currentTab == item ? tabs[item!]!.color : Colors.grey;
  }

}