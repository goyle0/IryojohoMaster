import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iryojoho_master/domain/entities/question.dart';
import 'package:iryojoho_master/domain/entities/study_progress.dart';
import 'package:iryojoho_master/data/models/question_model.dart';
import 'package:iryojoho_master/data/models/answer_model.dart';
import 'package:iryojoho_master/data/models/study_progress_model.dart';

class SyncItem {
  final String itemId;
  final String tableName;
  final DateTime createdAt;

  SyncItem({
    required this.itemId,
    required this.tableName,
    required this.createdAt,
  });
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('iryojoho_master.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        sub_category TEXT NOT NULL,
        text TEXT NOT NULL,
        explanation TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE answers (
        id TEXT PRIMARY KEY,
        question_id TEXT NOT NULL,
        text TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE study_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        attempt_count INTEGER NOT NULL,
        last_attempt_at TEXT NOT NULL,
        confidence_score REAL,
        UNIQUE(user_id, question_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,
        table_name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // 問題関連のメソッド
  Future<List<Question>> getQuestions({String? category, String? subCategory}) async {
    final db = await database;
    
    var query = 'SELECT * FROM questions';
    List<dynamic> args = [];
    
    if (category != null) {
      query += ' WHERE category = ?';
      args.add(category);
      
      if (subCategory != null) {
        query += ' AND sub_category = ?';
        args.add(subCategory);
      }
    }
    
    final questionsData = await db.rawQuery(query, args);
    List<Question> questions = [];
    
    for (final questionData in questionsData) {
      final answersData = await db.query(
        'answers',
        where: 'question_id = ?',
        whereArgs: [questionData['id']],
        orderBy: 'order_index ASC',
      );
      
      final answers = answersData.map((data) => AnswerModel(
        id: data['id'] as String,
        questionId: data['question_id'] as String,
        text: data['text'] as String,
        isCorrect: data['is_correct'] == 1,
        orderIndex: data['order_index'] as int,
      )).toList();
      
      questions.add(QuestionModel(
        id: questionData['id'] as String,
        category: questionData['category'] as String,
        subCategory: questionData['sub_category'] as String,
        text: questionData['text'] as String,
        answers: answers,
        explanation: questionData['explanation'] as String,
        difficulty: questionData['difficulty'] as int,
        imageUrl: questionData['image_url'] as String?,
      ));
    }
    
    return questions;
  }

  Future<Question?> getQuestionById(String id) async {
    final db = await database;
    
    final questionData = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (questionData.isEmpty) {
      return null;
    }
    
    final answersData = await db.query(
      'answers',
      where: 'question_id = ?',
      whereArgs: [id],
      orderBy: 'order_index ASC',
    );
    
    final answers = answersData.map((data) => AnswerModel(
      id: data['id'] as String,
      questionId: data['question_id'] as String,
      text: data['text'] as String,
      isCorrect: data['is_correct'] == 1,
      orderIndex: data['order_index'] as int,
    )).toList();
    
    return QuestionModel(
      id: questionData.first['id'] as String,
      category: questionData.first['category'] as String,
      subCategory: questionData.first['sub_category'] as String,
      text: questionData.first['text'] as String,
      answers: answers,
      explanation: questionData.first['explanation'] as String,
      difficulty: questionData.first['difficulty'] as int,
      imageUrl: questionData.first['image_url'] as String?,
    );
  }

  Future<void> saveQuestion(Question question) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // 問題の挿入または更新
      await txn.insert(
        'questions',
        {
          'id': question.id,
          'category': question.category,
          'sub_category': question.subCategory,
          'text': question.text,
          'explanation': question.explanation,
          'difficulty': question.difficulty,
          'image_url': question.imageUrl,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // 既存の回答を削除
      await txn.delete(
        'answers',
        where: 'question_id = ?',
        whereArgs: [question.id],
      );
      
      // 新しい回答を挿入
      for (final answer in question.answers) {
        await txn.insert(
          'answers',
          {
            'id': answer.id,
            'question_id': answer.questionId,
            'text': answer.text,
            'is_correct': answer.isCorrect ? 1 : 0,
            'order_index': answer.orderIndex,
          },
        );
      }
    });
  }

  // 学習進捗関連のメソッド
  Future<List<StudyProgress>> getUserProgress(String userId) async {
    final db = await database;
    
    final progressData = await db.query(
      'study_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    return progressData.map((data) => StudyProgressModel(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      questionId: data['question_id'] as String,
      isCorrect: data['is_correct'] == 1,
      attemptCount: data['attempt_count'] as int,
      lastAttemptAt: DateTime.parse(data['last_attempt_at'] as String),
      confidenceScore: data['confidence_score'] as double?,
    )).toList();
  }

  Future<StudyProgress?> getProgressByUserAndQuestion(
    String userId,
    String questionId,
  ) async {
    final db = await database;
    
    final progressData = await db.query(
      'study_progress',
      where: 'user_id = ? AND question_id = ?',
      whereArgs: [userId, questionId],
    );
    
    if (progressData.isEmpty) {
      return null;
    }
    
    return StudyProgressModel(
      id: progressData.first['id'] as String,
      userId: progressData.first['user_id'] as String,
      questionId: progressData.first['question_id'] as String,
      isCorrect: progressData.first['is_correct'] == 1,
      attemptCount: progressData.first['attempt_count'] as int,
      lastAttemptAt: DateTime.parse(progressData.first['last_attempt_at'] as String),
      confidenceScore: progressData.first['confidence_score'] as double?,
    );
  }

  Future<StudyProgress?> getProgressById(String id) async {
    final db = await database;
    
    final progressData = await db.query(
      'study_progress',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (progressData.isEmpty) {
      return null;
    }
    
    return StudyProgressModel(
      id: progressData.first['id'] as String,
      userId: progressData.first['user_id'] as String,
      questionId: progressData.first['question_id'] as String,
      isCorrect: progressData.first['is_correct'] == 1,
      attemptCount: progressData.first['attempt_count'] as int,
      lastAttemptAt: DateTime.parse(progressData.first['last_attempt_at'] as String),
      confidenceScore: progressData.first['confidence_score'] as double?,
    );
  }

  Future<void> saveProgress(StudyProgress progress) async {
    final db = await database;
    
    await db.insert(
      'study_progress',
      {
        'id': progress.id,
        'user_id': progress.userId,
        'question_id': progress.questionId,
        'is_correct': progress.isCorrect ? 1 : 0,
        'attempt_count': progress.attemptCount,
        'last_attempt_at': progress.lastAttemptAt.toIso8601String(),
        'confidence_score': progress.confidenceScore,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 同期関連のメソッド
  Future<void> markForSync(String itemId, String tableName) async {
    final db = await database;
    
    await db.insert(
      'sync_queue',
      {
        'item_id': itemId,
        'table_name': tableName,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<SyncItem>> getPendingSyncs(String tableName) async {
    final db = await database;
    
    final syncsData = await db.query(
      'sync_queue',
      where: 'table_name = ?',
      whereArgs: [tableName],
    );
    
    return syncsData.map((data) => SyncItem(
      itemId: data['item_id'] as String,
      tableName: data['table_name'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
    )).toList();
  }

  Future<void> clearSyncFlag(String itemId, String tableName) async {
    final db = await database;
    
    await db.delete(
      'sync_queue',
      where: 'item_id = ? AND table_name = ?',
      whereArgs: [itemId, tableName],
    );
  }

  // 設定関連のメソッド
  Future<DateTime?> getLastSyncTimestamp() async {
    final db = await database;
    
    final settingsData = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['last_sync_timestamp'],
    );
    
    if (settingsData.isEmpty) {
      return null;
    }
    
    return DateTime.parse(settingsData.first['value'] as String);
  }

  Future<void> updateLastSyncTimestamp(DateTime timestamp) async {
    final db = await database;
    
    await db.insert(
      'app_settings',
      {
        'key': 'last_sync_timestamp',
        'value': timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

