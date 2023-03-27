// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_sqflite/routes/routes.dart';
import 'package:todo_sqflite/services/todo_services.dart';
import 'package:todo_sqflite/services/user_services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserServices(),
        ),
        ChangeNotifierProvider(
          create: (context) => TodoServices(),
        )
      ], 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RouteManager.loginPage,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}
