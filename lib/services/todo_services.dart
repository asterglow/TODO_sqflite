import 'package:flutter/material.dart';
import 'package:todo_sqflite/database/todo_database.dart';

import '../models/todo_model.dart';

class TodoServices with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<String> getAllTodos(String username) async {
    try {
      _todos = await TodoDatabase.instance.getAllTodos(username);
      notifyListeners();
    } catch (e) {
      return e.toString();
    }
    return 'OK';
  }

  Future<String> deleteTodo(Todo todo) async {
    try {
      await TodoDatabase.instance.deleteTodo(todo);
    } catch (e) {
      return e.toString();
    }
    String result = await getAllTodos(todo.username);
    return result;
  }

  Future<String> createTodo(Todo todo) async {
    try {
      await TodoDatabase.instance.createTodo(todo);
    } catch (e) {
      return e.toString();
    }
    String result = await getAllTodos(todo.username);
    return result;
  }

  Future<String> toggleTodoDone(Todo todo) async {
    try {
      await TodoDatabase.instance.toggleTodoDone(todo);
    } catch (e) {
      return e.toString();
    }
    String result = await getAllTodos(todo.username);
    return result;
  }
  
}
