import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentDirectory.path}main.db';
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE Notifications(messageId TEXT PRIMARY KEY, title TEXT, body TEXT, date TEXT, read INTEGER)',
    );
  }

  Future<int> saveNotification(
    String messageId,
    String title,
    String body,
    String date,
  ) async {
    var dbClient = await db;
    int res = await dbClient.insert('Notifications', {
      'messageId': messageId,
      'title': title,
      'body': body,
      'date': date,
      'read': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query(
      'Notifications',
      orderBy: "datetime(date) DESC", // Sorts correctly
    );
    return res;
  }

  Future<void> updateReadStatus(String messageId, int newStatus) async {
    var dbClient = await db;
    await dbClient.update(
      'Notifications',
      {'read': newStatus},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> updateAllMessageRead() async {
    var dbClient = await db;
    await dbClient.update(
      'Notifications',
      {'read': 1},
      where: 'read = ?',
      whereArgs: [0],
    );
  }

  Future<int> getUnreadMessageCount() async {
    var dbClient = await db;
    final List<Map<String, dynamic>> unreadMessages = await dbClient.query(
      'Notifications',
      where: 'read = ?',
      whereArgs: [0], // 0 represents unread messages
    );
    return unreadMessages.length;
  }
}
