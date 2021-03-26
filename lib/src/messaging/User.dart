class StringeeUser {
  StringeeUser(
    this._userId,
    this._name,
    this._avatarUrl,
  );

  StringeeUser.fromJson(Map<dynamic, dynamic> json) {
    _userId = json['userId'];
    _name = json['name'];
    _avatarUrl = json['avatarUrl'];
  }

  String? _userId;
  String? _name;
  String? _avatarUrl;

  String? get userId => _userId;

  String? get name => _name;

  String? get avatarUrl => _avatarUrl;

  Map<String, dynamic> toJson() {
    return <String, String?>{
      'userId': _userId,
      'name': _name,
      'avatarUrl': _avatarUrl,
    };
  }
}
