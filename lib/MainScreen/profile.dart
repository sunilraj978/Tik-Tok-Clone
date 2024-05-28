import 'dart:io';
import 'dart:math';
import 'package:loading_animations/loading_animations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:tiktok/MainScreen/video.dart';
import 'package:tiktok/main.dart';

class Profile extends StatefulWidget {
  final String uid;

  const Profile({Key key, this.uid}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var userCollection = FirebaseFirestore.instance.collection('user');
  var chat = FirebaseFirestore.instance.collection('ChatUser');
  ScrollController _scrollController = ScrollController();
  var chatCollection = FirebaseFirestore.instance.collection('message');
  var user = FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser.uid).get();
  TextEditingController updateController = TextEditingController();
  var videoCollection = FirebaseFirestore.instance.collection('tiktokVideos');
  bool loading = false;
  bool isFollowing = false;
  bool uploadImage = false;
  int followers;
  int following;
  bool isLoading = false;
  bool isFollowed = false;
  String currentUser;
  String username,status;String pic;Future myVideo;int likes=0;
  File image;
  Future<QuerySnapshot>snapshot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async{
    myVideo =  videoCollection.where('uid',isEqualTo: widget.uid).get();
    DocumentSnapshot userSnapshot = await userCollection.doc(widget.uid).get();

      username = userSnapshot.data()['UserName'];
      pic = userSnapshot.data()['ProfilePic'];
    currentUser = FirebaseAuth.instance.currentUser.uid;
    var document = await videoCollection.where('uid',isEqualTo: widget.uid).get();
    for (var item in document.docs){
      likes = item.data()['likes'].length + likes;
    }




    //get follow following data
    var followerDocument = await  userCollection.doc(widget.uid).collection('followers')
        .get();
   var followingDocument = await userCollection.doc(currentUser).collection('following')
        .get();

   followers = followerDocument.docs.length;
   following = followingDocument.docs.length;

   //check already following
    userCollection.doc(widget.uid)
    .collection('followers').doc(FirebaseAuth.instance.currentUser.uid).get().then((value){
      if(!value.exists){
        setState(() {
          isFollowing = false;
        });
      }
      else{
        setState(() {
          isFollowing = true;
        });
      }
    });

    setState(() {
      loading = true;
    });
  }

//editProfile
  editProfile(){
    return showDialog(
        context:context,
      builder: (context){
          return SimpleDialog(
            children: [
              new Text('Edit Profile',style: new TextStyle(fontWeight: FontWeight.bold),),
              new TextFormField(
                controller:updateController,
                decoration: new InputDecoration(hintText: 'Edit Profile'),
              ),
              new RaisedButton(child: new Text('Edit'),onPressed: (){
                userCollection.doc(FirebaseAuth.instance.currentUser.uid).update({'UserName':updateController.text});setState(() {
                username = updateController.text;
              });
                chat.doc(widget.uid).update({'Username':updateController.text});

              updateController.clear();
              Navigator.pop(context);},color: Colors.pink,),

            ],

          );
      }

    );
  }


  signOut() async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.signOut();

      userCollection.doc(widget.uid).update({
        'Active':false,
      });
  }


//Follow function
  follow() async{
    var document = await userCollection
        .doc(widget.uid).collection('followers')
        .doc(currentUser).get();
    if(!document.exists){
      userCollection.doc(widget.uid).collection('followers')
          .doc(currentUser).set({});
      userCollection.doc(currentUser).collection('following')
          .doc(widget.uid).set({});
      setState(() {
        isFollowing = true;
        followers++;
        isLoading = true;
        isFollowed = false;
      });
    }
    else{
      userCollection.doc(widget.uid).collection('followers')
          .doc(currentUser).delete();
      userCollection.doc(currentUser).collection('following')
          .doc(widget.uid).delete();
      setState(() {
        isFollowing = false;
        followers -- ;
      });
    }
  }


  //Update Profile
  Future PickImage() async{
    var Image = await ImagePicker.pickImage(source: ImageSource.gallery);

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: Image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );
    var result = await FlutterImageCompress.compressAndGetFile(
      Image.path,croppedFile.path,
      quality: 30,

    );

    setState(() {
      image = result;
    });

    setState(() {
      uploadImage = true;
    });
    var allVideo = await userCollection.get();
    int len = allVideo.docs.length;
    StorageReference ImageReferrence = FirebaseStorage.instance.ref().child(FirebaseAuth.instance.currentUser.uid);
    StorageUploadTask uploadTask = ImageReferrence.child("ProfilePic").putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    String url = await taskSnapshot.ref.getDownloadURL();

    userCollection.doc(FirebaseAuth.instance.currentUser.uid).update({'ProfilePic':url});
    chat.doc(FirebaseAuth.instance.currentUser.uid).update({'Pic':url});

    var Profile =  videoCollection.where('uid',isEqualTo: FirebaseAuth.instance.currentUser.uid).get();
   setState(() {
     snapshot = Profile;
   });
   
    setState(() {
      pic = url;
    });

    setState(() {
      uploadImage = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: loading==false?new Center(child:LoadingFlipCircle(
        borderColor: Colors.pink,
        borderSize: 3.0,
        size: 50.0,
        backgroundColor: Colors.pink,
        duration: Duration(milliseconds: 500),
      )):SingleChildScrollView(
        child: new Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: new Column(
                children: [
                 uploadImage == true?new Center(child: new CircularProgressIndicator(),):Center(
                    child: Hero(
                      tag: pic,
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context,new MaterialPageRoute(builder: (context)=>new viewBig(pic:pic,)));
                        },
                        child: new Container(
                          height:130,
                          width: 130,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(image: new NetworkImage(pic),fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(60)

                          ),
                          child:  FirebaseAuth.instance.currentUser.uid == widget.uid? Padding(
                            padding: EdgeInsets.only(left: 100,top: 100),
                            child: Container(
                              height: 70,
                                width: 40,
                                decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(70),
                                  color: Colors.green
                                ),
                                child:new IconButton(icon: new Icon(Icons.photo,color: Colors.white,size: 18,),onPressed: (){PickImage();},)),
                          ):new Container()
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10,bottom: 10),
                    child: new Center(
                      child: new Text(username,style: new TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 22),),
                    ),
                  ),
                 currentUser == widget.uid? new Center(
                    child: InkWell(
                        onTap: (){editProfile();},
                        child: new RaisedButton(child: new Text("Edit Profile"),color: Colors.pink,onPressed: (){editProfile();},)),
                  ):InkWell(
                   onTap: (){follow();},
                    child: new Center(
                     child: isFollowing? new RaisedButton(child: new Text("UnFollow"),color: Colors.pink,onPressed: (){
                       follow();
                     },):new Container(
                       child: InkWell(
                         onTap: (){follow();},
                         child: new RaisedButton(child: new Text('Follow'),color: Colors.pink,onPressed: (){
                           follow();
                         },),
                       ),
                     ),
                 ),
                  ),
                  SizedBox(height: 40,),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new Text('Fans',style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                      new Text('Following',style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                      new Text('Likes',style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new Text('$followers',style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                      new Text('$following',style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                      new Text(likes.toString(),style: new TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)
                    ],
                  ),
                  new FutureBuilder(
                    future: myVideo,
                    builder: (BuildContext context,snapshot){
                      if(!snapshot.hasData){
                        return CircularProgressIndicator();
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context,index){
                          DocumentSnapshot videoSnap = snapshot.data.docs[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context, new MaterialPageRoute(
                                  builder: (context)=>new VideoDisplay(videourl: videoSnap.data()['videourl'].toString()),
                                ));
                              },
                              child: Container(
                                height: 180,
                                width: 50,
                                decoration: new BoxDecoration(image: new DecorationImage(image: new NetworkImage(videoSnap.data()['previewImage']),fit: BoxFit.contain)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                 FirebaseAuth.instance.currentUser.uid==widget.uid?
                   Container(
                     width: MediaQuery.of(context).size.width,
                     decoration: new BoxDecoration(
                       borderRadius: BorderRadius.circular(60),
                     ),
                     child: new RaisedButton(child: new Text('sign Out'),color: Colors.pink,onPressed: (){
                       userCollection.doc(FirebaseAuth.instance.currentUser.uid).update({"Active":false});
                        signOut();
                      },),
                   )
                 :new Container()
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  }

class viewBig extends StatefulWidget {
  final String pic;

  const viewBig({Key key, this.pic}) : super(key: key);
  @override
  _viewBigState createState() => _viewBigState();
}

class _viewBigState extends State<viewBig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: new Text('ProfilePic',style: new TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: new Container(
        height: 500,
        width:  500,
        decoration: new BoxDecoration(
          image: new DecorationImage(image: new NetworkImage(widget.pic))
        ),
    ),
      ));
  }
}






