import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'Screen/dashPage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'Screen/register.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );

  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: uiImage(),
    title: 'Tik Tok',

  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isSigned = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if(user!=null){
        setState(() {
          isSigned = true;
        });
      }
      else{
        setState(() {
          isSigned = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSigned == false?Login():isLoading == true?new CircularProgressIndicator():DashPage()
    );
  }
}


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController  passwordController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[300],
      body:new Container(
        alignment: Alignment.center,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Text("Welcome to TikTok",style: new TextStyle(fontSize: 27,fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            new Container(
              width:MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20,right: 20),
              child: new TextField(
                controller: emailController,
                decoration: new InputDecoration(

                  hintText: 'Email',
                  hintStyle: new TextStyle(fontWeight: FontWeight.bold),
                  prefixIcon: new Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),
              ),
            ),
            SizedBox(height: 10,),
            new Container(
              width:MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20,right: 20),
              child: new TextField(
                controller: passwordController,
                obscureText: true,
                decoration: new InputDecoration(
                    hintText: 'Password',
                    hintStyle: new TextStyle(fontWeight: FontWeight.bold),
                    prefixIcon: new Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                    )
                ),
              ),
            ),
            SizedBox(height: 20,),
            new Container(
              height: 50,
              width: 220,
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(20),
                color: Colors.orange[500]
              ),
              child: InkWell(
                  onTap: ()async{
                    try{
                   final id = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);

                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.success,
                        text: "Login successful!",
                      );

                    }
                    catch(e){
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.error,
                        text: "User Not Found",
                      );
                    }
                  },
                  child: Center(child: new Text('Login',style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),))),
            ),
            SizedBox(height: 10,),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Text("Don't have an account",style: new TextStyle(fontSize: 20),),
                SizedBox(width: 5,),
                InkWell(
                    onTap: ()=>Navigator.push(context, new MaterialPageRoute(
                      builder: (context)=>new Register()
                    )),
                    child: new Text("Register",style: new TextStyle(fontSize: 20,color: Colors.purple),))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class uiImage extends StatefulWidget {
  @override
  _uiImageState createState() => _uiImageState();
}

class _uiImageState extends State<uiImage>  {

  Timer _timer;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }
  startTime(){
    _timer = new Timer(Duration(milliseconds: 3000), (){
      Navigator.pushReplacement(context,new MaterialPageRoute(
        builder: (context)=>new HomePage()
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration(
          image: new DecorationImage(image: new NetworkImage('https://gray-kvly-prod.cdn.arcpublishing.com/resizer/SDUmEqG1ZAsdeCqU-yNAAciOvII=/1200x1800/smart/cloudfront-us-east-1.images.arcpublishing.com/gray/7UMWUM5I3VNGLGT3OIQ7JZ5XMU.jpg'),fit: BoxFit.cover)
        ),
      )
    );
  }
}

