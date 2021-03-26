import 'package:stringee_flutter_plugin/src/messaging/MessagingConstants.dart';

import 'StringeeChange.dart';

class Message implements StringeeObject {
  Message();
  Message.initFromEvent(Map<dynamic, dynamic> msgInfor) {
    // if (msgInfor == null) {
    //   return;
    // }
    _id = msgInfor['id'];
    _convId = msgInfor['convId'];
    _senderId = msgInfor['senderId'];
    _createdAt = msgInfor['createAt'];
    _updateAt = msgInfor['updateAt'];
    _sequence = msgInfor['sequence'];
    _state = msgInfor['state'];
    _stateType = msgInfor['msgType'];
    _type = msgInfor['type'];
    _text = msgInfor['text'];
    _thumbnail = msgInfor['thumbnail'];
    _thumbnailUrl = msgInfor['thumbnailUrl'];
    _latitude = msgInfor['latitude'];
    _longitude = msgInfor['longitude'];
    _address = msgInfor['address'];
    _filePath = msgInfor['filePath'];
    _fileUrl = msgInfor['fileUrl'];
    _fileName = msgInfor['fileName'];
    _fileLength = msgInfor['fileLength'];
    _duration = msgInfor['duration'];
    _imageRatio = msgInfor['imageRatio'];
    _contact = msgInfor['contact'];
    _clientId = msgInfor['clientId'];
    _stickerCategory = msgInfor['stickerCategory'];
    _stickerName = msgInfor['stickerName'];
    _customData = msgInfor['customData'];
    _isDeleted = msgInfor['isDeleted'];
  }

  String? _id;
  String? _convId;
  String? _senderId;
  int? _createdAt;
  int? _updateAt;
  int? _sequence;
  MsgState? _state;
  MsgStateType? _stateType;
  MsgType? _type;
  String? _text;
  String? _thumbnail;
  String? _thumbnailUrl;
  double? _latitude;
  double? _longitude;
  String? _address;
  String? _filePath;
  String? _fileUrl;
  String? _fileName;
  int? _fileLength;
  int? _duration;
  int? _imageRatio;
  String? _contact;
  String? _clientId;
  String? _stickerCategory;
  String? _stickerName;
  String? _customData;
  bool? _isDeleted;

  String? get id => _id;

  String? get convId => _convId;

  String? get senderId => _senderId;

  int? get createdAt => _createdAt;

  int? get updateAt => _updateAt;

  int? get sequence => _sequence;

  MsgState? get state => _state;

  MsgStateType? get msgType => _stateType;

  MsgType? get type => _type;

  String? get text => _text;

  String? get thumbnail => _thumbnail;

  String? get thumbnailUrl => _thumbnailUrl;

  double? get latitude => _latitude;

  double? get longitude => _longitude;

  String? get address => _address;

  String? get filePath => _filePath;

  String? get fileUrl => _fileUrl;

  String? get fileName => _fileName;

  int? get fileLength => _fileLength;

  int? get duration => _duration;

  int? get imageRatio => _imageRatio;

  String? get contact => _contact;

  String? get clientId => _clientId;

  String? get stickerCategory => _stickerCategory;

  String? get stickerName => _stickerName;

  String? get customData => _customData;

  bool? get isDeleted => _isDeleted;
}
