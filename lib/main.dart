import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final apiKey = "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";

void main(){
  runApp(MaterialApp(home: ChatScreen(),));
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = TextEditingController();
  List<ChatMessage> chatMessages = [];

  void sendMessage(String message) async {
    // Add user's message to the list
    setState(() {
      chatMessages.add(ChatMessage(text: message, isUser: true));
    });

    // Call the OpenAI API
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/text-davinci-003/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: json.encode({
        'prompt': message,
        'max_tokens': 50,
      }),
    );

    print("API Request: ${json.encode({
      'prompt': message,
      'max_tokens': 50,
    })}");

    if (response.statusCode == 200) {
      // Parse the API response
      final jsonResponse = json.decode(response.body);

      print("API Response: $jsonResponse");

      // Check if 'choices' is not empty before accessing its elements
      if (jsonResponse['choices'] != null && jsonResponse['choices'].isNotEmpty) {
        // Add the AI's response to the list
        setState(() {
          chatMessages.add(ChatMessage(text: jsonResponse['choices'][0]['text'], isUser: false));
        });
      } else {
        print("No response text from the chatbot.");
      }
    } else {
      print("Request Failed With Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        centerTitle: true,
        title: Text("RexiN BOT"),
      ),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
              itemCount: chatMessages.length,
            itemBuilder: (context,index){
                final message = chatMessages[index];
                return ChatBubble(
                  text: message.text,
                  isUser: message.isUser,
                );
            },
            ),
          ),
          Padding(padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Enter your message",
                ),
              ),
              ),
              IconButton(onPressed: (){
                sendMessage(messageController.text);
                messageController.clear();
              }, icon: Icon(Icons.send))
            ],
          ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatBubble({
    required this.text,
    required this.isUser,
});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(
      vertical: 5,horizontal: 10
    ),
    child: Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if(!isUser)
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text("AI"),
          ),
        Container(
          constraints:BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Text(text,style: TextStyle(
            color: Colors.white
          ),
          ),
        ),
        if(isUser)
          CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.person),
          )
      ],
    ),
    );
  }
}

