import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Sqldb {
  static Database? _db;

  Future<Database> initializeDb() async {
    final path = join(await getDatabasesPath(), 'learn.db');

    final database = await openDatabase(
      path,
      version: 2, // 👈 bump version (adds meta table)
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    // =======================
    // META (for caching TTL)
    // =======================
    await db.execute('''
      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT
      );
    ''');

    // =======================
    // CATEGORIES
    // =======================
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        title_ar TEXT NOT NULL,
        title_en TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL
      );
    ''');

    // =======================
    // INSTRUCTORS
    // =======================
    await db.execute('''
      CREATE TABLE instructors (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        bio TEXT,
        photo TEXT,
        social_links TEXT
      );
    ''');

    // =======================
    // COURSES
    // =======================
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        date_updated TEXT,
        title_ar TEXT NOT NULL,
        title_en TEXT NOT NULL,
        description_ar TEXT NOT NULL,
        description_en TEXT NOT NULL,
        thumbnail TEXT NOT NULL,
        rating REAL NOT NULL DEFAULT 0,
        category_id INTEGER NOT NULL,
        instructor_name TEXT NOT NULL,
        level TEXT NOT NULL
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_courses_category ON courses(category_id);',
    );
    await db.execute(
      'CREATE INDEX idx_courses_created ON courses(created_at);',
    );
    await db.execute('CREATE INDEX idx_courses_level ON courses(level);');

    // =======================
    // LESSONS
    // =======================
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY,
        title_ar TEXT NOT NULL,
        title_en TEXT NOT NULL,
        description_ar TEXT NOT NULL,
        description_en TEXT NOT NULL,
        video_url TEXT NOT NULL,
        duration INTEGER NOT NULL,
        course_id INTEGER NOT NULL
      );
    ''');

    await db.execute('CREATE INDEX idx_lessons_course ON lessons(course_id);');

    // =======================
    // ENROLLMENTS
    // =======================
    await db.execute('''
      CREATE TABLE enrollments (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        course_id INTEGER NOT NULL,
        progress_percent REAL NOT NULL DEFAULT 0,
        date_enrolled TEXT NOT NULL,
        UNIQUE(user_id, course_id)
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_enrollments_user ON enrollments(user_id);',
    );
    await db.execute(
      'CREATE INDEX idx_enrollments_course ON enrollments(course_id);',
    );

    // =======================
    // FAVORITES
    // =======================
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        course_id INTEGER NOT NULL,
        UNIQUE(user_id, course_id)
      );
    ''');

    await db.execute('CREATE INDEX idx_favorites_user ON favorites(user_id);');
    await db.execute(
      'CREATE INDEX idx_favorites_course ON favorites(course_id);',
    );

    // =======================
    // LESSON PROGRESS
    // =======================
    await db.execute('''
      CREATE TABLE lesson_progress (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        course_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        lesson_id INTEGER NOT NULL,
        watched_seconds INTEGER NOT NULL DEFAULT 0,
        UNIQUE(user_id, lesson_id)
      );
    ''');

    await db.execute('CREATE INDEX idx_lp_user ON lesson_progress(user_id);');
    await db.execute(
      'CREATE INDEX idx_lp_course ON lesson_progress(course_id);',
    );
    await db.execute(
      'CREATE INDEX idx_lp_lesson ON lesson_progress(lesson_id);',
    );

    // =======================
    // POPULAR
    // =======================
    await db.execute('''
      CREATE TABLE popular (
        id INTEGER PRIMARY KEY,
        course_id INTEGER NOT NULL,
        user_id TEXT NOT NULL
      );
    ''');

    await db.execute('CREATE INDEX idx_popular_course ON popular(course_id);');
    await db.execute('CREATE INDEX idx_popular_user ON popular(user_id);');

    // =======================
    // RECOMMEND
    // =======================
    await db.execute('''
      CREATE TABLE recommend (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        recommend_course_id INTEGER NOT NULL
      );
    ''');

    await db.execute('CREATE INDEX idx_recommend_user ON recommend(user_id);');
    await db.execute(
      'CREATE INDEX idx_recommend_course ON recommend(recommend_course_id);',
    );

    log('DB created (v$version)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_meta (
          key TEXT PRIMARY KEY,
          value TEXT
        );
      ''');
    }
  }

  Future<Database> get db async {
    _db ??= await initializeDb();
    return _db!;
  }

  // ---------- Safer parameterized helpers ----------

  Future<List<Map<String, Object?>>> readData({
    required String sql,
    List<Object?>? args,
  }) async {
    final dbClient = await db;
    return dbClient.rawQuery(sql, args);
  }

  Future<int> insertData({required String sql, List<Object?>? args}) async {
    final dbClient = await db;
    return dbClient.rawInsert(sql, args);
  }

  Future<int> updateData({required String sql, List<Object?>? args}) async {
    final dbClient = await db;
    return dbClient.rawUpdate(sql, args);
  }

  Future<int> deleteData({required String sql, List<Object?>? args}) async {
    final dbClient = await db;
    return dbClient.rawDelete(sql, args);
  }

  Future<void> runBatch(Future<void> Function(Batch b) fn) async {
    final dbClient = await db;
    await dbClient.transaction((txn) async {
      final b = txn.batch();
      await fn(b);
      await b.commit(noResult: true);
    });
  }

  // ---------- cache meta helpers ----------

  Future<String?> getMeta(String key) async {
    final rows = await readData(
      sql: 'SELECT value FROM app_meta WHERE key = ?',
      args: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setMeta(String key, String value) async {
    await insertData(
      sql: 'INSERT OR REPLACE INTO app_meta(key, value) VALUES(?, ?)',
      args: [key, value],
    );
  }
}
