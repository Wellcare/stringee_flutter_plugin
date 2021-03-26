import 'dart:convert';

import 'package:stringee_flutter_plugin/src/StringeeClient.dart';
import 'package:stringee_flutter_plugin/src/messaging/MessagingConstants.dart';

import 'StringeeChange.dart';
import 'User.dart';

class Conversation implements StringeeObject {
  Conversation();

  Conversation.initFromEvent(Map<dynamic, dynamic> convInfor) {
    _id = convInfor['id'];
    _localId = convInfor['localId'];
    _name = convInfor['name'];
    _isDistinct = convInfor['isDistinct'];
    _isGroup = convInfor['isGroup'];
    _isEnded = convInfor['isEnded'];
    _clientId = convInfor['clientId'];
    _creator = convInfor['creator'];
    _createAt = convInfor['createAt'];
    _updateAt = convInfor['updateAt'];
    _totalUnread = convInfor['totalUnread'];
    _text = convInfor['text'];
    _state = ConvState.values[convInfor['state']];
    _lastMsgSender = convInfor['lastMsgSender'];
    _lastMsgType = (convInfor['lastMsgType'] as int).msgType;
    _lastMsgId = convInfor['lastMsgId'];
    _lastMsgSeqReceived = convInfor['lastMsgSeqReceived'];
    _lastTimeNewMsg = convInfor['lastTimeNewMsg'];
    _lastMsgState = MsgState.values[convInfor['lastMsgState']];
    _lastMsg = LastMsg(convInfor['lastMsg']);
    _pinnedMsgId = convInfor['pinnedMsgId'];

    final List<StringeeUser> participants = <StringeeUser>[];
    final List<dynamic> participantArray =
        json.decode(convInfor['participants']);
    for (int i = 0; i < participantArray.length; i++) {
      final StringeeUser user = StringeeUser.fromJson(participantArray[i]);
      participants.add(user);
    }
    _participants = participants;
  }

  String? _id;
  String? _localId;
  String? _name;
  bool? _isDistinct;
  bool? _isGroup;
  bool? _isEnded;
  String? _clientId;
  String? _creator;
  int? _createAt;
  int? _updateAt;
  int? _totalUnread;
  String? _text;
  ConvState? _state;
  String? _lastMsgSender;
  MsgType? _lastMsgType;
  String? _lastMsgId;
  int? _lastMsgSeqReceived;
  int? _lastTimeNewMsg;
  MsgState? _lastMsgState;
  LastMsg? _lastMsg;
  String? _pinnedMsgId;
  List<StringeeUser>? _participants;

  String? get id => _id;

  String? get localId => _localId;

  String? get name => _name;

  bool? get isDistinct => _isDistinct;

  bool? get isGroup => _isGroup;

  bool? get isEnded => _isEnded;

  String? get clientId => _clientId;

  String? get creator => _creator;

  int? get createAt => _createAt;

  int? get updateAt => _updateAt;

  int? get totalUnread => _totalUnread;

  String? get text => _text;

  ConvState? get state => _state;

  String? get lastMsgSender => _lastMsgSender;

  MsgType? get lastMsgType => _lastMsgType;

  String? get lastMsgId => _lastMsgId;

  int? get lastMsgSeqReceived => _lastMsgSeqReceived;

  int? get lastTimeNewMsg => _lastTimeNewMsg;

  MsgState? get lastMsgState => _lastMsgState;

  LastMsg? get lastMsg => _lastMsg;

  String? get pinnedMsgId => _pinnedMsgId;

  List<StringeeUser>? get participants => _participants;

  Future<Map<dynamic, dynamic>> delete(String clientId) async {
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('delete', clientId);
  }
}

class LastMsg {
  LastMsg(Map<dynamic, dynamic> lastMsgInfor) {
    messageType = lastMsgInfor['messageType'];
    text = lastMsgInfor['text'];
    content = lastMsgInfor['content'];
  }
  int? messageType;
  String? text;
  String? content;
}
