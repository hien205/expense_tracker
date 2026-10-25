
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    _database = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            receipt_image_path TEXT
          )
        ''');

        await _createUsersTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE transactions ADD COLUMN receipt_image_path TEXT',
          );
        }

        if (oldVersion < 3) {
          await _createUsersTable(db);
        }
      },
    );

    return _database!;
  }

  // =====================================================
  // BẢNG NGƯỜI DÙNG
  // =====================================================

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL COLLATE NOCASE UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Đăng ký người dùng.
  // passwordHash phải là chuỗi băm, không phải mật khẩu nguyên bản.
  Future<int> registerUser({
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    final db = await database;

    return db.insert(
      'users',
      {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password_hash': passwordHash,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Tìm người dùng bằng email, bao gồm password_hash
  // để tầng xác thực kiểm tra mật khẩu.
  Future<Map<String, dynamic>?> getUserByEmail(
    String email,
  ) async {
    final db = await database;

    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  // Lấy hồ sơ công khai, không trả về password_hash.
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;

    final results = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'created_at'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  // Cập nhật tên và email trong hồ sơ.
  Future<int> updateUser({
    required int id,
    required String name,
    required String email,
  }) async {
    final db = await database;

    return db.update(
      'users',
      {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // BẢNG GIAO DỊCH
  // =====================================================

  Future<int> insertTransaction(
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    return db.insert('transactions', data);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return db.query('transactions', orderBy: 'id DESC');
  }

  Future<int> updateTransaction(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await database;

    return db.update(
      'transactions',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // 20 GIAO DỊCH MẪU
  // =====================================================

  Future<int> seedDemoTransactions() async {
    final db = await database;

    final existing = await db.rawQuery(
      "SELECT COUNT(*) AS total FROM transactions "
      "WHERE title LIKE '[MẪU]%'",
    );

    final count = (existing.first['total'] as int?) ?? 0;
    if (count > 0) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String formatDate(
      DateTime date,
      int hour,
      int minute,
    ) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final h = hour.toString().padLeft(2, '0');
      final m = minute.toString().padLeft(2, '0');

      return '$day/$month/$year • $h:$m';
    }

    final samples = <Map<String, dynamic>>[
      {'title': 'Ăn sáng', 'amount': -35000, 'category': 'Ăn uống', 'daysAgo': 0, 'hour': 7, 'minute': 30},
      {'title': 'Cà phê', 'amount': -45000, 'category': 'Ăn uống', 'daysAgo': 0, 'hour': 9, 'minute': 15},
      {'title': 'Cơm trưa', 'amount': -55000, 'category': 'Ăn uống', 'daysAgo': 1, 'hour': 12, 'minute': 10},
      {'title': 'Trà sữa', 'amount': -42000, 'category': 'Ăn uống', 'daysAgo': 2, 'hour': 15, 'minute': 20},
      {'title': 'Ăn tối', 'amount': -85000, 'category': 'Ăn uống', 'daysAgo': 3, 'hour': 19, 'minute': 0},
      {'title': 'Gửi xe', 'amount': -10000, 'category': 'Di chuyển', 'daysAgo': 0, 'hour': 8, 'minute': 0},
      {'title': 'Đổ xăng', 'amount': -100000, 'category': 'Di chuyển', 'daysAgo': 2, 'hour': 8, 'minute': 30},
      {'title': 'Đặt xe', 'amount': -65000, 'category': 'Di chuyển', 'daysAgo': 5, 'hour': 17, 'minute': 45},
      {'title': 'Mua áo', 'amount': -250000, 'category': 'Mua sắm', 'daysAgo': 1, 'hour': 16, 'minute': 20},
      {'title': 'Mỹ phẩm', 'amount': -320000, 'category': 'Mua sắm', 'daysAgo': 4, 'hour': 14, 'minute': 10},
      {'title': 'Vở và bút', 'amount': -78000, 'category': 'Học tập', 'daysAgo': 3, 'hour': 10, 'minute': 0},
      {'title': 'Tài liệu học tập', 'amount': -120000, 'category': 'Học tập', 'daysAgo': 7, 'hour': 9, 'minute': 0},
      {'title': 'Tiền điện', 'amount': -350000, 'category': 'Hóa đơn', 'daysAgo': 6, 'hour': 10, 'minute': 30},
      {'title': 'Tiền Internet', 'amount': -150000, 'category': 'Hóa đơn', 'daysAgo': 8, 'hour': 11, 'minute': 0},
      {'title': 'Mua thuốc', 'amount': -95000, 'category': 'Sức khỏe', 'daysAgo': 9, 'hour': 16, 'minute': 0},
      {'title': 'Xem phim', 'amount': -110000, 'category': 'Giải trí', 'daysAgo': 10, 'hour': 20, 'minute': 0},
      {'title': 'Mua đồ gia dụng', 'amount': -180000, 'category': 'Khác', 'daysAgo': 12, 'hour': 15, 'minute': 30},
      {'title': 'Tiền làm thêm', 'amount': 800000, 'category': 'Khác', 'daysAgo': 1, 'hour': 18, 'minute': 0},
      {'title': 'Tiền được tặng', 'amount': 200000, 'category': 'Khác', 'daysAgo': 4, 'hour': 12, 'minute': 0},
      {'title': 'Thu nhập freelance', 'amount': 1200000, 'category': 'Khác', 'daysAgo': 7, 'hour': 17, 'minute': 30},
    ];

    final batch = db.batch();

    for (final sample in samples) {
      final date = today.subtract(
        Duration(days: sample['daysAgo'] as int),
      );

      batch.insert('transactions', {
        'title': '[MẪU] ${sample['title']}',
        'amount': sample['amount'],
        'category': sample['category'],
        'date': formatDate(
          date,
          sample['hour'] as int,
          sample['minute'] as int,
        ),
        'receipt_image_path': null,
      });
    }

    await batch.commit(noResult: true);
    return samples.length;
  }
}
