import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:tugas_akhir_valorant/model/user_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'valorant_topup.db');

    return await openDatabase(
      path,
      version: 4, // Naikkan versi database
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vp INTEGER,
            price TEXT,
            currency TEXT,
            time TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE feedback(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kesan TEXT,
            pesan TEXT,
            time TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE bundle_purchases(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bundle_name TEXT NOT NULL,
            vp_spent INTEGER NOT NULL,
            time TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Ini akan dipanggil ketika versi database yang baru lebih tinggi dari yang lama.
        // Misalnya, jika pengguna memiliki database versi 1 dan Anda merilis versi 2.
        if (oldVersion < 2) {
          // Jika database lama tidak memiliki tabel 'users', buatlah.
          await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE feedback(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              kesan TEXT,
              pesan TEXT,
              time TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE bundle_purchases(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              bundle_name TEXT NOT NULL,
              vp_spent INTEGER NOT NULL,
              time TEXT
            )
          ''');
        }
      },
    );
  }

  Future<int> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('transactions', data);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'id DESC');
  }

  Future<int> insertFeedback(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('feedback', data);
  }

  Future<List<Map<String, dynamic>>> getAllFeedback() async {
    final db = await database;
    return await db.query('feedback', orderBy: 'id DESC');
  }

  Future<int> deleteFeedback(int id) async {
    final db = await database;
    return await db.delete('feedback', where: 'id = ?', whereArgs: [id]);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<int> registerUser(User user) async {
    final db = await database;
    final hashed = _hashPassword(user.password);
    final userMap = user.toMap()
      ..update('password', (_) => hashed, ifAbsent: () => hashed)
      ..removeWhere((key, value) => key == 'id' && value == null);
    return await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final hashed = _hashPassword(password);
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashed],
      limit: 1,
    );
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  // Mendapatkan total VP yang sudah dibeli (topup)
  Future<int> getTotalVP() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(vp) as total FROM transactions WHERE vp > 0',
    );
    final total = result.first['total'];
    return total != null ? (total as int) : 0;
  }

  // Mendapatkan total VP yang sudah digunakan (pembelian bundle)
  Future<int> getUsedVP() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(vp_spent) as total FROM bundle_purchases',
    );
    final total = result.first['total'];
    return total != null ? (total as int) : 0;
  }

  // Mendapatkan VP yang tersedia (total - digunakan)
  Future<int> getAvailableVP() async {
    final total = await getTotalVP();
    final used = await getUsedVP();
    return total - used;
  }

  // Membeli bundle (mengurangi VP)
  Future<bool> purchaseBundle(String bundleName, int vpCost) async {
    final db = await database;

    // Cek apakah VP cukup
    final availableVP = await getAvailableVP();
    if (availableVP < vpCost) {
      return false; // VP tidak cukup
    }

    // Simpan pembelian bundle
    await db.insert('bundle_purchases', {
      'bundle_name': bundleName,
      'vp_spent': vpCost,
      'time': DateTime.now().toIso8601String(),
    });

    return true; // Pembelian berhasil
  }

  // Mendapatkan riwayat pembelian bundle
  Future<List<Map<String, dynamic>>> getBundlePurchases() async {
    final db = await database;
    return await db.query('bundle_purchases', orderBy: 'id DESC');
  }
}
