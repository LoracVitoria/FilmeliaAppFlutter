import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import './filme.dart';

class DatabaseHelper {
  static const _dbName = 'filmesdb.db';
  static const _dbVersion = 1;

  //singleton
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    // if (_database == null) {
    //    _database = await _initDatabase();
    // }
    //versão curta:
    _database ??= await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), _dbName);

    return await openDatabase(dbPath,
        version: _dbVersion, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute(
        '''
      CREATE TABLE ${Filme.tableFilme}(
        ${Filme.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Filme.colNome} TEXT NOT NULL,
        ${Filme.colGenero} TEXT NOT NULL,
        ${Filme.colEstrelas} DOUBLE NOT NULL,
        ${Filme.colObservacoes} TEXT,
        ${Filme.colAnoLancamento} INTEGER NOT NULL,
        ${Filme.colImagem} TEXT NOT NULL)
      ''');
  }

  Future<int> inserirFilme(Filme filme) async {
    Database db = await database;
    return await db.insert(Filme.tableFilme, filme.toMap());
  }

  Future<int> atualizarFilme(Filme filme) async {
    Database db = await database;
    return await db.update(Filme.tableFilme, filme.toMap(),
        where: '${Filme.colId} = ?', whereArgs: [filme.id]);
  }

  Future<int> excluirFilme(int id) async {
    Database db = await database;
    return await db
        .delete(Filme.tableFilme, where: '${Filme.colId} = ?', whereArgs: [id]);
  }

  Future<List<Filme>> listarFilmes() async {
    Database db = await database;
    List<Map<String, dynamic>> filmes = await db.query(Filme.tableFilme);
    return filmes.isEmpty ? [] : filmes.map((e) => Filme.fromMap(e)).toList();
  }
}
