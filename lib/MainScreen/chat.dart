import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class Chat extends StatefulWidget {
  final String uid;

  const Chat({Key key, this.uid}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream _stream;
  ScrollController _scrollController = ScrollController();
  TextEditingController chatController = TextEditingController();
  var chatCollection = FirebaseFirestore.instance.collection('message');
  var userCollection = FirebaseFirestore.instance.collection('user');
  bool isLoading = false;
  String username,pic,status;
  bool status2;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
    _stream = chatCollection.orderBy("timestamp",descending: true).limit(20).snapshots();
  }
  getUserDetails() async{
    DocumentSnapshot snapshot = await userCollection.doc(widget.uid).get();
    username = snapshot.data()['UserName'];
    pic = snapshot.data()['ProfilePic'];
    status2 = snapshot.data()['Active'];
    print(status2);
    userCollection.doc(FirebaseAuth.instance.currentUser.uid).update({'Active':true});
    setState(() {
      status;
    });
    setState(() {
      isLoading = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.black,
          title: Stack(
              children: <Widget>
              [
                new Container(
                  width: MediaQuery.of(context).size.width,
                  child: new ListTile(
                    leading: pic !=null? new CircleAvatar(backgroundImage: new NetworkImage(pic),):new Container(),
                    title: username != null? new Text(username,style: new TextStyle(color: Colors.white,fontWeight: FontWeight.bold),):new Container(),
                    subtitle: status2.toString() == 'false'? new Text('Offline',style: new TextStyle(color: Colors.red,fontWeight: FontWeight.bold),):new Text('Online',style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                  ),
                )
              ]
          )),
      backgroundColor: Colors.black,
     body: isLoading == false?new Center(child: new CircularProgressIndicator(),):new Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: new StreamBuilder(
              stream: _stream,
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return new CircularProgressIndicator();
                }
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  controller: _scrollController,
                  itemBuilder: (context,index){
                    DocumentSnapshot snap = snapshot.data.docs[index];
                  return ((snap.data()['FromId'] == FirebaseAuth.instance.currentUser.uid)&&((snap.data()['FromId'] == FirebaseAuth.instance.currentUser.uid)&&(snap.data()['ToId'] == widget.uid)))?  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child:
                       new Stack(
                          children: [
                           new Column(
                             children: [
                               Bubble(
                                 margin: BubbleEdges.only(top: 10,left: 80),
                                 alignment: Alignment.topRight,
                                 nipWidth: 3,
                                 nipHeight: 14,
                                 nip: BubbleNip.rightTop,
                                 color: Color.fromRGBO(225, 255, 199, 1.0),
                                 child: Text(snap.data()['Message'], textAlign: TextAlign.right),
                               ),

                             ],
                           ),

                          ],
                    )
                  ):
                  ((snap.data()['FromId'] == widget.uid)&&(snap.data()['ToId'] == FirebaseAuth.instance.currentUser.uid))?
                  Bubble(
                    margin: BubbleEdges.only(top: 10,right:80),
                    alignment: Alignment.topLeft,
                    nipWidth: 8,
                    nipHeight: 24,
                    nip: BubbleNip.leftTop,
                    child: Text(snap.data()['Message']),
                  ):new Container();
                  },
                );
              },
            ),
          ),
        new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SentMessage(),
          ],
        )
        ],
      )

    );

  }


  SentMessage(){
    return Stack(
      children: <Widget>[
        new Row(
          children: <Widget>[
//            new Container(
//              child: new Material(
//                child: new IconButton(icon: new Icon(Icons.attachment), onPressed: (){
//                  Sow(context);
//                }),
//              ),
//            ),
            new Flexible(
                child: new Stack(
                  children: <Widget>[
                    new TextFormField(
                      controller:chatController,
                      style: new TextStyle(fontSize: 15),
                      decoration: new InputDecoration(
                          prefixIcon:new IconButton(
                            icon: new Icon(Icons.face),
                          ),
                          hintText: 'Type a Message',
                          border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          filled: true,
                          fillColor: Colors.white
                      ),
                      onFieldSubmitted: (e){
                        saveData();
                      },
                    ),
                  ],
                )
            ),

          ],
        )
      ],
    );
  }






  saveData() async {
    var chatCollection = FirebaseFirestore.instance.collection('message');
    var allVideo = await chatCollection.get();
    int len = allVideo.docs.length;
    var chats =  FirebaseFirestore.instance.collection('message').doc('$len').set({
      'Message':chatController.text,
      "timestamp":DateTime.now().millisecondsSinceEpoch.toString(),
      'FromId':FirebaseAuth.instance.currentUser.uid,
      'ToId' : widget.uid,
      'Seen' : "false",
      "UserName":username,
      "Pic":pic
    });
    var user = await FirebaseFirestore.instance.collection('ChatUser').doc(widget.uid).get();
    if(user.data() == null){
      FirebaseFirestore.instance.collection('ChatUser').doc(widget.uid).set({
        'Username':username,
        "Pic":pic,
        'uid':widget.uid,
        'FromId':FirebaseAuth.instance.currentUser.uid,
        'ToId':widget.uid
      });
    }
    chatController.clear();
    _scrollController.animateTo(0.0, duration:new Duration(microseconds: 300), curve:Curves.easeOutCirc);
  }

}





class ChatScreen extends StatefulWidget {
  final String uid;

  const ChatScreen({Key key, this.uid}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var chatCollection = FirebaseFirestore.instance.collection('ChatUser');
  var userCollection = FirebaseFirestore.instance.collection('user');
  Stream _stream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _stream = chatCollection.snapshots();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: new Text('Chats',style: new TextStyle(color: Colors.white),),
      ),
      body: new StreamBuilder(
      stream: _stream,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return new CircularProgressIndicator();
        }
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context,index){
            DocumentSnapshot snap = snapshot.data.docs[index];

            return (snap.data()['FromId'] == FirebaseAuth.instance.currentUser.uid)?  Padding(
                padding: const EdgeInsets.only(top: 0),
                child:
                new Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: new ListTile(
                        leading: new CircleAvatar(backgroundImage: new NetworkImage(snap?.data()['Pic']),),
                        title: new Text(snap?.data()['Username'],style: new TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        trailing: new IconButton(icon: new Icon(Icons.chat),color: Colors.white,onPressed: (){
                          Navigator.push(context,new MaterialPageRoute(
                            builder: (context)=>Chat(uid: snap.data()['uid'],)
                          ));
                        },),
                      ),

                    ),
                  ],
                )
            ):
                new Container();
          },
        );
      },
    ),
    );
  }


}





