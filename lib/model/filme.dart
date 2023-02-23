import 'dart:ffi';

class Filme {
  int id;
  String nome;
  String genero;
  double estrelas;
  String observacoes;
  int anoLancamento;
  String imagem;

  Filme({
    this.id = 0,
    this.nome = '',
    this.genero = '',
    this.estrelas = 0.0,
    this.observacoes = '',
    this.anoLancamento = 0,
    this.imagem = '',
  });

  static const tableFilme = 'tb_filmes';
  static const colId = 'id';
  static const colNome = 'nome';
  static const colGenero = 'genero';
  static const colEstrelas = 'estrelas';
  static const colObservacoes = 'observacoes';
  static const colAnoLancamento = 'anoLancamento';
  static const colImagem = 'imagem';

  factory Filme.fromMap(Map<String, dynamic> map) {
    return Filme(
      id: map[colId],
      nome: map[colNome],
      genero: map[colGenero],
      estrelas: map[colEstrelas],
      observacoes: map[colObservacoes],
      anoLancamento: map[colAnoLancamento],
      imagem: map[colImagem],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colNome: nome,
      colGenero: genero,
      colEstrelas: estrelas,
      colObservacoes: observacoes,
      colAnoLancamento: anoLancamento,
      colImagem: imagem,
    };
    if (map[colId] != null) {
      map[colId] = id;
    }
    return map;
  }
}
