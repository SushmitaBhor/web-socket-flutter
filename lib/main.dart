import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebSocketDemo(),
    );
  }
}

class WebSocketDemo extends StatefulWidget {
  WebSocketDemo({
    super.key,
  });
  final channel =
      WebSocketChannel.connect(Uri.parse("wss://echo.websocket.events"));
  @override
  State<WebSocketDemo> createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  @override
  void initState() {
    super.initState();
  }

  List<String> messageList = [];
  final inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                        labelText: 'Send Message',
                        border: OutlineInputBorder()),
                    style: TextStyle(fontSize: 22),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (inputController.text.isNotEmpty) {
                          widget.channel.sink
                              .add(inputController.text ?? 'Hello!');
                          inputController.text = "";
                        }
                      },
                      child: Text('send'),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded(child: getMessageList()),

            Expanded(
                child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                if (snapshot.error != null) {
                  messageList.add("try again");
                } else if (snapshot.hasData) {
                  if (snapshot.data !=
                      "echo.websocket.events sponsored by Lob.com") {
                    if (messageList.contains(snapshot.data)) {
                      messageList.removeLast();
                      messageList.add(snapshot.data);
                    } else {
                      messageList.add(snapshot.data);
                    }
                  }
                }
                return getMessageList();
              },
            ))
          ],
        ),
      ),
    );
  }

  ListView getMessageList() {
    List<Widget> listWidget = [];

    for (String message in messageList) {
      listWidget.add(ListTile(
        title: Container(
          color: Colors.lightBlueAccent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),
      ));
    }
    return ListView(children: listWidget);
  }

  @override
  void dispose() {
    inputController.dispose();
    widget.channel.sink.close();
    super.dispose();
  }
}
