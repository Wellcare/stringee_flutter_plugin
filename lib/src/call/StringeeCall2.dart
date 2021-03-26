import 'dart:async';
import 'dart:io';
import '../StringeeClient.dart';
import '../StringeeConstants.dart';

class StringeeCall2 {
  StringeeCall2() {
    _subscriber =
        StringeeClient().eventStreamController.stream.listen(_listener);
  }

  StringeeCall2.fromCallInfo(Map<dynamic, dynamic> info) {
    initCallInfo(info);
    _subscriber =
        StringeeClient().eventStreamController.stream.listen(_listener);
  }

  String? _id;
  String? _from;
  String? _to;
  String? _fromAlias;
  String? _toAlias;
  StringeeCallType? _callType;
  String? _customDataFromYourServer;
  bool _isVideocall = false;
  final StreamController<dynamic> _eventStreamController =
      StreamController<dynamic>();
  StreamSubscription<dynamic>? _subscriber;

  String? get id => _id;

  String? get from => _from;

  String? get to => _to;

  String? get fromAlias => _fromAlias;

  String? get toAlias => _toAlias;

  bool get isVideocall => _isVideocall;

  StringeeCallType? get callType => _callType;

  String? get customDataFromYourServer => _customDataFromYourServer;

  StreamController<dynamic> get eventStreamController => _eventStreamController;

  void initCallInfo(Map<dynamic, dynamic> callInfo) {
    _id = callInfo['callId'];
    _from = callInfo['from'];
    _to = callInfo['to'];
    _fromAlias = callInfo['fromAlias'];
    _toAlias = callInfo['toAlias'];
    _isVideocall = callInfo['isVideoCall'];
    _customDataFromYourServer = callInfo['customDataFromYourServer'];
    _callType = StringeeCallType.values[callInfo['callType']];
  }

  void _listener(dynamic event) {
    assert(event != null);
    final Map<dynamic, dynamic> map = event;
    if (map['typeEvent'] == StringeeType.StringeeCall2.index) {
      switch (map['event']) {
        case 'didChangeSignalingState':
          handleSignalingStateChange(map['body']);
          break;
        case 'didChangeMediaState':
          handleMediaStateChange(map['body']);
          break;
        case 'didReceiveCallInfo':
          handleCallInfoDidReceive(map['body']);
          break;
        case 'didHandleOnAnotherDevice':
          handleAnotherDeviceHadHandle(map['body']);
          break;
        case 'didReceiveLocalStream':
          handleReceiveLocalStream(map['body']);
          break;
        case 'didReceiveRemoteStream':
          handleReceiveRemoteStream(map['body']);
          break;
        case 'didChangeAudioDevice':
          handleChangeAudioDevice(map['body']);
          break;
      }
    } else {
      eventStreamController.add(event);
    }
  }

  void handleSignalingStateChange(Map<dynamic, dynamic> map) {
    final String callId = map['callId'];
    if (callId != _id) {
      return;
    }

    final StringeeSignalingState signalingState =
        StringeeSignalingState.values[map['code']];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeCall2Events,
      'eventType': StringeeCall2Events.DidChangeSignalingState,
      'body': signalingState
    });
  }

  void handleMediaStateChange(Map<dynamic, dynamic> map) {
    final String callId = map['callId'];
    if (callId != _id) {
      return;
    }

    final StringeeMediaState mediaState =
        StringeeMediaState.values[map['code']];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeCall2Events,
      'eventType': StringeeCall2Events.DidChangeMediaState,
      'body': mediaState
    });
  }

  void handleCallInfoDidReceive(Map<dynamic, dynamic> map) {
    final String callId = map['callId'];
    if (callId != _id) {
      return;
    }

    final Map<dynamic, dynamic> data = map['info'];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeCall2Events,
      'eventType': StringeeCall2Events.DidReceiveCallInfo,
      'body': data
    });
  }

  void handleAnotherDeviceHadHandle(Map<dynamic, dynamic> map) {
    // String callId = map['callId'];
    // if (callId != this._id) return;

    final StringeeSignalingState signalingState =
        StringeeSignalingState.values[map['code']];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeCall2Events,
      'eventType': StringeeCall2Events.DidHandleOnAnotherDevice,
      'body': signalingState
    });
  }

  void handleReceiveLocalStream(Map<dynamic, dynamic> map) {
    // String callId = map['callId'];
    // if (callId != this._id) return;

    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeCall2Events,
      'eventType': StringeeCall2Events.DidReceiveLocalStream,
      'body': map['callId']
    });
  }

  void handleReceiveRemoteStream(Map<dynamic, dynamic> map) {
    // String callId = map['callId'];
    // if (callId != this._id) return;

    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeCall2Events,
      'eventType': StringeeCall2Events.DidReceiveRemoteStream,
      'body': map['callId']
    });
  }

  void handleChangeAudioDevice(Map<dynamic, dynamic> map) {
    final AudioDevice selectedAudioDevice = AudioDevice.values[map['code']];
    final List<dynamic> codeList = <dynamic>[];
    codeList.addAll(map['codeList']);
    final List<AudioDevice> availableAudioDevices = <AudioDevice>[];
    for (int i = 0; i < codeList.length; i++) {
      final AudioDevice audioDevice = AudioDevice.values[codeList[i]];
      availableAudioDevices.add(audioDevice);
    }
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeCall2Events,
      'eventType': StringeeCall2Events.DidChangeAudioDevice,
      'selectedAudioDevice': selectedAudioDevice,
      'availableAudioDevices': availableAudioDevices
    });
  }

  //region Actions
  Future<Map<dynamic, dynamic>> makeCall(
      Map<dynamic, dynamic> parameters) async {
    final Map<dynamic, dynamic> params = parameters;
    switch (parameters['videoResolution']) {
      case VideoQuality.NORMAL:
        params['videoResolution'] = 'NORMAL';
        break;
      case VideoQuality.HD:
        params['videoResolution'] = 'HD';
        break;
      case VideoQuality.FULLHD:
        params['videoResolution'] = 'FULLHD';
        break;
      default:
        params['videoResolution'] = null;
        break;
    }
    final Map<dynamic, dynamic> results = await StringeeClient.methodChannel
        .invokeMethod<dynamic>('makeCall2', params);
    final Map<dynamic, dynamic> callInfo = results['callInfo'];

    print('callInfo' + callInfo.toString());

    initCallInfo(callInfo);

    final Map<String, dynamic> resultDatas = <String, dynamic>{
      'status': results['status'],
      'code': results['code'],
      'message': results['message']
    };

    return resultDatas;
  }

  Future<Map<dynamic, dynamic>> initAnswer() async {
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('initAnswer2', _id);
  }

  Future<Map<dynamic, dynamic>> answer() async {
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('answer2', _id);
  }

  Future<Map<dynamic, dynamic>> hangup() async {
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('hangup2', _id);
  }

  Future<Map<dynamic, dynamic>> reject() async {
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('reject2', _id);
  }

  Future<Map<dynamic, dynamic>> sendDtmf(String dtmf) async {
    final Map<String, String?> pram = <String, String?>{
      'callId': _id,
      'dtmf': dtmf,
    };
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('sendDtmf2', pram);
  }

  Future<Map<dynamic, dynamic>> sendCallInfo(
      Map<dynamic, dynamic> callInfo) async {
    final Map<String, dynamic> pram = <String, dynamic>{
      'callId': _id,
      'callInfo': callInfo,
    };
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('sendCallInfo2', pram);
  }

  Future<Map<dynamic, dynamic>> getCallStats() async {
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('getCallStats2', _id);
  }

  Future<Map<dynamic, dynamic>> mute(bool mute) async {
    final Map<String, dynamic> pram = <String, dynamic>{
      'callId': _id,
      'mute': mute,
    };
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('mute2', pram);
  }

  Future<Map<dynamic, dynamic>> enableVideo(bool enableVideo) async {
    final Map<String, dynamic> pram = <String, dynamic>{
      'callId': _id,
      'enableVideo': enableVideo,
    };
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('enableVideo2', pram);
  }

  Future<Map<dynamic, dynamic>> setSpeakerphoneOn(bool on) async {
    final Map<String, dynamic> pram = <String, dynamic>{
      'callId': _id,
      'speaker': on,
    };
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('setSpeakerphoneOn2', pram);
  }

  Future<Map<dynamic, dynamic>> switchCamera(bool isMirror) async {
    final Map<String, dynamic> pram = <String, dynamic>{
      'callId': _id,
      'isMirror': isMirror,
    };
    return await StringeeClient.methodChannel
        .invokeMethod<dynamic>('switchCamera2', pram);
  }

  Future<Map<dynamic, dynamic>> resumeVideo() async {
    if (Platform.isIOS) {
      final Map<String, dynamic> pram = <String, dynamic>{
        'status': false,
        'code': '-4',
        'message': 'This function work only for Android',
      };
      return pram;
    } else {
      final Map<String, String?> pram = <String, String?>{
        'callId': _id,
      };
      return await StringeeClient.methodChannel
          .invokeMethod<dynamic>('resumeVideo2', pram);
    }
  }

  void destroy() {
    if (_subscriber != null) {
      _subscriber?.cancel();
      _eventStreamController.close();
    }
  }

//endregion
}
