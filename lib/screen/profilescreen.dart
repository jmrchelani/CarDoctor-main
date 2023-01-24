import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cardoctor/Models/current_aap_user.dart';
import 'package:cardoctor/res/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  String? name;
  String? email;
  String? phone;
  String? name1;
  String? email1;
  String? phone1;
  @override
  void initState() {
    super.initState();
    name = CurrentAppUser.currentUserData.name ??
        CurrentMechanicUser.currentUserMechanicData.name ??
        "";
    email = CurrentAppUser.currentUserData.email ??
        CurrentMechanicUser.currentUserMechanicData.email ??
        "";
    phone = CurrentAppUser.currentUserData.phone ??
        CurrentMechanicUser.currentUserMechanicData.phone ??
        "";
    setState(() {});
  }

  bool showSpinner = false;

  final ref = FirebaseStorage.instance.ref('images');
  bool isUploading = false;

  void uploadImage() {
    setState(() {
      isUploading = true;
    });
    final _auth = FirebaseAuth.instance;
    final _user = _auth.currentUser;
    if (_user != null && _image != null) {
      final _uid = _user.uid;
      final imageExt = _image!.path.split('.').last;
      final _ref = FirebaseStorage.instance.ref('images/$_uid.$imageExt');
      _ref.putFile(_image!).then((value) {
        value.ref.getDownloadURL().then((value) async {
          print(value);
          Fluttertoast.showToast(msg: "Image Uploaded");
          var _ref = FirebaseFirestore.instance.collection('users');
          if ((await _ref.doc(_uid).get()).exists) {
            await _ref.doc('$_uid').update({'image': value});
          }
          _ref = FirebaseFirestore.instance.collection('mechanic');
          if ((await _ref.doc('$_uid').get()).exists) {
            await _ref.doc('$_uid').update({'image': value});
          }
          setState(() {
            isUploading = false;
          });
        });
      });
    }
  }

  File? _image;
  final picker = ImagePicker();
  Future getCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImage();
      } else {
        print("No Image Selected");
      }
    });
  }

  Future getGalleryImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImage();
      } else {
        print("No Image Selected");
      }
    });
  }

  void dialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  InkWell(
                      onTap: () {
                        getCameraImage();
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text("Camera"),
                      )),
                  InkWell(
                      onTap: () {
                        getGalleryImage();
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text("Gallery"),
                      ))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Center(
                  child: Badge(
                badgeColor: Colors.white70,
                position: BadgePosition.bottomEnd(),
                badgeContent: InkWell(
                  onTap: () => dialog(context),
                  child: isUploading
                      ? CircularProgressIndicator()
                      : Icon(
                          Icons.camera_alt,
                          // color: Colors.grey.shade500,
                          size: 30.0,
                        ),
                ),
                child: Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primaryColor, width: 5)),
                  child: ClipOval(
                    // borderRadius: BorderRadius.circular(100),
                    child: Image(
                        image: NetworkImage(
                          CurrentAppUser.currentUserData.image ??
                              CurrentMechanicUser
                                  .currentUserMechanicData.image ??
                              "https://firebasestorage.googleapis.com/v0/b/cardoctor-1f2c7.appspot.com/o/images%2Fdefault.png?alt=media&token=0b0b0b0b-0b0b-0b0b-0b0b-0b0b0b0b0b0b",
                        ),
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                          );
                        }),
                  ),
                ),
              )),
              SizedBox(height: 20),
              Text(
                " $name",
                style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'Pacifico',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Text(
              //   "$email".toUpperCase(),
              //   style: TextStyle(
              //     fontSize: 20.0,
              //     fontFamily: 'SourceSansPro',
              //     color: Colors.teal.shade100,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: 2.5,
              //   ),
              // ),
              SizedBox(
                height: 20.0,
                width: 150,
                child: Divider(
                  color: Colors.teal.shade100,
                ),
              ),
              InkWell(
                child: Card(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.phone,
                      color: Colors.teal,
                    ),
                    title: Text(
                      '$phone',
                      style: TextStyle(
                          fontFamily: 'SourceSansPro',
                          fontSize: 20,
                          color: Colors.teal.shade900),
                    ),
                  ),
                ),
              ),
              InkWell(
                child: Card(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.email,
                      color: Colors.teal,
                    ),
                    title: Text(
                      '$email'.toUpperCase(),
                      style: TextStyle(
                          fontFamily: 'SourceSansPro',
                          fontSize: 20,
                          color: Colors.teal.shade900),
                    ),
                  ),
                ),
                // onTap: (){
                //   _launchURL('mailto:fadcrepin@gmail.com?subject=Need Flutter developer&body=Please contact me');
                // },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // StreamBuilder(
  //   stream: ref.child(SessionController().userID.toString()).onValue,
  //   builder: (context, AsyncSnapshot snapshot) {
  //     if (!snapshot.hasData) {
  //       return Center(child: CircularProgressIndicator());
  //     } else if (snapshot.hasData) {
  //       return
  //             ),
  //           ]);
}

void toastMessage(String message) {
  Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
