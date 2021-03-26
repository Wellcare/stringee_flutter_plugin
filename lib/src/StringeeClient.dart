import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'StringeeConstants.dart';
import 'call/StringeeCall.dart';
import 'call/StringeeCall2.dart';
import 'messaging/Conversation.dart';
import 'messaging/Message.dart';
// import 'messaging/User.dart';

class StringeeClient {
  factory StringeeClient() {
    return _instance;
  }

  StringeeClient._internal() {
    eventChannel.receiveBroadcastStream().listen(_listener);
  }

  static final StringeeClient _instance = StringeeClient._internal();

  static const MethodChannel methodChannel =
      MethodChannel('com.stringee.flutter.methodchannel');
  static const EventChannel eventChannel =
      EventChannel('com.stringee.flutter.eventchannel');
  final StreamController<dynamic> _eventStreamController =
      StreamController<dynamic>.broadcast();

  String? _userId;
  String? _projectId;
  bool _hasConnected = false;
  bool _isReconnecting = false;

  String? get userId => _userId;

  String? get projectId => _projectId;

  bool get hasConnected => _hasConnected;

  bool get isReconnecting => _isReconnecting;

  StreamController<dynamic> get eventStreamController => _eventStreamController;

  /// connect to StringeeClient
  Future<void> connect(String token) async {
    return await methodChannel.invokeMethod('connect', token);
  }

  /// disconnect to StringeeCLient
  Future<void> disconnect() async {
    return await methodChannel.invokeMethod('disconnect');
  }

  ///register push from Stringee
  Future<Map<dynamic, dynamic>> registerPush(
      Map<dynamic, dynamic> parameters) async {
    return await methodChannel.invokeMethod<dynamic>(
        'registerPush', parameters);
  }

  /// unregister push from Stringee
  Future<Map<dynamic, dynamic>> unregisterPush(String deviceToken) async {
    return await methodChannel.invokeMethod<dynamic>(
        'unregisterPush', deviceToken);
  }

  /// send a custom message
  Future<Map<dynamic, dynamic>> sendCustomMessage(
      Map<dynamic, dynamic> parameters) async {
    return await methodChannel.invokeMethod<dynamic>(
        'sendCustomMessage', parameters);
  }

  /// create new conversation
  Future<Map<dynamic, dynamic>> createConversation(
      Map<dynamic, dynamic> parameters) async {
    final Map<dynamic, dynamic> params = parameters;
    params['users'] = jsonEncode(parameters['users']);
    params['option'] = jsonEncode(parameters['option']);
    return await methodChannel.invokeMethod<dynamic>(
        'createConversation', params);
  }

  Future<Map<dynamic, dynamic>> getConversationById(
      Map<dynamic, dynamic> parameters) async {
    return await methodChannel.invokeMethod<dynamic>(
        'getConversationById', parameters);
  }

  ///send StringeeClient event
  void _listener(dynamic event) {
    assert(event != null);
    final Map<dynamic, dynamic> map = event;
    if (map['typeEvent'] == StringeeType.StringeeClient.index) {
      switch (map['event']) {
        case 'didConnect':
          _handleDidConnectEvent(map['body']);
          break;
        case 'didDisconnect':
          _handleDidDisconnectEvent(map['body']);
          break;
        case 'didFailWithError':
          _handleDidFailWithErrorEvent(map['body']);
          break;
        case 'requestAccessToken':
          _handleRequestAccessTokenEvent(map['body']);
          break;
        case 'didReceiveCustomMessage':
          _handleDidReceiveCustomMessageEvent(map['body']);
          break;
        case 'incomingCall':
          _handleIncomingCallEvent(map['body']);
          break;
        case 'incomingCall2':
          _handleIncomingCall2Event(map['body']);
          break;
        case 'didReceiveTopicMessage':
          _handleDidReceiveTopicMessageEvent(map['body']);
          break;
        case 'didReceiveChangeEvent':
          _handleReceiveChangeEvent(map['body']);
          break;
      }
    } else {
      eventStreamController.add(event);
    }
  }

  void _handleDidConnectEvent(Map<dynamic, dynamic> map) {
    _userId = map['userId'];
    _projectId = map['projectId'];
    _hasConnected = true;
    _isReconnecting = map['isReconnecting'];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.DidConnect,
      'body': null
    });
  }

  void _handleDidDisconnectEvent(Map<dynamic, dynamic> map) {
    _userId = map['userId'];
    _projectId = map['projectId'];
    _hasConnected = false;
    _isReconnecting = map['isReconnecting'];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.DidDisconnect,
      'body': null
    });
  }

  void _handleDidFailWithErrorEvent(Map<dynamic, dynamic> map) {
    _userId = map['userId'];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.DidFailWithError,
      'message': map['message'],
      'code': map['code']
    });
  }

  void _handleRequestAccessTokenEvent(Map<dynamic, dynamic> map) {
    _userId = map['userId'];
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.RequestAccessToken,
      'body': null
    });
  }

  void _handleDidReceiveCustomMessageEvent(Map<dynamic, dynamic> map) {
    final Map<dynamic, dynamic> body = <String, dynamic>{
      'from': map['fromUserId'],
      'message': map['infor']
    };
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.DidReceiveCustomMessage,
      'body': body
    });
  }

  void _handleDidReceiveTopicMessageEvent(Map<dynamic, dynamic> map) {
    final Map<dynamic, dynamic> body = <String, dynamic>{
      'from': map['fromUserId'],
      'message': map['infor']
    };
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.DidReceiveTopicMessage,
      'body': body
    });
  }

  void _handleIncomingCallEvent(Map<dynamic, dynamic> map) {
    final StringeeCall call = StringeeCall.fromCallInfo(map);
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.IncomingCall,
      'body': call
    });
  }

  void _handleIncomingCall2Event(Map<dynamic, dynamic> map) {
    final StringeeCall2 call = StringeeCall2.fromCallInfo(map);
    _eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.IncomingCall2,
      'body': call
    });
  }

  void _handleReceiveChangeEvent(Map<dynamic, dynamic> map) {
    final Map<dynamic, dynamic> bodyMap = map;
    bodyMap['changeType'] = ChangeType.values[bodyMap['changeType']];
    bodyMap['objectType'] = ObjectType.values[bodyMap['objectType']];
    switch (bodyMap['objectType']) {
      case ObjectType.CONVERSATION:
        bodyMap['objects'] = Conversation.initFromEvent(bodyMap['objects']);
        break;
      case ObjectType.MESSAGE:
        bodyMap['objects'] = Message.initFromEvent(bodyMap['objects']);
        break;
    }
    eventStreamController.add(<String, dynamic>{
      'typeEvent': StringeeClientEvents,
      'eventType': StringeeClientEvents.DidReceiveChange,
      'body': bodyMap
    });
  }
}
