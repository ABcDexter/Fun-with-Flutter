class AuthUser {
  String username; // "VELOCITY",
  String environment; // "JPY920",
  String role; // "*ALL",
  String jasserver; // "http://c1y76088.ora.vtscloud.io:3001",

  AuthUser(this.username, this.environment, this.role, this.jasserver);

  factory AuthUser.fromJson(dynamic json) {
    return AuthUser(json['username'] as String, json['environment'] as String,
        json['role'] as String, json['jassserver'] as String);
  }

  @override
  String toString() {
    return '{ $username, $environment, $role, $jasserver }';
  }
}
