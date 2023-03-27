// ignore_for_file: prefer_const_declarations

import 'package:sqflite/sqflite.dart';
import 'package:todo_sqflite/models/todo_model.dart';
import '../models/user_model.dart';
import 'package:path/path.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._initialise();
  static Database? _database;
  TodoDatabase._initialise();

  Future _createDB(Database db, int version) async {
    final userUsernameType = 'TEXT PRIMARY KEY NOT NULL';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';

    await db.execute('''CREATE TABLE $userTable (
      ${UserFields.username} $userUsernameType,
      ${UserFields.name} $textType
    )''');

    await db.execute('''CREATE TABLE $todoTable (
      ${TodoFields.username} $textType,
      ${TodoFields.title} $textType,
      ${TodoFields.done} $boolType,
      ${TodoFields.created} $textType,
      FOREIGN KEY (${TodoFields.username}) REFERENCES $userTable (${UserFields.username})
    )''');
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future close() async {
    final db = await instance.database;
    db!.close();
  }

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDB('todo.db');
      return _database;
    }
  }

  Future<User> createUser(User user) async {
    final db = await instance.database;
    await db!.insert(userTable, user.toJson());
    return user;
  }

  Future<User> getUser(String username) async {
    final db = await instance.database;
    final maps = await db!.query(
      userTable,
      columns: UserFields.allFields,
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('$username not found in the database.');
    }
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final allUserMaps = await db!.query(
      userTable,
      orderBy: '${UserFields.username} ASC',
    );
    return allUserMaps.map((e) => User.fromJson(e)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return db!.update(userTable, user.toJson(),
        where: '${UserFields.username} = ?', whereArgs: [user.username]);
  }

  Future<int> deleteUser(String username) async {
    final db = await instance.database;
    return db!.delete(userTable,
        where: '${UserFields.username} = ?', whereArgs: [username]);
  }

  Future<Todo> createTodo(Todo todo) async {
    final db = await instance.database;
    await db!.insert(
      todoTable,
      todo.toJson(),
    );
    return todo;
  }

  Future<int> toggleTodoDone(Todo todo) async {
    final db = await instance.database;
    todo.done = !todo.done;
    return db!.update(
      todoTable,
      todo.toJson(),
      where: '${TodoFields.username} = ? AND ${TodoFields.title} = ?',
      whereArgs: [todo.username, todo.title],
    );
  }

  Future<List<Todo>> getAllTodos(String username) async {
    final db = await instance.database;
    final allTodoMaps = await db!.query(
      todoTable,
      orderBy: '${TodoFields.created} DESC',
      where: '${TodoFields.username} = ?',
      whereArgs: [username],
    );
    return allTodoMaps.map((e) => Todo.fromJson(e)).toList();
  }

  Future<int> deleteTodo(Todo todo) async {
    final db = await instance.database;
    return db!.delete(todoTable,
        where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
        whereArgs: [todo.title, todo.username]);
  }
}
