import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:tiktok/MainScreen/comments.dart';
import 'package:tiktok/MainScreen/profile.dart';
import 'package:typed_data/typed_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiktok/MainScreen/circularAnimation.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:video_player/video_player.dart';
class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {

  var videoCollection = FirebaseFirestore.instance.collection('tiktokVideos');
  Stream myStream;
  String uid,status;
  var userCollection = FirebaseFirestore.instance.collection('user');


  //shareVideo
  shareVideo(String id, String url) async {
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('TikTok', 'Video.mp4', bytes, 'video/mp4');
    DocumentSnapshot shareSnap = await videoCollection.doc(id).get();
    videoCollection.doc(id).update({
      'share': shareSnap.data()['share'] + 1
    });
  }


  LikeVideo(String id) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot likeSnap = await videoCollection.doc(id).get();

    if (likeSnap.data()['likes'].contains(uid)) {
      videoCollection.doc(id).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    }
    else {
      videoCollection.doc(id).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }


  musicAlbum() {
    return Container(
      height: 50,
      width: 50,
      decoration: new BoxDecoration(
          image: new DecorationImage(image: new NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7g6ijKuiBf9lpjb6LACvE5qON3UlJ4pijzQ&usqp=CAU')),
          color: Colors.purple,
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: [Colors.grey[800], Colors.grey[900]])
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myStream = videoCollection.snapshots();
    uid = FirebaseAuth.instance.currentUser.uid;
    userCollection.doc(FirebaseAuth.instance.currentUser.uid).update({'Active':true});
  }

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  Future<bool> saveVideo(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/tiktok";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
              setState(() {
                progress = value1 / value2;
              });
            });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile(String url) async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded = await saveVideo(
        url,
        randomString(10));
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        backgroundColor: Colors.black,
        body: loading?Center(
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
          ),
        ) : StreamBuilder(
            stream: myStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return new Center(child: new CircularProgressIndicator(),);
              }
              return PageView.builder(
                  itemCount: snapshot.data.docs.length,
                  controller: PageController(initialPage: 0, viewportFraction: 1),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    DocumentSnapshot videoSnapshot = snapshot.data.docs[index];

                    return new Stack(
                      children: [
                        VideoDisplay(videourl: videoSnapshot.data()['videourl'],),
                        new Column(
                          children: [
                            Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 12,
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Text('Following',
                                    style: new TextStyle(color: Colors.white),),
                                  SizedBox(width: 8,),
                                  new Text('|',
                                    style: new TextStyle(color: Colors.white),),
                                  SizedBox(width: 8,),
                                  new Text('For you', style: new TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))
                                ],
                              ),
                            )
                          ],
                        ),

                        SingleChildScrollView(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 160),
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      new Container(
                                        height: 40,
                                        width: 40,
                                        child: InkWell(
                                            onTap: (){
                                              Navigator.push(context,new MaterialPageRoute(
                                                builder: (context)=>new Profile(uid: videoSnapshot.data()['uid'],)
                                              ));
                                            },
                                            child: ImageDisplay(uid:videoSnapshot.data()['uid'])),
                                      ),
                                      SizedBox(height: 20,),
                                      InkWell(
                                          onTap: () {
                                            LikeVideo(videoSnapshot.data()['id']);
                                          },
                                          child: new Icon(Icons.favorite,
                                            color: videoSnapshot.data()['likes']
                                                .contains(uid) ? Colors.red : Colors
                                                .white, size: 35,)
                                      ),
                                      new Text(videoSnapshot.data()['likes'].length
                                          .toString(),
                                        style: new TextStyle(color: Colors.white),),
                                      SizedBox(height: 20,),
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(context,
                                                new MaterialPageRoute(builder: (
                                                    context) => new Comment(
                                                  id: videoSnapshot
                                                      .data()['id'],)));
                                          },
                                          child: new Icon(
                                            Icons.comment, color: Colors.white,
                                            size: 35,)),
                                      new Text(
                                        videoSnapshot.data()['comments'].toString(),
                                        style: new TextStyle(color: Colors.white),),
                                      SizedBox(height: 20,),

                                      InkWell(
                                          onTap: () {
                                           downloadFile(videoSnapshot.data()['videourl'].toString());
                                          },
                                          child:new Icon(Icons.file_download,color: Colors.white)
                                          ),
                                      SizedBox(height: 20,),

                                      InkWell(
                                          onTap: () {
                                            shareVideo(videoSnapshot.data()['id'],
                                                videoSnapshot.data()['videourl']);
                                          },
                                          child: new Icon(
                                            Icons.share, color: Colors.white,
                                            size: 35,)),
                                      new Text(
                                        videoSnapshot.data()['share'].toString(),
                                        style: new TextStyle(color: Colors.white),),
                                      SizedBox(height: 20,),
                                      CircularAnimation(child: musicAlbum())
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        Container(
                          height: size.height - 120,
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              new Text(videoSnapshot.data()['username'],
                                style: new TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Container(
                          height: size.height - 90,
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              new Text(videoSnapshot.data()['caption'],
                                style: new TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Container(
                          height: size.height / 1,
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              new Icon(Icons.music_note, color: Colors.white,),
                              new Text(videoSnapshot.data()['songName'],
                                style: new TextStyle(color: Colors.white),),
                            ],
                          ),
                        )

                      ],
                    );
                  }
              );
            }
        ),
      );

  }

}








class ImageDisplay extends StatefulWidget {

  final String uid;

  const ImageDisplay({Key key, this.uid}) : super(key: key);

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {


  String url;

  getProfile() async{
    var userCollection = FirebaseFirestore.instance.collection('user');
    DocumentSnapshot snapshot = await userCollection.doc(widget.uid).get();
    setState(() {
      url = snapshot.data()['ProfilePic'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height:40,
          width: 40,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: url!=null? new ClipRRect(
            child: new Image(image: new NetworkImage(url),fit: BoxFit.cover,),
            borderRadius: BorderRadius.circular(25),
          ):Container(),
        ),
        Container(
          height: 12,
          width: 12,
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.pink
          ),
          child: new Center(
            child: new Icon(Icons.add,color: Colors.white,size: 13,),
          ),
        )
      ],
    );
  }
}







//DisPlay Video
class VideoDisplay extends StatefulWidget {

  final String videourl;

  const VideoDisplay({Key key, this.videourl}) : super(key: key);

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {

  VideoPlayerController videoPlayerController;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videourl)
    ..initialize().then((value){
      videoPlayerController.play();
      videoPlayerController.setLooping(false);
      videoPlayerController.setVolume(1);
    });
    setState(() {
      isLoading = true;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child:  isLoading == true? VideoPlayer(videoPlayerController):new Center(child: new CircularProgressIndicator(),),
    );
  }
}
















