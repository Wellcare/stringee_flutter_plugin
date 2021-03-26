import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';

StringeeCall? _stringeeCall;
StringeeCall2? _stringeeCall2;

class Call extends StatefulWidget {
  const Call({
    Key? key,
    required this.fromUserId,
    required this.toUserId,
    this.showIncomingUi = false,
    this.isVideoCall = false,
    this.callType,
    this.incomingCall2,
    this.incomingCall,
  }) : super(key: key);

  final StringeeCall? incomingCall;
  final StringeeCall2? incomingCall2;
  final String toUserId;
  final String fromUserId;
  final StringeeType? callType;
  final bool showIncomingUi;
  final bool isVideoCall;

  @override
  State<StatefulWidget> createState() {
    return _CallState();
  }
}

class _CallState extends State<Call> {
  String? _callId;
  String _status = '';
  bool _isSpeaker = false;
  bool _hasLocalStream = false;
  bool _hasRemoteStream = false;
  late bool _showIncomingUi;
  final bool _isMirror = true;

  @override
  void initState() {
    super.initState();

    _showIncomingUi = widget.showIncomingUi;
    _isSpeaker = widget.isVideoCall;

    if (widget.callType == StringeeType.StringeeCall) {
      _makeOrInitAnswerCall();
    } else {
      _makeOrInitAnswerCall2();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget _nameCalling = Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 120.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              '${widget.toUserId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 35.0,
              ),
            ),
          ),
          Container(
            child: Text(
              _status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
    );

    final Widget _bottomContainer = Container(
      padding: const EdgeInsets.only(bottom: 30.0),
      alignment: Alignment.bottomCenter,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _showIncomingUi
              ? <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: _rejectCallTapped,
                        child: Image.asset(
                          'images/end.png',
                          height: 75.0,
                          width: 75.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: _acceptCallTapped,
                        child: Image.asset(
                          'images/answer.png',
                          height: 75.0,
                          width: 75.0,
                        ),
                      ),
                    ],
                  )
                ]
              : <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ButtonSpeaker(isSpeaker: widget.isVideoCall),
                      const ButtonMicro(isMute: false),
                      ButtonVideo(isVideoEnable: widget.isVideoCall),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: GestureDetector(
                      onTap: _endCallTapped,
                      child: Image.asset(
                        'images/end.png',
                        height: 75.0,
                        width: 75.0,
                      ),
                    ),
                  )
                ]),
    );

    final Widget localView = (_hasLocalStream && _callId != null)
        ? StringeeVideoView(
            color: Colors.white,
            alignment: Alignment.topRight,
            callId: _callId!,
            isLocal: true,
            isOverlay: true,
            isMirror: _isMirror,
            margin: const EdgeInsets.only(top: 100.0, right: 25.0),
            height: 200.0,
            width: 150.0,
          )
        : const Placeholder();

    final Widget remoteView = (_hasRemoteStream && _callId != null)
        ? StringeeVideoView(
            color: Colors.blue,
            callId: _callId!,
            isLocal: false,
            isOverlay: false,
            isMirror: false,
            scalingType: ScalingType.SCALE_ASPECT_FIT,
          )
        : const Placeholder();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          remoteView,
          localView,
          _nameCalling,
          _bottomContainer,
          ButtonSwitchCamera(
            isMirror: _isMirror,
          ),
        ],
      ),
    );
  }

  Future<void> _makeOrInitAnswerCall() async {
    // Gán cuộc gọi đến cho biến global
    _stringeeCall = widget.incomingCall;

    if (!_showIncomingUi) {
      _stringeeCall = StringeeCall();
    }

    // Listen events
    _stringeeCall!.eventStreamController.stream.listen((dynamic event) {
      final Map<dynamic, dynamic> map = event;
      if (map['typeEvent'] == StringeeCallEvents) {
        switch (map['eventType']) {
          case StringeeCallEvents.DidChangeSignalingState:
            handleSignalingStateChangeEvent(map['body']);
            break;
          case StringeeCallEvents.DidChangeMediaState:
            handleMediaStateChangeEvent(map['body']);
            break;
          case StringeeCallEvents.DidReceiveCallInfo:
            handleReceiveCallInfoEvent(map['body']);
            break;
          case StringeeCallEvents.DidHandleOnAnotherDevice:
            handleHandleOnAnotherDeviceEvent(map['body']);
            break;
          case StringeeCallEvents.DidReceiveLocalStream:
            handleReceiveLocalStreamEvent(map['body']);
            break;
          case StringeeCallEvents.DidReceiveRemoteStream:
            handleReceiveRemoteStreamEvent(map['body']);
            break;
          case StringeeCallEvents.DidChangeAudioDevice:
            if (Platform.isAndroid) {
              handleChangeAudioDeviceEvent(
                  map['selectedAudioDevice'], _stringeeCall!, null);
            }
            break;
          default:
            break;
        }
      }
    });

    if (_showIncomingUi) {
      _stringeeCall!.initAnswer().then((Map<dynamic, dynamic> event) {
        final bool status = event['status'];
        if (!status) {
          clearDataEndDismiss();
        }
      });
    } else {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'from': widget.fromUserId,
        'to': widget.toUserId,
        'isVideoCall': widget.isVideoCall,
        'customData': null,
        'videoResolution': VideoQuality.FULLHD,
      };

      _stringeeCall!.makeCall(parameters).then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        final int code = result['code'];
        final String message = result['message'];
        print(
            'MakeCall CallBack --- $status - $code - $message - ${_stringeeCall!.id} - ${_stringeeCall!.from} - ${_stringeeCall!.to}');
        if (!status) {
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _makeOrInitAnswerCall2() async {
    // Gán cuộc gọi đến cho biến global
    _stringeeCall2 = widget.incomingCall2;

    if (!_showIncomingUi) {
      _stringeeCall2 = StringeeCall2();
    }

    // Listen events
    _stringeeCall2!.eventStreamController.stream.listen((dynamic event) {
      final Map<dynamic, dynamic> map = event;
      if (map['typeEvent'] == StringeeCall2Events) {
        switch (map['eventType']) {
          case StringeeCall2Events.DidChangeSignalingState:
            handleSignalingStateChangeEvent(map['body']);
            break;
          case StringeeCall2Events.DidChangeMediaState:
            handleMediaStateChangeEvent(map['body']);
            break;
          case StringeeCall2Events.DidReceiveCallInfo:
            handleReceiveCallInfoEvent(map['body']);
            break;
          case StringeeCall2Events.DidHandleOnAnotherDevice:
            handleHandleOnAnotherDeviceEvent(map['body']);
            break;
          case StringeeCall2Events.DidReceiveLocalStream:
            handleReceiveLocalStreamEvent(map['body']);
            break;
          case StringeeCall2Events.DidReceiveRemoteStream:
            handleReceiveRemoteStreamEvent(map['body']);
            break;
          case StringeeCall2Events.DidChangeAudioDevice:
            if (Platform.isAndroid) {
              handleChangeAudioDeviceEvent(
                  map['selectedAudioDevice'], null, _stringeeCall2);
            }
            break;
          default:
            break;
        }
      }
    });

    if (_showIncomingUi) {
      _stringeeCall2?.initAnswer().then((Map<dynamic, dynamic> event) {
        final bool status = event['status'];
        if (!status) {
          clearDataEndDismiss();
        }
      });
    } else {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'from': widget.fromUserId,
        'to': widget.toUserId,
        'isVideoCall': widget.isVideoCall,
        'customData': null,
        'videoResolution': VideoQuality.FULLHD,
      };

      _stringeeCall2!.makeCall(parameters).then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        final int code = result['code'];
        final String message = result['message'];
        print(
            'MakeCall CallBack --- $status - $code - $message - ${_stringeeCall2!.id} - ${_stringeeCall2!.from} - ${_stringeeCall2!.to}');
        if (!status) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _endCallTapped() {
    switch (widget.callType) {
      case StringeeType.StringeeCall:
        _stringeeCall?.hangup().then((Map<dynamic, dynamic> result) {
          print('_endCallTapped -- ${result['message']}');
          final bool status = result['status'];
          if (status) {
            clearDataEndDismiss();
          }
        });
        break;
      case StringeeType.StringeeCall2:
        _stringeeCall2?.hangup().then((Map<dynamic, dynamic> result) {
          print('_endCallTapped -- ${result['message']}');
          final bool status = result['status'];
          if (status) {
            clearDataEndDismiss();
          }
        });
        break;
      default:
    }
  }

  void _acceptCallTapped() {
    switch (widget.callType) {
      case StringeeType.StringeeCall:
        _stringeeCall?.answer().then((Map<dynamic, dynamic> result) {
          print('_acceptCallTapped -- ${result['message']}');
          final bool status = result['status'];
          if (!status) {
            clearDataEndDismiss();
          }
        });
        break;
      case StringeeType.StringeeCall2:
        _stringeeCall2?.answer().then((Map<dynamic, dynamic> result) {
          print('_acceptCallTapped -- ${result['message']}');
          final bool status = result['status'];
          if (!status) {
            clearDataEndDismiss();
          }
        });
        break;
      default:
    }
    setState(() {
      _showIncomingUi = !_showIncomingUi;
    });
  }

  void _rejectCallTapped() {
    switch (widget.callType) {
      case StringeeType.StringeeCall:
        _stringeeCall?.reject().then((Map<dynamic, dynamic> result) {
          print('_rejectCallTapped -- ${result['message']}');
          clearDataEndDismiss();
        });
        break;
      case StringeeType.StringeeCall2:
        _stringeeCall2?.reject().then((Map<dynamic, dynamic> result) {
          print('_rejectCallTapped -- ${result['message']}');
          clearDataEndDismiss();
        });
        break;
      default:
    }
  }

  void handleSignalingStateChangeEvent(StringeeSignalingState state) {
    print('handleSignalingStateChangeEvent - $state');
    setState(() {
      _status = state.toString().split('.')[1];
    });
    switch (state) {
      case StringeeSignalingState.Calling:
        break;
      case StringeeSignalingState.Ringing:
        break;
      case StringeeSignalingState.Answered:
        break;
      case StringeeSignalingState.Busy:
        clearDataEndDismiss();
        break;
      case StringeeSignalingState.Ended:
        clearDataEndDismiss();
        break;
      default:
        break;
    }
  }

  void handleMediaStateChangeEvent(StringeeMediaState state) {
    print('handleMediaStateChangeEvent - $state');
    setState(() {
      _status = state.toString().split('.')[1];
    });
    switch (state) {
      case StringeeMediaState.Connected:
        break;
      case StringeeMediaState.Disconnected:
        break;
      default:
        break;
    }
  }

  void handleReceiveCallInfoEvent(Map<dynamic, dynamic> info) {
    print('handleReceiveCallInfoEvent - $info');
  }

  void handleHandleOnAnotherDeviceEvent(StringeeSignalingState state) {
    print('handleHandleOnAnotherDeviceEvent - $state');
  }

  void handleReceiveLocalStreamEvent(String callId) {
    print('handleReceiveLocalStreamEvent - $callId');
    setState(() {
      _hasLocalStream = true;
      _callId = callId;
    });
  }

  void handleReceiveRemoteStreamEvent(String callId) {
    print('handleReceiveRemoteStreamEvent - $callId');
    setState(() {
      _hasRemoteStream = true;
      _callId = callId;
    });
  }

  void handleChangeAudioDeviceEvent(
      AudioDevice audioDevice, StringeeCall? call, StringeeCall2? call2) {
    print('handleChangeAudioDeviceEvent - $audioDevice');
    switch (audioDevice) {
      case AudioDevice.SPEAKER_PHONE:
      case AudioDevice.EARPIECE:
        if (call != null) {
          call.setSpeakerphoneOn(_isSpeaker);
        }
        if (call2 != null) {
          call2.setSpeakerphoneOn(_isSpeaker);
        }
        break;
      case AudioDevice.BLUETOOTH:
      case AudioDevice.WIRED_HEADSET:
        _isSpeaker = false;
        if (call != null) {
          call.setSpeakerphoneOn(_isSpeaker);
        }
        if (call2 != null) {
          call2.setSpeakerphoneOn(_isSpeaker);
        }
        break;
      case AudioDevice.NONE:
        print('handleChangeAudioDeviceEvent - non audio devices connected');
        break;
    }
  }

  void clearDataEndDismiss() {
    if (_stringeeCall != null) {
      _stringeeCall!.destroy();
      _stringeeCall = null;
      Navigator.pop(context);
    } else if (_stringeeCall2 != null) {
      _stringeeCall2!.destroy();
      _stringeeCall2 = null;
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }
}

class ButtonSwitchCamera extends StatelessWidget {
  const ButtonSwitchCamera({Key? key, required this.isMirror})
      : super(key: key);
  final bool isMirror;

  void _toggleSwitchCamera() {
    if (_stringeeCall != null) {
      _stringeeCall
          ?.switchCamera(!isMirror)
          .then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {}
      });
    } else {
      _stringeeCall2
          ?.switchCamera(!isMirror)
          .then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 50.0, top: 50.0),
        child: GestureDetector(
          onTap: _toggleSwitchCamera,
          child: Image.asset(
            'images/switch_camera.png',
            height: 30.0,
            width: 30.0,
          ),
        ),
      ),
    );
  }
}

class ButtonSpeaker extends StatefulWidget {
  const ButtonSpeaker({Key? key, required this.isSpeaker}) : super(key: key);
  final bool isSpeaker;

  @override
  State<StatefulWidget> createState() => _ButtonSpeakerState();
}

class _ButtonSpeakerState extends State<ButtonSpeaker> {
  late bool _isSpeaker;

  void _toggleSpeaker() {
    if (_stringeeCall != null) {
      _stringeeCall
          ?.setSpeakerphoneOn(!_isSpeaker)
          .then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {
          setState(() {
            _isSpeaker = !_isSpeaker;
          });
        }
      });
    } else {
      _stringeeCall2
          ?.setSpeakerphoneOn(!_isSpeaker)
          .then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {
          setState(() {
            _isSpeaker = !_isSpeaker;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isSpeaker = widget.isSpeaker;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSpeaker,
      child: Image.asset(
        _isSpeaker ? 'images/ic_speaker_off.png' : 'images/ic_speaker_on.png',
        height: 75.0,
        width: 75.0,
      ),
    );
  }
}

class ButtonMicro extends StatefulWidget {
  const ButtonMicro({Key? key, required this.isMute}) : super(key: key);
  final bool isMute;

  @override
  State<StatefulWidget> createState() => _ButtonMicroState();
}

class _ButtonMicroState extends State<ButtonMicro> {
  late bool _isMute;

  void _toggleMicro() {
    if (_stringeeCall != null) {
      _stringeeCall?.mute(!_isMute).then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {
          setState(() {
            _isMute = !_isMute;
          });
        }
      });
    } else {
      _stringeeCall2?.mute(!_isMute).then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {
          setState(() {
            _isMute = !_isMute;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isMute = widget.isMute;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleMicro,
      child: Image.asset(
        _isMute ? 'images/ic_mute.png' : 'images/ic_mic.png',
        height: 75.0,
        width: 75.0,
      ),
    );
  }
}

class ButtonVideo extends StatefulWidget {
  const ButtonVideo({Key? key, required this.isVideoEnable}) : super(key: key);
  final bool isVideoEnable;

  @override
  State<StatefulWidget> createState() => _ButtonVideoState();
}

class _ButtonVideoState extends State<ButtonVideo> {
  late bool _isVideoEnable;

  void _toggleVideo() {
    if (_stringeeCall != null) {
      // _stringeeCall.enableVideo(!_isVideoEnable).then((result) {
      //   bool status = result['status'];
      //   if (status) {
      //     setState(() {
      //       _isVideoEnable = !_isVideoEnable;
      //     });
      //   }
      // });
      _stringeeCall?.resumeVideo().then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {}
      });
    } else {
      // _stringeeCall2.enableVideo(!_isVideoEnable).then((result) {
      //   bool status = result['status'];
      //   if (status) {
      //     setState(() {
      //       _isVideoEnable = !_isVideoEnable;
      //     });
      //   }
      // });
      _stringeeCall2?.resumeVideo().then((Map<dynamic, dynamic> result) {
        final bool status = result['status'];
        if (status) {}
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isVideoEnable = widget.isVideoEnable;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isVideoEnable ? _toggleVideo : null,
      child: Image.asset(
        _isVideoEnable ? 'images/ic_video.png' : 'images/ic_video_off.png',
        height: 75.0,
        width: 75.0,
      ),
    );
  }
}
