import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'confirm.dart';

class addVideo extends StatefulWidget {
  @override
  _addVideoState createState() => _addVideoState();
}

class _addVideoState extends State<addVideo> {
  uploadVideo(ImageSource src) async{
    Navigator.pop(context);
    final video = await ImagePicker().getVideo(source: src);
    Navigator.push(context, new MaterialPageRoute(
      builder: (context)=>new Confirm(filename: File(video.path),filepath: video.path,src: src,)
    ));
  }
  selectOption(){
    return showDialog(
      context:context,
      builder: (context){
        return SimpleDialog(
          children: [
            new SimpleDialogOption(child: new Text('Gallery'),onPressed: (){uploadVideo(ImageSource.gallery);},),
            new SimpleDialogOption(child: new Text('Camera'),onPressed: (){uploadVideo(ImageSource.camera);},),
            new SimpleDialogOption(child: new Text('Cancel'),onPressed: (){Navigator.pop(context);},)
          ],
        );
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: new Center(
        child: new RaisedButton(child: new Text('Add Video'),color: Colors.pink,onPressed: (){
          selectOption();
        },),
      ),
    );
  }
}
