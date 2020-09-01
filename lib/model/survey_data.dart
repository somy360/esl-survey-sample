import 'dart:io';
import 'package:esl_survey/components/checkboxTile.dart';
import 'package:esl_survey/components/checkbox_details_tile.dart';
import 'package:esl_survey/components/dropdown_details_tile.dart';
import 'package:esl_survey/components/image_capture_tile.dart';
import 'package:esl_survey/components/image_details_tile.dart';
import 'package:esl_survey/components/multi_image_tile.dart';
import 'package:esl_survey/components/question_details_tile.dart';
import 'package:esl_survey/components/question_tile.dart';
import 'package:esl_survey/components/dropdown_tile.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

final Firestore _firestore = Firestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;
FirebaseUser loggedInUser;

///
///Deals with all communication with firebase for our individual survey
///
///A provider
///
class SurveyData extends ChangeNotifier {
  //TODO: Check we need all these variables
  final _auth = FirebaseAuth.instance;
  String selectedJobTitle;
  bool listPopulated = false;
  bool listClear = false;

  //I like to keep 1 item in the list just as an example but it is redundant and is
  //cleared everytime
  List<Widget> _survey = [
    //JobTile(title: 'McDonalds', subtitle: 'short description'),
  ];

  ///Constructor
  ///
  ///We almost definitely don't need this
  ///TODO: check if getCurrentUser is neccessary
  SurveyData() {
    getCurrentUser();
  }

  ///clears the list then sets our flag to true
  ///
  ///TODO: check if listClear flag is actually needed, 99% sure it is not
  clearList() {
    _survey.clear();
    listClear = true;
  }

  ///
  ///Check for the current user
  ///
  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();

      if (user != null) {
        loggedInUser = user;
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  ///
  ///getter for the surveyList, unmodifiable for safety
  ///
  UnmodifiableListView<Widget> get survey {
    return UnmodifiableListView(_survey);
  }

  ///Selected Job getter
  String get getSelectedJobTitle {
    return selectedJobTitle;
  }

  ///Has List cleared previously been called
  ///
  ///TODO: delete this method 99% sure
  bool get isListCleared {
    return listClear;
  }

  ///number of items in the surveylist
  ///
  ///TODO: refactor-rename this method
  int get taskCount {
    return _survey.length;
  }

  ///has the list been populated from firebase
  ///
  ///TODO: check if we are actually using this, not sure we are
  bool get isListPopulated {
    return listPopulated;
  }

  ///set list populated to false
  ///
  ///TODO: check if we can delete, 99% sure this isn't used
  setListPopulatedFalse() {
    listPopulated = false;
    notifyListeners();
  }

  /// add a widget to the survey and notify listeners to rebuild the screen
  _addToSurvey(Widget widget) {
    if (listPopulated == false) {
      _survey.add(widget);
      notifyListeners();
    }
  }

  ///
  ///Add a question tile to the survey list
  ///
  addQuestionTileToList(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    final questionTile = QuestionTile(
      question: element.data['Question'],
      documentID: docID,
      hint: element.data['Content'],
    );
    _addToSurvey(questionTile);
  }

  ///
  ///add the users response to firebase
  ///
  ///adds 'content' to the document 'documentID' to the field 'Content'
  ///
  addQuestionResultToFirebase({String documentID, String content}) {
    print('test');
    print(documentID + ': ' + content);
    //add content to firebase
    _firestore
        .collection(loggedInUser.email)
        .document(getSelectedJobTitle)
        .collection('WidgetList')
        .document(documentID)
        .setData({
      'Content': content,
    }, merge: true);
  }

  ///
  ///Add imageCaptureTile to the Survey list
  ///
  addImageCaptureTileToList(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    final imageCaptureTile = ImageCaptureTile(
      question: element.data['Question'],
      imageUrl: element.data['ImageUrl'],
      documentID: docID,
    );
    _addToSurvey(imageCaptureTile);
  }

  ///
  ///add image to firebase storage then save the location to firebase firestore
  ///
  Future addImageToFirebaseStorage({File image, String documentID}) async {
    //uuid to create a unique id for our image
    var uuid = Uuid();

    //Create a reference to the location you want to upload to in firebase
    StorageReference reference = _storage
        .ref()
        .child("ESL_Survey_Images/" + loggedInUser.email + '/' + uuid.v1());

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putFile(image);

    // Waits till the file is uploaded then stores the download url in firestore
    await uploadTask.onComplete;
    reference.getDownloadURL().then((fileURL) {
      _firestore
          .collection(loggedInUser.email)
          .document(getSelectedJobTitle)
          .collection('WidgetList')
          .document(documentID)
          .setData({
        'ImageUrl': fileURL,
      }, merge: true);
    });
  }

  // creates a dropdownlist widget and then adds it to the survey list
  addDropdownQuestionToList(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    //we have to declare listItems as dynamic because the array we get from firebase
    //will always be dynamic
    List<dynamic> listItems = element.data['ListItems'];

    final dropdownTile = DropdownTile(
      question: element.data['Question'],
      documentID: docID,
      hint: element.data['Content'],
      //we cast the array to type String since we know our values are always strings
      listItems: listItems.cast<String>(),
    );
    _addToSurvey(dropdownTile);
  }

  // creates a checkboxTile widget and then adds it to the survey list
  addCheckBoxQuestion(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    //when we add data to firebase it automatically is stored as a String so we
    //need to convert it back to a bool for out widget
    bool contentBool;
    String contentString = element.data['Content'];
    if (contentString == null) {
    } else {
      if (contentString == 'true') {
        contentBool = true;
      } else {
        contentBool = false;
      }
    }

    final checkboxTile = CheckboxTile(
      question: element.data['Question'],
      documentID: docID,
      hint: contentBool,
    );
    _addToSurvey(checkboxTile);
  }

  ///
  /// Add the value of the checkbox (true or false) to the corresponding firebase
  /// document
  ///
  /// note: probably would be better to create a data object so we can add the bool
  /// to it and then in turn add that object to firebase. Not sure though and this
  /// is simple enough to convert back when we pull from firebase
  ///
  addCheckboxResultToFirebase({String documentID, bool content}) {
    print('test');
    print(documentID + ': ' + content.toString());
    //add content to firebase
    _firestore
        .collection(loggedInUser.email)
        .document(getSelectedJobTitle)
        .collection('WidgetList')
        .document(documentID)
        .setData({
      'Content': content,
    }, merge: true);
  }

  // creates a checkboxTile widget and then adds it to the survey list
  addDetailsQuestion(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    final detailsTile = QuestionDetailsTile(
      question: element.data['Question'],
      documentID: docID,
      hint: element.data['Content'],
      detailsHint: element.data['DetailsContent'],
      detailsTitle: element.data['DetailsTitle'],
    );
    _addToSurvey(detailsTile);
  }

  addCheckBoxDetailsQuestion(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    //when we add data to firebase it automatically is stored as a String so we
    //need to convert it back to a bool for out widget
    bool contentBool;
    String contentString = element.data['Content'];
    if (contentString == null) {
    } else {
      if (contentString == 'true') {
        contentBool = true;
      } else {
        contentBool = false;
      }
    }

    final checkboxDetailsTile = CheckboxDetailsTile(
      question: element.data['Question'],
      documentID: docID,
      hint: contentBool,
      detailsHint: element.data['DetailsContent'],
      detailsTitle: element.data['DetailsTitle'],
    );
    _addToSurvey(checkboxDetailsTile);
  }

  ///
  ///add the users response to firebase
  ///
  ///adds 'content' to the document 'documentID' to the field 'Content'
  ///
  addDetailsQuestionResultToFirebase({String documentID, String content}) {
    print('test');
    print(documentID + ': ' + content);
    //add content to firebase
    _firestore
        .collection(loggedInUser.email)
        .document(getSelectedJobTitle)
        .collection('WidgetList')
        .document(documentID)
        .setData({
      'DetailsContent': content,
    }, merge: true);
    //setListPopulatedFalse();
  }

  // creates a dropdownlist widget and then adds it to the survey list
  addDropdownDetailsQuestionToList(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    //we have to declare listItems as dynamic because the array we get from firebase
    //will always be dynamic
    List<dynamic> listItems = element.data['ListItems'];

    final dropdownDetailsTile = DropdownDetailsTile(
      question: element.data['Question'],
      documentID: docID,
      hint: element.data['Content'],
      //we cast the array to type String since we know our values are always strings
      listItems: listItems.cast<String>(),
      detailsHint: element.data['DetailsContent'],
      detailsTitle: element.data['DetailsTitle'],
    );
    _addToSurvey(dropdownDetailsTile);
  }

  ///
  ///Add imageCaptureTile to the Survey list
  ///
  addImageDetailTileToList(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;

    final imageCaptureTile = ImageDetailsTile(
      question: element.data['Question'],
      imageUrl: element.data['ImageUrl'],
      documentID: docID,
      detailsHint: element.data['DetailsContent'],
      detailsTitle: element.data['DetailsTitle'],
    );
    _addToSurvey(imageCaptureTile);
  }

  ///
  ///Add imageCaptureTile to the Survey list
  ///
  addMultiImageTileToList(DocumentSnapshot element) {
    //we can use this to get the id of the document
    String docID = element.documentID;
    List<dynamic> imageUrls = element.data['imageUrls'];
    // List<String> list = new List();
    // for (int i = 0; i < 6; i++) {
    //   list.add(null);
    // }

    final multiImageTile = MultiImageTile(
      question: element.data['Question'],
      imageUrl: element.data['ImageUrl'],
      documentID: docID,
      urlList: imageUrls,
    );
    _addToSurvey(multiImageTile);
  }

  ///
  ///add image to firebase storage then save the location to firebase firestore
  ///
  Future<String> addMultiImageToFirebaseStorage(
      {File image, String documentID}) async {
    //uuid to create a unique id for our image
    var uuid = Uuid();

    //Create a reference to the location you want to upload to in firebase
    StorageReference reference = _storage
        .ref()
        .child("ESL_Survey_Images/" + loggedInUser.email + '/' + uuid.v1());

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putFile(image);
    dynamic newFileUrl;

    // Waits till the file is uploaded then stores the download url in firestore
    await uploadTask.onComplete;
    await reference.getDownloadURL().then((fileURL) {
      newFileUrl = fileURL.toString();
      List<dynamic> list = new List();
      list.add(fileURL);
      _firestore
          .collection(loggedInUser.email)
          .document(getSelectedJobTitle)
          .collection('WidgetList')
          .document(documentID)
          .updateData({
        'imageUrls': FieldValue.arrayUnion(list),
      });
    });
    //bug with newFileUrl
    print(newFileUrl);
    return newFileUrl;
  }

  removeMultiImageFromFirebaseStorage({String imageUrl, String documentID}) {
    List<dynamic> list = new List();
    list.add(imageUrl);
    _firestore
        .collection(loggedInUser.email)
        .document(getSelectedJobTitle)
        .collection('WidgetList')
        .document(documentID)
        .updateData({
      'imageUrls': FieldValue.arrayRemove(list),
    });
  }

  ///gets the survey list from Firebase for a specific job
  getSurveyListFromFirebase({String jobTitle}) async {
    selectedJobTitle = jobTitle;
    print(loggedInUser.email);
    //TODO: Fix
    while (_auth.currentUser() == null) {
      print('user null');
    }

    //we are opening some kind of infinite stream that keeps pulling whenever data is changed in database
    if (listPopulated == false) {
      //old version created a stream that got updated everytime we changed the data on firebase, caused some issues
      // _firestore
      //     .collection(loggedInUser.email)
      //     .document(jobTitle)
      //     .collection('WidgetList')
      //     //we have a parameter on each document which is a simple integer, we use it to order the widgets correctly
      //     //TODO: think this causes an issue with displaying the list originally, need to check
      //     .orderBy('Order')
      //     .snapshots()
      //     .forEach((element) {
      //   element.documents.forEach((element) {
      //     getWidgetType(element);
      //   });
      // });
      QuerySnapshot querySnapshot = await _firestore
          .collection(loggedInUser.email)
          .document(jobTitle)
          .collection('WidgetList')
          .orderBy('Order')
          .getDocuments();
      for (int i = 0; i < querySnapshot.documents.length; i++) {
        var a = querySnapshot.documents[i];
        getWidgetType(a);
      }
    }
    listPopulated = true;
  }

  ///get the type of widget
  getWidgetType(DocumentSnapshot element) {
    switch (element.data['WidgetType']) {
      case 'simpleQuestion':
        {
          addQuestionTileToList(element);
        }
        break;
      case 'imageCapture':
        {
          addImageCaptureTileToList(element);
        }
        break;
      case 'dropdownQuestion':
        {
          addDropdownQuestionToList(element);
        }
        break;
      case 'checkboxQuestion':
        {
          addCheckBoxQuestion(element);
        }
        break;
      case 'detailsQuestion':
        {
          addDetailsQuestion(element);
        }
        break;
      case 'checkboxDetails':
        {
          addCheckBoxDetailsQuestion(element);
        }
        break;
      case 'dropdownDetails':
        {
          addDropdownDetailsQuestionToList(element);
        }
        break;
      case 'imageDetails':
        {
          addImageDetailTileToList(element);
        }
        break;
      case 'multiImage':
        {
          addMultiImageTileToList(element);
        }
        break;
    }
  }
}
