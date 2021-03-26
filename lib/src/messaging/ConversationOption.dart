class ConversationOption {
  ConversationOption(
    this._name,
    this._isGroup,
    this._isDistinct,
  );
  final String _name;
  final bool _isGroup;
  final bool _isDistinct;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': _name,
      'isGroup': _isGroup,
      'isDistinct': _isDistinct,
    };
  }
}
