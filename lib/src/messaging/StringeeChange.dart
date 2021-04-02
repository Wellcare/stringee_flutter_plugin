import '../StringeeConstants.dart';
import 'Conversation.dart';
import 'Message.dart';

class StringeeObject {}

class StringeeChange {
  StringeeChange(ChangeType type, StringeeObject object) {
    _type = type;
    _object = object;
    _objectType = getType(object);
  }

  ChangeType? _type;
  ObjectType? _objectType;
  StringeeObject? _object;

  StringeeObject? get object => _object;

  ObjectType? get objectType => _objectType;

  ChangeType? get changeType => _type;

  ObjectType getType(StringeeObject object) {
    if (object is Conversation) {
      return ObjectType.conversation;
    } else if (object is Message) {
      return ObjectType.message;
    } else {
      throw ArgumentError('Invalid object type: $object');
    }
  }
}
