import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

const todoListKey = 'task_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  Future<List<Task>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecode = json.decode(jsonString) as List;
    return jsonDecode.map((e) => Task.fromJson(e)).toList();
  }

  void saveTodoList(List<Task> tasks) {
    final jsonString = json.encode(tasks);
    sharedPreferences.setString('task_list', jsonString);
  }
}
