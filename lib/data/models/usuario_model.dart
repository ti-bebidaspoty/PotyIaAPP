class UsuarioModel {
  final String usuarioId;
  final String nome;

  const UsuarioModel({
    required this.usuarioId,
    required this.nome,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      usuarioId: json['UsuarioID']?.toString() ?? '',
      nome: json['Nome']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UsuarioID': usuarioId,
      'Nome': nome,
    };
  }
}