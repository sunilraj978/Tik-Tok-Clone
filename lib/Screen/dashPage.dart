import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiktok/MainScreen/addVideo.dart';
import 'package:tiktok/MainScreen/chat.dart';
import 'package:tiktok/MainScreen/profile.dart';
import 'package:tiktok/MainScreen/search.dart';
import 'package:tiktok/MainScreen/video.dart';


class DashPage extends StatefulWidget {
  @override
  _DashPageState createState() => _DashPageState();
}

class _DashPageState extends State<DashPage> {

  var userCollection = FirebaseFirestore.instance.collection('user');
  List items = [
    Video(),
    Search(),
    addVideo(),
    ChatScreen(uid: FirebaseAuth.instance.currentUser.uid,),
    Profile(uid:FirebaseAuth.instance.currentUser.uid)
  ];

  int page = 0;

  Future<bool> _back(){
    return showDialog(
      context: context,
      builder: (context)=>new AlertDialog(
        backgroundColor: Colors.black,
        title: new Text('Are you want to exit tiktok',style: new TextStyle(color: Colors.white,fontSize: 20),),
        actions: [
          FlatButton.icon(icon: new Icon(Icons.done),label:new Text('Exit',style: new TextStyle(color: Colors.white,fontSize: 16)),color: Colors.green,onPressed: (){
            userCollection.doc(FirebaseAuth.instance.currentUser.uid).update({
              'Active':false
            });
            Navigator.pop(context,true);
          },),
          FlatButton.icon(icon: new Icon(Icons.clear),label:new Text('Cancel',style: new TextStyle(color: Colors.white,fontSize: 16)),color: Colors.red,onPressed: (){
            Navigator.pop(context,false);
          },)
        ],

      )
    );
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _back,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: items[page],
        bottomNavigationBar: new BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,

          unselectedItemColor: Colors.grey,
          onTap: (index){
            setState(() {
              page = index;
            });
          },
          currentIndex: page,
          items: [
            BottomNavigationBarItem(icon: new Icon(Icons.home),title: new Text('Home')),
            BottomNavigationBarItem(icon: new Icon(Icons.search),title: new Text('Search')),
            BottomNavigationBarItem(icon: customIcon(),title: new Text('')),
            BottomNavigationBarItem(icon: new Icon(Icons.chat),title: new Text('Chat')),
            BottomNavigationBarItem(icon: new Icon(Icons.person),title: new Text('Profile'))
          ],
        ),

      ),
    );
  }
}

customIcon() {
  return Container(
    height: 27,
    width: 47,
    child: new Stack(
      children: [
        new Container(
          margin: EdgeInsets.only(left: 10),
          width: 37,
          decoration: new BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.lightGreen),
        ),
        new Container(
          margin: EdgeInsets.only(right: 10),
          width: 37,
          decoration: new BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.deepOrange),
        ),
        Center(
          child: new Container(
            height: double.infinity,
            width: 37,
            decoration: new BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white),
            child: new Icon(Icons.add,color: Colors.blue,),
          ),
        ),
      ],
    ),
  );
}
