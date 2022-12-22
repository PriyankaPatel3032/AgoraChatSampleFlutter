import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'agora_chat_config.dart';
import 'message_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agora Chat Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<String> _logText = [];
  ScrollController scrollController = ScrollController();
  bool isSignIn = false;
  String? loginID;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSDK();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Agora Chat"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 10),
              const Text("Login User : ${ AgoraChatConfig.userId}", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: _signIn,
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.lightBlue),
                      ),
                      child: const Text("SIGN IN"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: _signOut,

                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.lightBlue),
                      ),
                      child: const Text("SIGN OUT",style: TextStyle(fontSize: 15),),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Enter recipient's userId",hintStyle : TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _sendMessage,
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                ),
                child: const Text("Message",style: TextStyle(fontSize: 15),),
              ),
              const SizedBox(height: 10),

              Flexible(
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: _logText.length,
                    itemBuilder: (_, index) {

                        return
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                            child: Text(_logText[index],style: TextStyle(fontSize: 15),),
                        );

                    }),
              ),
            ],
          ),
        ));
  }

  void _initSDK() async {
    ChatOptions options = ChatOptions(
      appKey: AgoraChatConfig.appKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
  }

  void _signIn() async {
    try {
      await ChatClient.getInstance.loginWithAgoraToken(
        AgoraChatConfig.userId,
        AgoraChatConfig.agoraToken,
      );
      _addLogToConsole("login succeed : ${AgoraChatConfig.userId}");
      isSignIn = true;

      loginID = AgoraChatConfig.userId;
    } on ChatError catch (e) {
      _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
      isSignIn = false;

    } on ChatError catch (e) {
      _addLogToConsole(
          "sign out failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _sendMessage() async {

    if(!isSignIn){
      _addLogToConsole("Please signin");

    }
    else if (!controller.text.isEmpty) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageList(chatUserId: controller.text),
        ),
      );
    }else{
      _addLogToConsole("Please enter recipient's userId");
    }
  }

  void _addLogToConsole(String log) {
    _logText.add(log);
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }
}
