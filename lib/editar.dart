import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_project/salvos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'model/database_helper.dart';
import 'model/filme.dart';

class Editar extends StatefulWidget {
  const Editar({super.key, required this.filme});

  final Filme filme;

  @override
  State<StatefulWidget> createState() => _Editar();
}

class _Editar extends State<Editar> {
  List<Filme> _filmes = [];
  DatabaseHelper _dbHelper = DatabaseHelper.instance;

  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _nomeEC = TextEditingController();
  final _generoEC = TextEditingController();
  final _observacoesEC = TextEditingController();
  final _anoLancamentoEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setarCampos(widget.filme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Center(
          child: Text(
            'Editar Filmes',
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

  _setarCampos(index) {
    setState(() {
      _nomeEC.text = widget.filme.nome;
      _generoEC.text = widget.filme.genero;
      widget.filme.estrelas = widget.filme.estrelas;
      _observacoesEC.text = widget.filme.observacoes;
      _anoLancamentoEC.text = widget.filme.anoLancamento.toString();
      _image = File(widget.filme.imagem);
    });
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
              widget.filme.nome = value!;
            }),
          ),
          const SizedBox(
            height: 15,
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
              widget.filme.genero = value!;
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
                rating: widget.filme.estrelas,
                onRated: (v) {
                  setState(() {
                    widget.filme.estrelas = v;
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
              widget.filme.anoLancamento = int.parse(value!);
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
              widget.filme.observacoes = value!;
            }),
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null ||
                            widget.filme.imagem.isEmpty
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
                      widget.filme.imagem = _image!.path;
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
      await _dbHelper.atualizarFilme(widget.filme);
      _abrirSalvos(context);
    }
    print('''
        Nome : ${widget.filme.nome}
        Genêro : ${widget.filme.genero}
        Estrelas: ${widget.filme.estrelas}
        Observações: ${widget.filme.observacoes}
        Ano Lancamento: ${widget.filme.anoLancamento}''');
    //chamar a home
    // _resetForm();
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
      widget.filme.imagem = image.path;
    });
  }
}
