import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'model/database_helper.dart';
import 'model/filme.dart';

class Visualizar extends StatefulWidget {
  const Visualizar({super.key, required this.filme});

  final Filme filme;

  @override
  State<StatefulWidget> createState() => _Visualizar();
}

class _Visualizar extends State<Visualizar> {
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
            'Visualizar Filmes',
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
          CircleAvatar(
              radius: 60,
              backgroundImage: _image != null
                  ? FileImage(_image!) as ImageProvider
                  : const NetworkImage(
                      'https://img.freepik.com/vetores-gratis/3d-ilustracao-realistica-do-clapperboard-ou-do-badalo-do-filme-aberto-isolado-no-fundo_1441-1783.jpg?w=740&t=st=1677118980~exp=1677119580~hmac=2e225e7bc2e5ee9107a5f2279013f22807427fa640197fae455a9c478999a349') // No matter how big it is, it won't overflow
              ),
          TextFormField(
            enabled: false,
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
            enabled: false,
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
                isReadOnly: true,
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
            enabled: false,
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
            onSaved: (value) => setState(() {}),
          ),
          const SizedBox(
            height: 15,
          ),
          TextFormField(
            enabled: false,
            controller: _observacoesEC,
            decoration: const InputDecoration(labelText: 'Observações:'),
            maxLines: 3,
            onSaved: (value) => setState(() {}),
          ),
          const SizedBox(
            height: 25,
          ),
        ]),
      ),
    );
  }
}
