import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_project/visualizar.dart';

import 'editar.dart';
import 'model/database_helper.dart';
import 'model/filme.dart';

class Salvos extends StatefulWidget {
  const Salvos({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Salvos();
}

class _Salvos extends State<Salvos> {
  Filme _filme = Filme();
  List<Filme> _filmes = [];
  DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final _formKey = GlobalKey<FormState>();
  final _nomeEC = TextEditingController();
  final _generoEC = TextEditingController();
  final _observacoesEC = TextEditingController();
  final _anoLancamentoEC = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            'Filmes salvos',
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
                      backgroundImage: File(_filmes[index].imagem) != null ||
                              _filmes[index].imagem == ''
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
