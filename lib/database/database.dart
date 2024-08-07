import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todolist/model/todo.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'todos';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'todo_database.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY,
            todotext TEXT,
            isdone INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.insert(tableName, task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return db.query(tableName);
  }

  Future<void> updateTaskIsDone(ToDo todo) async {
    final db = await database;

    await db.update(
      tableName,
      {'isdone': todo.isDone ? 1 : 0}, // 1 for true, 0 for false
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
