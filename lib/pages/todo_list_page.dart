import 'package:flutter/material.dart';
import 'package:listadetarefas/models/task.dart';
import 'package:listadetarefas/repositories/todo_repository.dart';

import '../widgets/todo_list_item.dart';

class ToDoListPage extends StatefulWidget {
  ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final TextEditingController taskListController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Task> tasks = [];
  Task? deleteTask;
  int? deletedTaskPos;
  String? errorText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskListController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String newTask = taskListController.text;

                        if (newTask.isEmpty) {
                          setState(() {
                            errorText = "O título não pode ser vazio!.";
                          });
                          return;
                        }

                        setState(() {
                          Task newTodo =
                              Task(title: newTask, dateTime: DateTime.now());
                          tasks.add(newTodo);
                          errorText = null;
                        });
                        taskListController.clear();
                        todoRepository.saveTodoList(tasks);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                          padding: EdgeInsets.all(14)),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Task todo in tasks)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                        child: Text(
                            'Você possui ${tasks.length} tarefas pendentes')),
                    ElevatedButton(
                      onPressed: deleteAllTasksShowConfirmation,
                      child: Text('Limpar tudo'),
                      style:
                          ElevatedButton.styleFrom(primary: Colors.blueAccent),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Task todo) {
    deleteTask = todo;
    deletedTaskPos = tasks.indexOf(todo);
    setState(() {
      tasks.remove(todo);
    });
    todoRepository.saveTodoList(tasks);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa ${todo.title} foi removida com sucesso! '),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              tasks.insert(deletedTaskPos!, deleteTask!);
            });
            todoRepository.saveTodoList(tasks);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void deleteAllTasksShowConfirmation() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Apagar tudo?'),
              content: Text('Você tem certeza que deseja apagar tudo?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                  style: TextButton.styleFrom(primary: Colors.blueAccent),
                ),
                TextButton(
                  onPressed: () {
                    content:
                    Text('Você tem certeza que deseja apagar tudo?');
                    deleteAllTasks();
                    Navigator.of(context).pop();
                  },
                  child: Text('Limpar Tudo'),
                  style: TextButton.styleFrom(primary: Colors.red),
                )
              ],
            ));
  }

  void deleteAllTasks() {
    setState(() {
      tasks.clear();
    });
    todoRepository.saveTodoList(tasks);
  }
}
