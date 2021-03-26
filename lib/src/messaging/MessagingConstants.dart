///Chat object type
enum ObjectType {
  CONVERSATION,
  MESSAGE,
}

///Chat change type
enum ChangeType {
  INSERT,
  UPDATE,
  DELETE,
}

///Conversation state
enum ConvState {
  STATE_DEFAULT,
  STATE_LEFT,
}

enum MsgState {
  INITIALIZE,
  SENDING,
  SENT,
  DELIVERED,
  READ,
}

enum MsgStateType {
  TYPE_SEND,
  TYPE_RECEIVE,
}

enum MsgType {
  TYPE_TEXT,
  TYPE_PHOTO,
  TYPE_VIDEO,
  TYPE_AUDIO,
  TYPE_FILE,
  TYPE_LINK,
  TYPE_CREATE_CONVERSATION,
  TYPE_RENAME_CONVERSATION,
  TYPE_LOCATION,
  TYPE_CONTACT,
  TYPE_STICKER,
  TYPE_NOTIFICATION,
  TYPE_TEMP_DATE,
}

extension MsgTypeValueExtension on MsgType {
  // ignore: missing_return
  int get value {
    switch (this) {
      case MsgType.TYPE_TEXT:
        return 1;
      case MsgType.TYPE_PHOTO:
        return 2;
      case MsgType.TYPE_VIDEO:
        return 3;
      case MsgType.TYPE_AUDIO:
        return 4;
      case MsgType.TYPE_FILE:
        return 5;
      case MsgType.TYPE_LINK:
        return 6;
      case MsgType.TYPE_CREATE_CONVERSATION:
        return 7;
      case MsgType.TYPE_RENAME_CONVERSATION:
        return 8;
      case MsgType.TYPE_LOCATION:
        return 9;
      case MsgType.TYPE_CONTACT:
        return 10;
      case MsgType.TYPE_STICKER:
        return 11;
      case MsgType.TYPE_NOTIFICATION:
        return 100;
      case MsgType.TYPE_TEMP_DATE:
        return 1000;
    }
  }
}

extension MsgTypeExtension on int {
  // ignore: missing_return
  MsgType? get msgType {
    switch (this) {
      case 1:
        return MsgType.TYPE_TEXT;
      case 2:
        return MsgType.TYPE_PHOTO;
      case 3:
        return MsgType.TYPE_VIDEO;
      case 4:
        return MsgType.TYPE_AUDIO;
      case 5:
        return MsgType.TYPE_FILE;
      case 6:
        return MsgType.TYPE_LINK;
      case 7:
        return MsgType.TYPE_CREATE_CONVERSATION;
      // case 6:
      //   return MsgType.TYPE_RENAME_CONVERSATION;
      // case 7:
      //   return MsgType.TYPE_LOCATION;
      case 10:
        return MsgType.TYPE_CONTACT;
      case 11:
        return MsgType.TYPE_STICKER;
      case 100:
        return MsgType.TYPE_NOTIFICATION;
      case 1000:
        return MsgType.TYPE_TEMP_DATE;
    }
  }
}
