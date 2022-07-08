import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp_task/custom%20widgets/custom_toast.dart';
import 'package:fyp_task/custom_formfield.dart';
import 'package:fyp_task/user profile/profile_widget.dart';
import 'package:fyp_task/user profile/teacher_profile.dart';
import 'package:get/get.dart';

import '../custom widgets/custom_widgets.dart';

class edit_profile extends StatefulWidget {
  const edit_profile({Key? key}) : super(key: key);

  @override
  State<edit_profile> createState() => _edit_profileState();
}

class _edit_profileState extends State<edit_profile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _about = TextEditingController();
  final TextEditingController designation = TextEditingController();
  final TextEditingController department = TextEditingController();
  String path = '';
  bool IsSelected = false;
  bool isworking = false;
  final maxlength = 5;
  var imagePath = '';
  var currentuserid;
  var args = Get.arguments;
  String? _designation;
  String? _department;
  List<String> tDesignation = [
    "Instructor",
    "Visiting Lecturer",
    "Lecturer",
    "Assistant Professor",
    "Associate Professor",
    "Professor",
  ];
  List<String> departments = [
    'Computer Science and IT',
    'Biological Science',
    'Chemistry',
    'Physics',
    'Business Administration',
    'Economics',
    'Education',
    'English',
    'Mathematics',
    'Psychology',
    'Social Work',
    'Sociology',
    'Sports Sciences',
    'Urdu'
  ];

  @override
  void initState() {
    super.initState();
    User? currentuser = FirebaseAuth.instance.currentUser;
    if (currentuser != null) {
      currentuserid = FirebaseAuth.instance.currentUser?.uid;
    }
    imagePath = args["imgUrl"].toString();
    _fullname.text = args['teacher_name'];
    _designation = args['designation'];
    _department = args['department'];
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      await FirebaseStorage.instance
          .ref('images/profile_pictures/$currentuserid.png')
          .putFile(file);
    } on FirebaseException catch (e) {
      Get.snackbar('Error occured.', '');
    }
  }

  Future<void> downloadURLfunc(cuserid) async {
    String imgurl = await FirebaseStorage.instance
        .ref('images/profile_pictures/$cuserid.png')
        .getDownloadURL();
    setState(() {
      imagePath = imgurl;
    });
  }

  Widget customtextformfield(lbltext, _controller, icon, isreadonly,
      {maxlength}) {
    return Padding(
      padding: const EdgeInsets.only(left: 35, right: 35, top: 15, bottom: 15),
      child: TextFormField(
          maxLines: maxlength,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (_val) {
            if (_val!.isEmpty) {
              return 'required';
            }
            return null;
          },
          readOnly: isreadonly,
          cursorColor: Colors.teal,
          controller: _controller,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: lbltext,
            labelStyle: const TextStyle(
              color: Colors.teal,
            ),
            filled: true,
            enabled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: const BorderSide(color: Colors.teal),
            ),
          )),
    );
  }

  Widget customdropdownformfield(fieldTitle, dropDownValue,
      List<String> listOfItems, onChangedFunc, ctx, icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 35, right: 35, top: 15, bottom: 15),
      child: DropdownButtonFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: fieldTitle,
            labelStyle: const TextStyle(
              color: Colors.teal,
            ),
            filled: true,
            enabled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: const BorderSide(color: Colors.teal),
            ),
          ),
          validator: (value) => value == null ? 'Required*' : null,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.grey,
          ),
          // hint: Text(
          //   'Select $fieldTitle',
          // ),
          value: dropDownValue,
          items: listOfItems.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChangedFunc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () {
            Navigator.pop(context);
          }),
          title: Center(
              child: customText(
            txt: "Edit Profile",
            fsize: 20.0,
          )),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: [
            IconButton(
              onPressed: () {
                customdialogcircularprogressindicator('Saving... ');
                if (IsSelected) {
                  uploadFile(imagePath).then((value) {
                    downloadURLfunc(currentuserid).then((value) {
                      FirebaseFirestore.instance
                          .collection('teachers')
                          .doc(currentuserid)
                          .set({
                        // 'isteacher': false,
                        'teacher_name': _fullname.text.trim(),
                        'designation': _designation,
                        'department': _department,
                        'imgUrl': imagePath.toString(),
                      }, SetOptions(merge: true)).then((value) {
                        Navigator.pop(context);
                        customtoast('Data Submitted');
                        Navigator.pop(context);
                      });
                    });
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('teachers')
                      .doc(currentuserid)
                      .set({
                    // 'isteacher': false,
                    'teacher_name': _fullname.text.trim(),
                    'designation': _designation,
                    'department': _department,
                  }, SetOptions(merge: true)).then((value) {
                    Navigator.pop(context);
                    customtoast('Data Submitted');
                    Navigator.pop(context);
                  });
                }
              },
              icon: const Icon(
                Icons.check,
              ),
            )
          ],
        ),
        body: ListView(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          ProfileWidget(
              imagePath: imagePath,
              onClicked: () {
                filepicker(filetype: FileType.image).then((selectedpath) {
                  if (selectedpath.toString().isNotEmpty) {
                    setState(() {
                      imagePath = selectedpath;
                      // imagePath = selectedpath;
                      IsSelected = true;
                    });
                  }
                });
              },
              icon: Icons.camera_enhance),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customtextformfield(
                  'Full Name',
                  _fullname,
                  Icons.edit,
                  false,
                ),
                customdropdownformfield(
                    "Designation", _designation, tDesignation, (value) {
                  setState(() {
                    _designation = value;
                  });
                }, context, Icons.workspace_premium_outlined),
                customdropdownformfield("Department", _department, departments,
                    (value) {
                  setState(() {
                    _department = value;
                  });
                }, context, FontAwesomeIcons.building),
                // customtextformfield('Designation', designation,
                //     Icons.workspace_premium_outlined, false),
                // customtextformfield(
                //     'Department', department, FontAwesomeIcons.building, false),
                // SizedBox(
                //     height: maxlength * 30.0,
                //     child: customtextformfield('About', _about,FontAwesomeIcons.circleInfo,false)),
              ],
            ),
          ),
        ]));
  }
}
