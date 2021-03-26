import 'package:flutter/material.dart';
import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';

import 'Call.dart';

const String user1 =
    'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZULTE2MDg3MTY0ODAiLCJpc3MiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZUIiwiZXhwIjoxNjExMzA4NDgwLCJ1c2VySWQiOiJ1c2VyMSJ9.e5U4nCiHrKDpuqi8oWs0LHTtzcH6_2Q0hP1oqMdNeMw';
const String user2 =
    'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZULTE2MDYxMjI4OTkiLCJpc3MiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZUIiwiZXhwIjoxNjA4NzE0ODk5LCJ1c2VySWQiOiJ1c2VyMiJ9.b_tG9wp0zharQV0EHVSGefXyCzUvmGjqTImEVNOg01o';
const String token =
    'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTS3RVaTBMZzNLa0lISkVwRTNiakZmMmd6UGtsNzlsU1otMTYwODg2NjkxMiIsImlzcyI6IlNLdFVpMExnM0trSUhKRXBFM2JqRmYyZ3pQa2w3OWxTWiIsImV4cCI6MTYwODk1MzMxMiwidXNlcklkIjoiQUM3RlRFTzZHVCIsImljY19hcGkiOnRydWUsImRpc3BsYXlOYW1lIjoiTmd1eVx1MWVjNW4gUXVhbmcgS1x1MWVmMyBBbmgiLCJhdmF0YXJVcmwiOm51bGwsInN1YnNjcmliZSI6Im9ubGluZV9zdGF0dXNfR1I2Nkw3SU4sQUxMX0NBTExfU1RBVFVTLGFnZW50X21hbnVhbF9zdGF0dXMiLCJhdHRyaWJ1dGVzIjoiW3tcImF0dHJpYnV0ZVwiOlwib25saW5lU3RhdHVzXCIsXCJ0b3BpY1wiOlwib25saW5lX3N0YXR1c19HUjY2TDdJTlwifSx7XCJhdHRyaWJ1dGVcIjpcImNhbGxcIixcInRvcGljXCI6XCJjYWxsX0dSNjZMN0lOXCJ9XSJ9.akfOwo9a2WzhZvLcUGi322LJgJLrn2sRIz4Wls1RG_E';
final StringeeClient client = StringeeClient();
String strUserId = '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'OneToOneCallSample', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String myUserId = 'Not connected...';

  @override
  void initState() {
    super.initState();

    // Lắng nghe sự kiện của StringeeClient(kết nối, cuộc gọi đến...)
    client.eventStreamController.stream.listen((dynamic event) {
      final Map<dynamic, dynamic> map = event;
      if (map['typeEvent'] == StringeeClientEvents) {
        switch (map['eventType']) {
          case StringeeClientEvents.DidConnect:
            handleDidConnectEvent();
            break;
          case StringeeClientEvents.DidDisconnect:
            handleDiddisconnectEvent();
            break;
          case StringeeClientEvents.DidFailWithError:
            handleDidFailWithErrorEvent(map['code'], map['message']);
            break;
          case StringeeClientEvents.RequestAccessToken:
            handleRequestAccessTokenEvent();
            break;
          case StringeeClientEvents.DidReceiveCustomMessage:
            handleDidReceiveCustomMessageEvent(
                map['body']['from'], map['body']['message']);
            break;
          case StringeeClientEvents.DidReceiveTopicMessage:
            handleDidReceiveTopicMessageEvent(
                map['body']['from'], map['body']['message']);
            break;
          case StringeeClientEvents.IncomingCall:
            final StringeeCall call = map['body'];
            handleIncomingCallEvent(call);
            break;
          case StringeeClientEvents.IncomingCall2:
            final StringeeCall2 call = map['body'];
            handleIncomingCall2Event(call);
            break;
          default:
            break;
        }
      }
    });

    // Connect
    client.connect(token);
  }

  @override
  Widget build(BuildContext context) {
    final Widget topText = Container(
      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
      child: Text(
        'Connected as: $myUserId',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('OneToOneCallSample'),
        backgroundColor: Colors.indigo[600],
      ),
      body: Stack(
        children: <Widget>[topText, MyForm()],
      ),
    );
  }

  //region Handle Client Event
  void handleDidConnectEvent() {
    if (client.userId != null)
      setState(() {
        myUserId = client.userId!;
      });
  }

  void handleDiddisconnectEvent() {
    setState(() {
      myUserId = 'Not connected...';
    });
  }

  void handleDidFailWithErrorEvent(int code, String message) {
    print('code: ' + code.toString() + '\nmessage: ' + message);
  }

  void handleRequestAccessTokenEvent() {
    print('Request new access token');
  }

  void handleDidReceiveCustomMessageEvent(
      String from, Map<dynamic, dynamic> message) {
    print('from: ' + from + '\nmessage: ' + message.toString());
  }

  void handleDidReceiveTopicMessageEvent(
      String from, Map<dynamic, dynamic> message) {
    print('from: ' + from + '\nmessage: ' + message.toString());
  }

  void handleIncomingCallEvent(StringeeCall call) {
    if (call.from != null && call.to != null) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => Call(
            fromUserId: call.from!,
            toUserId: call.to!,
            isVideoCall: call.isVideocall,
            callType: StringeeType.StringeeCall,
            showIncomingUi: true,
            incomingCall: call,
          ),
        ),
      );
    }
  }

  void handleIncomingCall2Event(StringeeCall2 call) {
    if (call.from != null && call.to != null) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => Call(
            fromUserId: call.from!,
            toUserId: call.to!,
            isVideoCall: call.isVideocall,
            callType: StringeeType.StringeeCall2,
            showIncomingUi: true,
            incomingCall2: call,
          ),
        ),
      );
    }
  }

//endregion
}

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (String value) {
                _changeText(value);
              },
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _callTapped(false, StringeeType.StringeeCall);
                      },
                      child: const Text('CALL'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.grey[300],
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.black,
                        ),
                        padding: MaterialStateProperty.resolveWith(
                          (_) => const EdgeInsets.only(left: 20.0, right: 20.0),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _callTapped(true, StringeeType.StringeeCall);
                      },
                      child: const Text('VIDEOCALL'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.grey[300],
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.black,
                        ),
                        padding: MaterialStateProperty.resolveWith(
                          (_) => const EdgeInsets.only(left: 20.0, right: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _callTapped(false, StringeeType.StringeeCall2);
                      },
                      child: const Text('CALL2'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.grey[300],
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.black,
                        ),
                        padding: MaterialStateProperty.resolveWith(
                          (_) => const EdgeInsets.only(left: 20.0, right: 20.0),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _callTapped(true, StringeeType.StringeeCall2);
                      },
                      child: const Text('VIDEOCALL2'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.grey[300],
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.black,
                        ),
                        padding: MaterialStateProperty.resolveWith(
                          (_) => const EdgeInsets.only(left: 20.0, right: 20.0),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeText(String val) {
    strUserId = val;
  }

  void _callTapped(bool isVideoCall, StringeeType callType) {
    // if (strUserId.isEmpty || !client.hasConnected) return;
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => Call(
    //           fromUserId: client.userId,
    //           toUserId: strUserId,
    //           isVideoCall: isVideoCall,
    //           callType: callType,
    //           showIncomingUi: false)),
    // );
    // List<User> users = [];
    // User user = new User('3', 'a', null);
    // User user2 = new User('v', 'v', null);
    // users.add(user);
    // users.add(user2);
    //
    // ConversationOption option = new ConversationOption('a', true, false);
    // final parameters = {
    //   'users': users,
    //   'option': option,
    // };
    // client.createConversation(parameters);

    final Map<String, String> parameters = <String, String>{
      'convId': 'conv-vn-1-73JJ5R8BMN-1606409865248'
    };

    client.getConversationById(parameters);
  }
}
