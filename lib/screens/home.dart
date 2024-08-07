import 'package:flutter/material.dart';
import '../widgets/todo_item.dart';
import '../constants/colors.dart';
import '../model/todo.dart';
import 'package:todolist/database/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                searchBox(),
                Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 20),
                  child: const Text(
                    'My Todo List',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _databaseHelper.getTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.hasData &&
                          snapshot.data is List<Map<String, dynamic>>) {
                        List<Map<String, dynamic>> data =
                            snapshot.data as List<Map<String, dynamic>>;
                        return Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              if (index < data.length) {
                                final todo = ToDo(
                                  id: data[index]["id"].toString(),
                                  todoText: data[index]["todotext"],
                                  isDone:
                                      data[index]["isdone"] == 0 ? false : true,
                                );

                                if (searchQuery.isEmpty ||
                                    todo.todoText!
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase())) {
                                  return ToDoItem(
                                    todo: todo,
                                    onDeleteItem: (id) async {
                                      await _databaseHelper.deleteTask(id);
                                      setState(() {});
                                    },
                                    onToDoChanged: (toDo) async {
                                      await _databaseHelper
                                          .updateTaskIsDone(toDo);
                                      setState(() {});
                                    },
                                  );
                                } else {
                                  return const SizedBox(); // Placeholder widget when item is not to be displayed
                                }
                              } else {
                                return const SizedBox();
                              }
                            },
                            itemCount: data.length,
                          ),
                        );
                      } else {
                        return const SizedBox(); // Placeholder widget for when there is no data or data is not in the expected format
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new goal to pursue!',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _databaseHelper.insertTask({
                        "todotext": _todoController.text,
                        "isdone": 0,
                      });
                      _todoController.clear();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdBlue,
                      minimumSize: const Size(60, 60),
                      elevation: 10,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu,
            color: tdBlack,
            size: 30,
          ),
        ],
      ),
    );
  }
}
