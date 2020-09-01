import 'package:flutter/material.dart';
import 'job.dart';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore _firestore = Firestore.instance;
FirebaseUser loggedInUser;

///
/// Deals with all communication with firebase for our list of jobs for the
/// logged in User
///
/// A Provider
///
class JobData extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool listPopulated = false;
  bool listClear = false;

  ///A sample list of jobs, can leave empty in the future
  List<Job> _jobs = [
    Job(title: 'McDonalds', subTitle: 'short description'),
    Job(title: 'Pets At Home', subTitle: 'short description'),
    Job(title: 'Londis', subTitle: 'short description'),
    Job(title: 'Tesco', subTitle: 'short description'),
    Job(title: 'Asda', subTitle: 'short description'),
    Job(title: 'Saisburys', subTitle: 'short description'),
    Job(title: 'Lidl', subTitle: 'short description'),
    Job(title: 'Aldi', subTitle: 'short description'),
  ];

  ///get the current user when the object is created
  ///unnecessary since we call the method manually later???
  JobData() {
    getCurrentUser();
  }

  ///clear the joblist
  ///maybe we don't need the listClear variable????
  void clearList() {
    _jobs.clear();
    listClear = true;
  }

  ///return a future if we are successful at setting the current user
  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();

      if (user != null) {
        loggedInUser = user;
        //getJobsListFromFirebase();
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  ///return an unmodifable version of the list so we can't mess about with the list by accident
  UnmodifiableListView<Job> get jobs {
    return UnmodifiableListView(_jobs);
  }

  ///getter for listClear
  bool get isListCleared {
    return listClear;
  }

  ///returns the number of jobs in the list
  int get taskCount {
    return _jobs.length;
  }

  ///getter for if list is populated
  bool get isListPopulated {
    return listPopulated;
  }

  ///add a new job to the list of jobs
  ///notifly our listeners to this provider
  void addToList({String title, String subTitle}) {
    final job = Job(title: title, subTitle: subTitle);
    _jobs.add(job);
    notifyListeners();
  }

  ///get the list of jobs from firebase and store them in our list
  getJobsListFromFirebase() {
    //while there is no user loop forever
    //TODO: Fix
    while (_auth.currentUser() == null) {}
    print(loggedInUser.email);

    ///accessing firestore
    _firestore
        .collection(loggedInUser.email)
//        .orderBy('dateCreated', descending: false)
        .snapshots()
        .forEach((element) {
      element.documents.forEach((element) {
        print(element.data['subTitle']);
        addToList(
            title: element.data['title'], subTitle: element.data['subTitle']);
      });
    });

    ///set the list to
    listPopulated = true;
  }
}
