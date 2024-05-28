import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController  passwordController = TextEditingController();
  TextEditingController  userController = TextEditingController();


  SignIn(){
    FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password:passwordController.text)
        .then((signInUser) {
          var userCollection = FirebaseFirestore.instance.collection('user').doc(signInUser.user.uid).set({
            'UserName':userController.text,
            'Email':emailController.text,
            'Password':passwordController.text,
            'ProfilePic': 'https://st.depositphotos.com/1779253/5140/v/600/depositphotos_51405259-stock-illustration-male-avatar-profile-picture-use.jpg',
            'uid':FirebaseAuth.instance.currentUser.uid
          });
    });
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[300],
      body: new Container(
        alignment: Alignment.center,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Text("Create New Account",style: new TextStyle(fontSize: 27,fontWeight: FontWeight.bold),),
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
            SizedBox(height: 10,),
            new Container(
              width:MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20,right: 20),
              child: new TextField(
                controller: userController,
                decoration: new InputDecoration(
                    hintText: 'UserName',
                    hintStyle: new TextStyle(fontWeight: FontWeight.bold),
                    prefixIcon: new Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                    )
                ),
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: ()=>SignIn(),
              child: new Container(
                height: 50,
                width: 220,
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(20),
                    color: Colors.orange[500]
                ),
                child: Center(child: new Text('Register',style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),)),
              ),
            ),
            SizedBox(height: 10,),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Text("I agree to",style: new TextStyle(fontSize: 20),),
                SizedBox(width: 5,),
                InkWell(
                    onTap: ()=>Navigator.push(context, new MaterialPageRoute(
                        builder: (context)=>new Register()
                    )),
                    child: new Text("Terms of Policy",style: new TextStyle(fontSize: 20,color: Colors.purple),))
              ],
            )
          ],
        ),
      ),
    );
  }
}
