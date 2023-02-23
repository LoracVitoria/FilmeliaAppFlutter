import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_project/avaliar.dart';
import 'package:flutter_project/model/filme.dart';
import 'package:flutter_project/model/database_helper.dart';
import 'package:flutter_project/salvos.dart';
import 'package:flutter_project/visualizar.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'editar.dart';

class FilmeliaApp extends StatefulWidget {
  const FilmeliaApp({Key? key}) : super(key: key);

  @override
  State<FilmeliaApp> createState() => _FilmeliaAppState();
}

class _FilmeliaAppState extends State<FilmeliaApp> {
  Filme _filme = Filme();
  List<Filme> _filmes = [];
  DatabaseHelper _dbHelper = DatabaseHelper.instance;
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _nomeEC = TextEditingController();
  final _generoEC = TextEditingController();
  final _observacoesEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () => _atualizarListaFilmes());
    _atualizarListaFilmes();
  }

  _atualizarListaFilmes() async {
    List<Filme> c = await _dbHelper.listarFilmes();
    setState(() {
      _filmes = c;
    });
  }

  Future<void> _exibirParaEdicao(BuildContext context, Filme filme) async {
    final retorno = Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Editar(filme: filme)),
    );
  }

  Future<void> _exibirParaVisualizacao(
      BuildContext context, Filme filme) async {
    final retorno = Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Visualizar(filme: filme)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Center(
          child: Text(
            'Filmelia',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _listaFilmes(),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lime,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 50,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.reviews),
              title: const Text('Avaliar'),
              onTap: () {
                _abrirAvaliar(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Salvos'),
              onTap: () {
                _abrirSalvos(context);
              },
            ),
            const AboutListTile(
              // <-- SEE HERE
              icon: Icon(
                Icons.info,
              ),
              child: Text('Sobre'),
              applicationIcon: Icon(
                Icons.local_play,
              ),
              applicationName: 'Filmelia App',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2023 Caroline',
              aboutBoxChildren: [
                ///Content goes here...
              ],
            ),
          ],
        ),
      ),
    );
  }

  _listaFilmes() {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              // Then show a snackbar.
              return Dismissible(
                // Each Dismissible must contain a Key. Keys allow Flutter to
                // uniquely identify widgets.
                key: UniqueKey(),
                // Provide a function that tells the app
                // what to do after an item has been swiped away.
                onDismissed: (direction) {
                  // Remove the item from the data source.
                  setState(() {
                    _exibirParaEdicao(context, _filmes[index]);
                  });
                },
                // Show a red background as the item is swiped away.
                background: Container(color: Colors.lime),
                child: ListTile(
                  leading: CircleAvatar(
                      radius: 40,
                      backgroundImage: File(_filmes[index].imagem) != null
                          ? FileImage(File(_filmes[index].imagem))
                              as ImageProvider
                          : const NetworkImage(
                              'https://img.freepik.com/vetores-gratis/3d-ilustracao-realistica-do-clapperboard-ou-do-badalo-do-filme-aberto-isolado-no-fundo_1441-1783.jpg?w=740&t=st=1677118980~exp=1677119580~hmac=2e225e7bc2e5ee9107a5f2279013f22807427fa640197fae455a9c478999a349') // No matter how big it is, it won't overflow

                      ),
                  title: Text(
                    _filmes[index].nome.toUpperCase(),
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_filmes[index].genero),
                  onTap: () {
                    _exibirParaVisualizacao(context, _filmes[index]);
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Excluir o filme?'),
                          content: Text(_filmes[index].nome),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _dbHelper.excluirFilme(_filmes[index].id);
                                _atualizarListaFilmes();
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            )
                          ],
                        );
                      },
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.movie_edit, color: Colors.grey.shade600),
                    onPressed: () {
                      _exibirParaEdicao(context, _filmes[index]);
                    },
                  ),
                ),
              );
            },
            itemCount: _filmes.length,
          ),
        ),
      ),
    );
  }
}

Future<void> _abrirAvaliar(BuildContext context) async {
  final retorno = Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Avaliar()),
  );
}

Future<void> _abrirSalvos(BuildContext context) async {
  final retorno = Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Salvos()),
  );
}
