import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:esl_survey/constants.dart';
import 'package:esl_survey/model/survey_data.dart';

///
///An Image Capture Tile tile, for use in the survey screen.
///
///Creates a tile with some text and an option to capture an image from the users camera.
///
class MultiImageTile extends StatefulWidget {
  final String question;
  final String documentID;
  final String imageUrl;
  final List<dynamic> urlList;

  //remember to access these immutable variables in our state object we use widget.hint etc
  MultiImageTile(
      {@required this.question, this.documentID, this.imageUrl, this.urlList});

  @override
  _ImageCaptureTile createState() => _ImageCaptureTile();
}

/// mixin with [AutomaticKeepAliveClientMixin] keeps state of widget
class _ImageCaptureTile extends State<MultiImageTile>
    with AutomaticKeepAliveClientMixin {
  ///I had some issues getting this to work due to some null errors, not sure what the correct
  ///solution is but I'm just using this rare character to check if the variable has been changed

  List<File> _image = new List<File>();
  List<dynamic> listOfUrls;
  final picker = ImagePicker();

  //we have to capture the context outside of the build method to be used by onFocusChange
  BuildContext currentContext;

  /// keeps the state of our widget alive even when it is off of the screen
  ///
  /// temporary fix for bug where our widget reset its state after going off screen
  /// TODO: analyse the performance of this and possibly look for a different solution
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!(widget.urlList == null)) {
      listOfUrls = widget.urlList;
      for (int i = 0; i < listOfUrls.length; i++) {
        _image.add(null);
      }
    } else {
      listOfUrls = new List();
      listOfUrls.add(null);
      listOfUrls.add(null);
      for (int i = 0; i < 2; i++) {
        _image.add(null);
      }
    }
    print(listOfUrls.length);
    print(_image.length);
  }

  ///Get the image from the user using [image_picker] package then adds the image to firebase storage
  ///and the link to firebase database
  ///
  Future getImage(int i, String imgUrl) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (!(pickedFile == null)) {
      setState(() {
        _image.replaceRange(i, i + 1, [File(pickedFile.path)]);
      });
      //remember we need to set the listen to false when we aren't listening for changes in the provider model
      Provider.of<SurveyData>(currentContext, listen: false)
          .addMultiImageToFirebaseStorage(
              image: _image.elementAt(i), documentID: widget.documentID);
    }
  }

  ///Get the image from the user using [image_picker] package then adds the image to firebase storage
  ///and the link to firebase database
  ///
  Future getNewImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (!(pickedFile == null)) {
      //remember we need to set the listen to false when we aren't listening for changes in the provider model
      String newUrl =
          await Provider.of<SurveyData>(currentContext, listen: false)
              .addMultiImageToFirebaseStorage(
                  image: File(pickedFile.path), documentID: widget.documentID);
      listOfUrls.add(newUrl.toString()); //TODO:newurl is null
      setState(() {
        _image.add(File(pickedFile.path));
      });
    }
    print('url length: ' + listOfUrls.length.toString());
    print('_image length: ' + _image.length.toString());
  }

  ///
  ///checks if our local image is available, if not checks if our network image is available,
  ///if not displays a button that when pressed gets an image from the camera
  ///
  ///Regarding buttons, I use three in this class, the one shown here, the onTap method of the ListTile
  ///and the onTap method of the trailing icon widget, probably it would be better to only use the listTile one
  ///partly a UI decision which to actually use though so at the moment I'm leaving all three until I decide on
  ///the best option.
  Widget _checkForImage(int i, String imageUrl) {
    if (!(_image.elementAt(i) == null)) {
      return Image.file(_image.elementAt(i));
    } else if (!(listOfUrls.elementAt(i) == null)) {
      return Image.network(listOfUrls.elementAt(i));
    } else {
      return FlatButton(
        color: Colors.lightBlue,
        onPressed: () {
          getImage(i, imageUrl);
        },
        child: Text(
          'Select an Image',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  removeImage(int i) {
    //might need replace with null
    print(listOfUrls.elementAt(i));
    Provider.of<SurveyData>(currentContext, listen: false)
        .removeMultiImageFromFirebaseStorage(
            imageUrl: listOfUrls.elementAt(i), documentID: widget.documentID);
    listOfUrls.removeAt(i);
    setState(() {
      _image.removeAt(i);
    });
  }

  List<Widget> imageList() {
    List<Widget> list = new List();
    int listSize = listOfUrls == null ? 2 : listOfUrls.length;
    for (int i = 0; i < listSize; i++) {
      list.add(
        Container(
          //height: 150,
          //padding: const EdgeInsets.all(8),
          child: FlatButton(
            onLongPress: () {
              removeImage(i);
            },
            onPressed: () {
              //originally this would have replaced the old image with a new one
              //but I will just leave it that longpress removes the image and pressing
              //on the tile adds a new image, it's simple for the user and less
              //work for me
              // removeImage(i);
              // getImage(i, listOfUrls == null ? null : listOfUrls.elementAt(i));
            },
            child: Center(
              child: _checkForImage(
                  i, listOfUrls == null ? null : listOfUrls.elementAt(i)),
            ),
          ),
        ),
      );
    }
    return list;
  }

  ///returns a very simple list tile
  @override
  Widget build(BuildContext context) {
    super.build(context);
    currentContext = context;
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: eslBlue,
          shape: BoxShape.rectangle,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(20),
          onTap: () {
            getNewImage();
          },
          trailing: FlatButton(
            onPressed: () {
              getNewImage();
            },
            child: Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              //added a some spaces so the text lines up better
              widget.question,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          subtitle: Container(
            padding: EdgeInsets.only(top: 5),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: imageList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// get list of all url's from firebase somehow
/// as we loop to create the Url's use the size of list for number of times to loop
/// and grab the imageUrl from the list at the current index
