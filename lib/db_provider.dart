import 'dart:io';

import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  // Create a singleton
  DBProvider._();

  static final DBProvider db = DBProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDB();
    return _database;
  }

  _initDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'app.db');

    return await openDatabase(path, version: 1, onOpen: (db) async {},
        onConfigure: (Database db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: (Database db, int version) async {
      await db.execute('''
                CREATE TABLE competition(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL
                );
            ''');
      await db.execute('''
                CREATE TABLE competitor(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    competitionId INTEGER,
                    FOREIGN KEY (competitionId) REFERENCES competition(id) ON DELETE CASCADE ON UPDATE NO ACTION
                );
      ''');
      await db.execute('''
                CREATE TABLE match(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    competitionId INTEGER,
                    homeCompetitor INTEGER,
                    awayCompetitor INTEGER,
                    winner INTEGER,
                    winnerPoints INTEGER,
                    loserPoints INTEGER,
                    FOREIGN KEY (competitionId) REFERENCES competition(id) ON DELETE CASCADE ON UPDATE NO ACTION,
                    FOREIGN KEY (homeCompetitor) REFERENCES competitor(id) ON DELETE CASCADE ON UPDATE NO ACTION,
                    FOREIGN KEY (awayCompetitor) REFERENCES competitor(id) ON DELETE CASCADE ON UPDATE NO ACTION,
                    FOREIGN KEY (winner) REFERENCES competitor(id) ON DELETE CASCADE ON UPDATE NO ACTION
                );
      ''');
    });
  }

  /// CRUD - Competitions

  Future<List<Competition>> findCompetitions() async {
    final db = await database;
    var res = await db.query('competition');
    List<Competition> competitions = res.isNotEmpty
        ? res.map((competition) => Competition.fromJson(competition)).toList()
        : [];
    return competitions;
  }

  Future<Competition> findCompetition(int id) async {
    final db = await database;
    var res = await db.query('competition', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? Competition.fromJson(res.first) : null;
  }

  Future<int> insertCompetition(Competition competition) async {
    final db = await database;
    var competitionRes = await db.insert('competition', competition.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return competitionRes;
  }

  Future<int> deleteCompetition(int competitionId) async {
    final db = await database;
    final res = await db.delete('competition', where: 'id = ?', whereArgs: [competitionId]);
    return res;
  }

  ///CRUD - Competitors

  Future<Competitor> findCompetitor(int competitorId) async {
    final db = await database;
    var res = await db
        .query('competitor', where: 'id = ?', whereArgs: [competitorId]);

    return res.isNotEmpty ? Competitor.fromJson(res.first) : null;
  }

  Future<List<Competitor>> findCompetitors(int competitionId) async {
    final db = await database;
    var res = await db.query('competitor',
        where: 'competitionId = ?', whereArgs: [competitionId]);
    List<Competitor> competitors = res.isNotEmpty
        ? res.map((competitor) => Competitor.fromJson(competitor)).toList()
        : [];
    return competitors;
  }

  Future<int> insertCompetitor(Competitor competitor) async {
    final db = await database;
    var res = await db.insert('competitor', competitor.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<int>> insertCompetitors(
      int competitionId, List<Competitor> competitors) async {
    //add competitors for competition
    final competitorIds = await Future.wait(competitors.map((competitor) async {
      competitor.competitionId = competitionId;
      return await insertCompetitor(competitor);
    }));
    return competitorIds;
  }

  ///CRUD - Matches

  Future<List<int>> insertMatches(List<Match> matches) async {
    final matchIds = await Future.wait(matches.map((match) async {
      return await insertMatch(match);
    }));
    return matchIds;
  }

  Future<int> insertMatch(Match match) async {
    final db = await database;
    var res = await db.insert('match', match.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<Match>> findMatches(int competitionId) async {
    final db = await database;
    var res = await db
        .query('match', where: 'competitionId = ?', whereArgs: [competitionId]);
    List<Match> matches = res.isNotEmpty
        ? res.map((match) => Match.fromJson(match)).toList()
        : [];
    return matches;
  }

  Future<List<Match>> findUnfinishedMatches(int competitionId) async {
    final db = await database;
    var res = await db.query('match',
        where: 'competitionId = ? AND winner is NULL',
        whereArgs: [competitionId]);
    List<Match> matches = res.isNotEmpty
        ? res.map((match) => Match.fromJson(match)).toList()
        : [];
    return matches;
  }

  Future<List<Match>> findFinishedMatches(int competitionId) async {
    final db = await database;
    var res = await db.query('match',
        where: 'competitionId = ? AND winner IS NOT NULL',
        whereArgs: [competitionId]);
    List<Match> matches = res.isNotEmpty
        ? res.map((match) => Match.fromJson(match)).toList()
        : [];
    return matches;
  }
}
