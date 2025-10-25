/*
Login class to hold user credentials
*/
class Login {
  String username; // "VELOCITY",
  String password; // "JPY920",

  Login(this.username, this.password);

  factory Login.fromJson(dynamic json) {
    return Login(json['username'] as String, json['password'] as String);
  }

  @override
  String toString() {
    return '{ $username, $password }';
  }
}
