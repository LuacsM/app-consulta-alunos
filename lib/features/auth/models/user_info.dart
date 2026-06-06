class UserInfo {
  const UserInfo({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    required this.nivelAcesso,
  });

  final int id;
  final String nomeCompleto;
  final String email;
  final String nivelAcesso;

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      nomeCompleto: json['nome_completo'] as String,
      email: json['email'] as String,
      nivelAcesso: json['nivel_acesso'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome_completo': nomeCompleto,
        'email': email,
        'nivel_acesso': nivelAcesso,
      };
}
