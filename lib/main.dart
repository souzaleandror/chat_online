import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {

  //Firestore.instance.collection("teste").document("teste").setData({"teste2":"teste2"});
//  Firestore.instance.collection("mesagens").document().setData({"from":"Daniel","texto":"ola"});
//  Firestore.instance.collection("mesagens").document().setData({"from":"Marcos","texto":"Tudo bem ?"});
//  Firestore.instance.collection("mesagens").document().setData({"from":"Marcos","texto":"Tudo bem 1 ?"});
//  Firestore.instance.collection("mesagens").document().setData({"from":"Marcos","texto":"Tudo bem 2 ?"});

  // 3 formas de leituras - Firebase

  //1) Cada usuarios
//  DocumentSnapshot snapshot = await Firestore.instance.collection("usuarios").document("rpZbBnwTCgoCwzZqeu96").get();
//
//  print(snapshot.data);
//  print(snapshot.documentID);
//
//  DocumentSnapshot snapshot2 = await Firestore.instance.collection("usuarios").document("cbCHdfERYiilOxOKXvDM").get();
//
//  print(snapshot2.data);
//  print(snapshot2.documentID);
  //

  //2) todos os usuarios

//  QuerySnapshot snapshot3 = await Firestore.instance.collection("usuarios").getDocuments();
//
//  print(snapshot3.documents);
//
//  for(DocumentSnapshot docu in snapshot3.documents) {
//    print(docu.documentID);
//    print(docu.data);
//  }

  //3) Em tempo real pegar os dados
//  Firestore.instance.collection("mensagens").snapshots().listen((snapshot4){
//    print(snapshot4.documents);
//
//    for(DocumentSnapshot docu in snapshot4.documents) {
//      print(docu.documentID);
//      print(docu.data);
//    }
//  });

  runApp(MyApp());
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light
);

final ThemeData kDefaultTheme = ThemeData(
    primarySwatch: Colors.purple,
    accentColor: Colors.orangeAccent[400],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS ?
          kIOSTheme : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat App"),
          centerTitle: true,
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ), //AppBar
        body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor
              ),
              child: TextComposer(),
            ),
          ],
        ),
      ), //Scaffold 
    );
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0.0),
        decoration: Theme.of(context).platform == TargetPlatform.iOS ?
        BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]))
        ) : null,
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                icon: Icon(Icons.phone_iphone),
                onPressed: () {
                  
                },
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration.collapsed(hintText: "Enviar Mensagem"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
