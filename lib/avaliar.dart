import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_project/salvos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'filmelia_app.dart';
import 'model/database_helper.dart';
import 'model/filme.dart';

class Avaliar extends StatefulWidget {
  const Avaliar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Avaliar();
}

class _Avaliar extends State<Avaliar> {
  Filme _filme = Filme();
  List<Filme> _filmes = [];
  DatabaseHelper _dbHelper = DatabaseHelper.instance;

  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _nomeEC = TextEditingController();
  final _generoEC = TextEditingController();
  final _observacoesEC = TextEditingController();
  final _anoLancamentoEC = TextEditingController();
  final _imagemEC = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Center(
          child: Text(
            'Avaliar Filmes',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _form(),
            ],
          ),
        ),
      ),
    );
  }

  _form() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _nomeEC,
            decoration: const InputDecoration(labelText: 'Nome:'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
            onSaved: (value) => setState(() {
              _filme.nome = value!;
            }),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: _generoEC,
            decoration: const InputDecoration(labelText: 'Genêro:'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
            onSaved: (value) => setState(() {
              _filme.genero = value!;
            }),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Avaliação:',
              style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
            ),
            SmoothStarRating(
                isReadOnly: false,
                allowHalfRating: true,
                rating: _filme.estrelas,
                onRated: (v) {
                  setState(() {
                    _filme.estrelas = v;
                  });
                },
                starCount: 5,
                size: 40.0,
                color: Colors.yellow.shade600,
                borderColor: Colors.grey,
                spacing: 0.0),
          ]),
          const SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: _anoLancamentoEC,
            decoration: const InputDecoration(labelText: "Ano de Lançamento:"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty || int.parse(value) == 0) {
                return 'Campo obrigatório';
              } else if (int.parse(value) < 1895 || int.parse(value) > 2023) {
                return 'Insira um ano válido';
              } else {
                return null;
              }
            },
            onSaved: (value) => setState(() {
              _filme.anoLancamento = int.parse(value!);
            }),
          ),
          const SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: _observacoesEC,
            decoration: const InputDecoration(labelText: 'Observações:'),
            maxLines: 3,
            onSaved: (value) => setState(() {
              _filme.observacoes = value!;
            }),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider
                        : const NetworkImage(
                            'https://img.freepik.com/vetores-gratis/3d-ilustracao-realistica-do-clapperboard-ou-do-badalo-do-filme-aberto-isolado-no-fundo_1441-1783.jpg?w=740&t=st=1677118980~exp=1677119580~hmac=2e225e7bc2e5ee9107a5f2279013f22807427fa640197fae455a9c478999a349') // No matter how big it is, it won't overflow
                    ),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate),
                  color: Colors.grey.shade600,
                  iconSize: 48,
                  tooltip: 'Adicione uma imagem',
                  onPressed: () {
                    setState(() {
                      pickimage();
                    });
                  },
                ),
              ]),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
            onPressed: () {
              _onSubmit();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.lime, // Background color
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ]),
      ),
    );
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form?.validate() ?? false) {
      form!.save();
      await _dbHelper.inserirFilme(_filme);
      _abrirSalvos(context);

      print('''
        Nome : ${_filme.nome}
        Genêro : ${_filme.genero}
        Estrelas: ${_filme.estrelas}
        Observações: ${_filme.observacoes}
        Ano Lancamento: $_filme.anoLancamento]
        Imagem: ${_filme.imagem}

        ''');
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _nomeEC.clear();
      _generoEC.clear();
      _observacoesEC.clear();
      _filme.estrelas = 0.0;
      _filme.id = 0;
      _anoLancamentoEC.clear();
      _image = null;
    });
  }

  Future<void> _abrirSalvos(BuildContext context) async {
    final retorno = Navigator.pop(context);

    final retorno2 = Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Salvos()),
    );
  }

  void pickimage() async {
    var image =
        await ImagePicker.platform.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
      _filme.imagem = image.path;
    });
  }
}
