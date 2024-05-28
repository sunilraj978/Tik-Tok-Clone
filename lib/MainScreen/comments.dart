import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tago;

class Comment extends StatefulWidget {

  final String id;

  const Comment({Key key, this.id}) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  TextEditingController commentController = TextEditingController();
  var videoCollection = FirebaseFirestore.instance.collection('tiktokVideos');
  var userCollection = FirebaseFirestore.instance.collection('user');
  String uid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
  }

  sendComment() async{
    DocumentSnapshot userSnap = await userCollection.doc(uid).get();
    var alldocs = await videoCollection.doc(widget.id).collection('Comments').get();
    int length = alldocs.docs.length;
    videoCollection.doc(widget.id).collection('Comments').doc("comment $length").set({
      'username': userSnap.data()['UserName'],
      'uid':uid,
      'comment':commentController.text,
      'Pic':userSnap.data()['ProfilePic'],
      'likes':[],
      'time':DateTime.now(),
      'id':'comment $length'
    });
    commentController.clear();
    DocumentSnapshot videoSnap = await videoCollection.doc(widget.id).get();
    videoCollection.doc(widget.id).update({
      'comments':videoSnap.data()['comments'] + 1,
    });
  }



  LikeVideo(String id) async{
    print('gj');
    DocumentSnapshot likeSnap = await videoCollection.doc(widget.id).collection('Comments').doc(id).get();

    if(likeSnap.data()['likes'].contains(uid)){
      videoCollection.doc(widget.id).collection('Comments').doc(id).update({
        'likes':FieldValue.arrayRemove([uid])
      });
    }
    else{
      videoCollection.doc(widget.id).collection('Comments').doc(id).update({
        'likes':FieldValue.arrayUnion([uid])
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: new Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: videoCollection.doc(widget.id).collection('Comments').snapshots(),
                  builder: (BuildContext context, snapshot){
                    if(!snapshot.hasData){
                      return new Center(child: new CircularProgressIndicator(),);
                    }
                    return ListView.builder(
                      itemCount:snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index){
                        DocumentSnapshot comment = snapshot.data.docs[index];
                        return ListTile(
                         leading: new CircleAvatar(backgroundImage: new NetworkImage(comment.data()['Pic'].toString()),),
                          title: new Row(
                            children: [
                              new Text(comment.data()['username']),
                              SizedBox(width: 5,),
                              new Text(comment.data()['comment'])
                            ],
                          ),
                          subtitle: new Row(
                            children: [
                              new Text(tago.format(comment.data()['time'].toDate())),
                              SizedBox(width: 5,),
                              new Text(comment.data()['likes'].length.toString()+' ' + 'likes')
                            ],
                          ),
                          trailing: new InkWell(
                            onTap: (){LikeVideo(comment.data()['id']);},
                            child:new Icon(Icons.favorite,color: comment.data()['likes'].contains(uid)?Colors.red:Colors.grey,))
                        );
                      },
                    );
                  },
                )
              ),
              Divider(),
              ListTile(
                title: new TextFormField(
                  controller:commentController,
                  decoration: new InputDecoration(
                    hintText: 'Comment',
                    hintStyle: new TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: new IconButton(onPressed: (){
                  sendComment();
                },icon: new Icon(Icons.send),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
