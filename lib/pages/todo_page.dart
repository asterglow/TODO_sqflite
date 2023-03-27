// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:todo_sqflite/services/todo_services.dart';
import 'package:todo_sqflite/services/user_services.dart';
import 'package:todo_sqflite/widgets/dialogs.dart';

import '../models/todo_model.dart';
import '../models/user_model.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late TextEditingController todoController;

  @override
  void initState() {
    super.initState();
    todoController = TextEditingController();
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text('Create a new TODO'),
                              content: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Please enter TODO'),
                                controller: todoController,
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text('Save'),
                                  onPressed: () async {
                                    if (todoController.text.isEmpty) {
                                      showSnackBar(context,
                                          'Please enter a Todo to save');
                                    } else {
                                      String username = await context
                                          .read<UserServices>()
                                          .currentUser
                                          .username;
                                      Todo todo = Todo(
                                        username: username,
                                        title: todoController.text.trim(),
                                        created: DateTime.now(),
                                      );
                                      if (context
                                          .read<TodoServices>()
                                          .todos
                                          .contains(todo)) {
                                        showSnackBar(context,
                                            'This Todo already exists');
                                      } else {
                                        String result = await context
                                            .read<TodoServices>()
                                            .createTodo(todo);
                                        if (result == 'OK') {
                                          showSnackBar(
                                              context, 'New Todo added');
                                          todoController.text = '';
                                        } else {
                                          showSnackBar(context, result);
                                        }
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Selector<UserServices, User>(
                  selector: (context, value) => value.currentUser,
                  builder: (context, value, child) {
                    return Text(
                      '${value.username}\'s Todo list',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '>>>>>> Slide to delete Todo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
                    color: Colors.purple[100],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                  child: Consumer<TodoServices>(
                    builder: (context, value, child) {
                      return ListView.builder(
                        itemCount: value.todos.length,
                        itemBuilder: (context, index) {
                          return TodoCard(todo: value.todos[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoCard extends StatelessWidget {
  const TodoCard({
    Key? key,
    required this.todo,
  }) : super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade300,
      child: Slidable(
        startActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                String result =
                    await context.read<TodoServices>().deleteTodo(todo);
                if (result == 'OK') {
                  showSnackBar(context, 'Deleted Todo');
                } else {
                  showSnackBar(context, result);
                }
              },
              icon: Icons.delete,
              backgroundColor: Colors.deepPurple,
            )
          ],
        ),
        // secondaryActions: [
        //   IconSlideAction(
        //     caption: 'Delete',
        //     color: Colors.purple[600],
        //     icon: Icons.delete,
        //     onTap: () async {},
        //   ),
        // ],
        child: CheckboxListTile(
          checkColor: Colors.purple,
          activeColor: Colors.purple[100],
          value: todo.done,
          onChanged: (value) async {
            String result =
                await context.read<TodoServices>().toggleTodoDone(todo);
            if (result != 'OK') {
              showSnackBar(context, result);
            }
          },
          subtitle: Text(
            '${todo.created.day}/${todo.created.month}/${todo.created.year}',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              color: Colors.white,
              decoration:
                  todo.done ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
