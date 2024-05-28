import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart'as vid;
import 'package:video_compress/video_compress.dart';
class Confirm extends StatefulWidget {

  final File filename;
  final String filepath;
  final ImageSource src;



  const Confirm({Key key, this.filename, this.filepath, this.src}) : super(key: key);

  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {

  TextEditingController songName = TextEditingController();
  TextEditingController caption = TextEditingController();
 vid.FlutterVideoCompress _compress = vid.FlutterVideoCompress();
  bool isLoading = false;
  VideoPlayerController controller;
  var videoCollection = FirebaseFirestore.instance.collection('tiktokVideos');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      print(widget.filename);
      controller = VideoPlayerController.file(widget.filename);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
  compressVideo() async{

    if(widget.src == ImageSource.gallery){
      final compresses =  await VideoCompress.compressVideo(
          widget.filepath,
          deleteOrigin: false,
          includeAudio: true,
          quality: VideoQuality.LowQuality
      );
      return File(compresses.path);
    }
    else{
      final compresses =  await VideoCompress.compressVideo(
          widget.filepath,
          deleteOrigin: false,
          includeAudio: true,
          quality: VideoQuality.LowQuality
      );
      return File(compresses.path);
    }
  }

  compressImage() async{
    final gmage = _compress.getThumbnailWithFile(widget.filepath);
    return gmage;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true?new Center(child: new CircularProgressIndicator(),):SingleChildScrollView(
        child: new Stack(
          children: [
           new Column(
             children: [
               SingleChildScrollView(
                 child: new Container(
                   width: MediaQuery.of(context).size.width,
                   height: MediaQuery.of(context).size.height-240,
                   child: VideoPlayer(controller),
                 ),
               ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new Container(
                        width: MediaQuery.of(context).size.width/2.2,
                        child: new TextFormField(
                          controller: songName,
                          decoration: new InputDecoration(
                            hintText: 'Song Name',
                            prefixIcon: new Icon(Icons.music_note),
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                        ),
                      ),
                      new Container(
                        width: MediaQuery.of(context).size.width/2.2,
                        child: new TextFormField(
                          controller: caption,
                          decoration: new InputDecoration(
                              hintText: 'caption',
                              prefixIcon: new Icon(Icons.closed_caption),
                              border: new OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               new Column(
                 children: [
                   new RaisedButton(child: new Text('Upload'),color: Colors.red,onPressed: (){uploadVideo();},)
                 ],
               )
             ],
           )
          ],
        ),
      )
    );
  }
  uploadVideo() async{
    setState(() {
      isLoading = true;
    });
    var firebaseUid = FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('user').doc(firebaseUid).get();
    var videoCollection = FirebaseFirestore.instance.collection('tiktokVideos');
    print(snapshot.data());
    var allVideo = await videoCollection.get();
    int len = allVideo.docs.length;
    String videoUrl = await videoUpload('Video $len');
    String previewImage = await uploadImage("Video $len");
    videoCollection.doc("Video $len").set({
      'username':snapshot.data()['UserName'],
      'ProfilePic':snapshot.data()['ProfilePic'],
      'uid':firebaseUid,
      'id':"Video $len",
      "likes":[],
      "comments":0,
      "share":0,
      "songName":songName.text,
      "caption":caption.text,
      "videourl":videoUrl,
      "previewImage":previewImage
    });
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  videoUpload(String s)  async{

    StorageReference Video = FirebaseStorage.instance.ref().child('Video');
    StorageReference Image = FirebaseStorage.instance.ref().child('Image');
    StorageUploadTask storageUploadTask = Video.child(s).putFile(await compressVideo());
    StorageTaskSnapshot snapshot = await storageUploadTask.onComplete;
    String url = await snapshot.ref.getDownloadURL();
    return url;

  }
  uploadImage(String s)  async{
    StorageReference Image = FirebaseStorage.instance.ref().child('Image');

    StorageUploadTask storageUploadTask = Image.child(s).putFile(await compressImage());

    StorageTaskSnapshot snapshot = await storageUploadTask.onComplete;

    String url = await snapshot.ref.getDownloadURL();

    return url;

  }
}





