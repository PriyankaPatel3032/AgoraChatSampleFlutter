import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';

class MessageList extends StatefulWidget {
  MessageList({Key? key, required this.chatUserId}) : super(key: key);
  String chatUserId;

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final List<ChatMessage?> _messageList = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    getMessages();
    _addChatListener();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      )),
                  Text(
                    widget.chatUserId,
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Flexible(
              child: ListView.builder(
                  itemCount: _messageList.length,
                  itemBuilder: (_, index) {
                    var messageData = _messageList[index];

                    return Container(
                      alignment:
                          messageData!.from.toString() == widget.chatUserId
                              ? Alignment.topLeft
                              : Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0,right: 10.0,top: 2),
                        child: Text(messageData.body.toJson()["content"],style: TextStyle(fontSize: 15),),
                      ),
                    );
                  }),
            ),

            Row(
              children: [
                const SizedBox(width: 15,),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Enter message",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _sendMessage();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  icon: Icon(Icons.send,color: Colors.blue,),
                ),
              ],
            ),

            //  Text(_logText.toString()),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    var msg = ChatMessage.createTxtSendMessage(
      targetId: widget.chatUserId, content: controller.text,
    );
    msg.chatType = ChatType.Chat;

    ChatClient.getInstance.chatManager.sendMessage(msg).then((value) {
      setState(() {
        _messageList.add(value);
          controller.clear();
      });
    });
  }

  Future<void> getMessages() async {
    try {
      // The conversation ID.
      String? convId = widget.chatUserId;
      // The conversation type.
      ChatConversationType convType = ChatConversationType.Chat;
      // The maximin number of messages
      int pageSize = 100;
      // The message ID from which to start retrieving
      String startMsgId = "";
      ChatCursorResult<ChatMessage?> cursor =
          await ChatClient.getInstance.chatManager.fetchHistoryMessages(
        conversationId: convId,
        type: convType,
        pageSize: pageSize,
        startMsgId: startMsgId,
      );

      _messageList.addAll(cursor.data);
      setState(() {});
    } catch (e) {}
  }

  void _addChatListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    setState(() {
      _messageList.add(messages[0]);
    });
  }
}
