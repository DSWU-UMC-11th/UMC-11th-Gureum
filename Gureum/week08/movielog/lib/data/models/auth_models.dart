class LoginResult {
  const LoginResult({required this.nickname, required this.accessToken});
  final String nickname;
  final String accessToken;

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    nickname: json['nickname'] as String,
    accessToken: json['accessToken'] as String,
  );
}

class MemberProfile {
  const MemberProfile({
    required this.email,
    required this.nickname,
    required this.createdAt,
  });
  final String email;
  final String nickname;
  final DateTime createdAt;

  factory MemberProfile.fromJson(Map<String, dynamic> json) => MemberProfile(
    email: json['email'] as String,
    nickname: json['nickname'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
