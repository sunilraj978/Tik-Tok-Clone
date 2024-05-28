import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiktok/MainScreen/chat.dart';
import 'package:tiktok/MainScreen/profile.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  var userCollection = FirebaseFirestore.instance.collection('user');
  var videoCollection = FirebaseFirestore.instance.collection('tiktokVideos');

  Future<QuerySnapshot> snapshot;
  searchUser(String s) {
    var user = userCollection.where('UserName',isGreaterThanOrEqualTo: s).get();


    setState(() {
      snapshot = user;
    });

    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        title: new TextFormField(
          decoration: new InputDecoration(
            hintText: 'Search User',
            suffixIcon: new Icon(Icons.search)
          ),
          onFieldSubmitted: searchUser,
        ),
      ),
      body: snapshot == null?new Center(
        child: new Text('Search User'),
      ):FutureBuilder(
        future: snapshot,
        builder: (BuildContext context,snapshot){
          if(!snapshot.hasData){
            return new CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context,int index){
              DocumentSnapshot user = snapshot.data.docs[index];
              print(snapshot.data.docs.length);
                return  Container(
               child: snapshot.data.docs.length>0? ListTile(
                   leading:  new Container(
                     height: 40,
                     width: 40,
                     child: user.data()['uid']!=FirebaseAuth.instance.currentUser.uid ? new CircleAvatar(backgroundImage: new NetworkImage(user.data()['ProfilePic']),):new Container(),
                   ),
                   trailing: user.data()['uid']!=FirebaseAuth.instance.currentUser.uid ?  new IconButton(icon: new Icon(Icons.chat,color: Colors.white,),onPressed: (){
                     Navigator.push(context,new MaterialPageRoute(
                         builder: (context)=>new Chat(uid: user.data()['uid'],)
                     ));
                   },):new Text(' ',style: new TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                   title:  InkWell(
                       onTap: (){Navigator.push(context,new MaterialPageRoute(
                           builder: (context)=>new Profile(uid:user.data()['uid'],)
                       ));},
                       child: user.data()['uid']!=FirebaseAuth.instance.currentUser.uid ? new Text(user.data()['UserName'],style: new TextStyle(color: Colors.white,fontWeight: FontWeight.bold),):new Container()),
                 ):new Center(
                 child: new Text('No Data', style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
               ),

              );
            },
          );
        },
      ),
    );
  }
}

