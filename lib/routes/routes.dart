// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/todo_page.dart';


class RouteManager {
  static const String loginPage = '/';
  static const String registerPage = '/registerPage';
  static const String todoPage = '/todoPage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPage:
        return MaterialPageRoute(
          builder: (context) => Login(),
        );

      case registerPage:
        return MaterialPageRoute(
          builder: (context) => Register(),
        );

      case todoPage:
        return MaterialPageRoute(
          builder: (context) => TodoPage(),
        );

      default:
        throw FormatException('Route not found! Check routes again!');
    }
  }
}