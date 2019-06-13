import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

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

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signInSilently();
  }
  if (user == null) {
    user = await googleSignIn.signIn();
  }
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
//    await auth.signInWithGoogle(
//      idToken: credentials.idToken,
//      accessToken: credentials.accessToken
//    );
    await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: credentials.idToken, accessToken: credentials.accessToken));
  }
}

final ThemeData kIOSTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

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
      theme: Theme.of(context).platform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
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
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ), //AppBar
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                  stream:
                      Firestore.instance.collection("messagens").snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        return ListView.builder(
                            reverse: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              List r = snapshot.data.documents.reversed.toList();
                              return ChatMessage(r[index].data);
                            });
                    }
                  }),

//              child: ListView(
//                children: <Widget>[
//                  ChatMessage(),
//                  ChatMessage(),
//                  ChatMessage(),
//                  ChatMessage(),
//                ],
//              ),
//            ),
            ),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: TextComposer(),
            ),
          ],
        ),
      ), //Scaffold
    );
  }
}

_handleSubmitted(text) async {
  await _ensureLoggedIn();
  _sendMessage(text: text);
}

void _sendMessage({String text, String imgUrl}) {
  Firestore.instance.collection("messagens").add({
    "text": text,
    "imgUrl": imgUrl,
    "senderName": googleSignIn.currentUser.displayName,
    "senderPhotoUrl": googleSignIn.currentUser.photoUrl
  });
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  final _textController = TextEditingController();

  void _reset() {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0.0),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200])))
            : null,
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                icon: Icon(Icons.phone_iphone),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration:
                    InputDecoration.collapsed(hintText: "Enviar Mensagem"),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: (text) {
                  _handleSubmitted(text);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text("Enviar"),
                      onPressed: _isComposing
                          ? () {
                              _handleSubmitted(_textController.text);
                              _reset();
                            }
                          : null,
                    )
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _isComposing
                          ? () {
                              _handleSubmitted(_textController.text);
                              _reset();
                            }
                          : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;

  ChatMessage(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              //backgroundImage: NetworkImage("https://abrilsuperinteressante.files.wordpress.com/2018/05/filhotes-de-cachorro-alcanc3a7am-o-c3a1pice-de-fofura-com-8-semanas1.png"),
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                //"Daniel",
                data["senderName"],
                style: Theme.of(context).textTheme.subhead,
              ),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                //child: Text("teste"),
                child: data["imgUrl"] != null ?
                    Image.network(data["imgUrl"], width: 250.0) : Text(data["text"]),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
