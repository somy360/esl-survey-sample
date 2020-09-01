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
class ImageDetailsTile extends StatefulWidget {
  final String question;
  final String documentID;
  final String imageUrl;
  final String details;
  final String detailsHint;
  final String detailsTitle;

  //remember to access these immutable variables in our state object we use widget.hint etc
  ImageDetailsTile({
    @required this.question,
    this.documentID,
    this.imageUrl,
    this.details,
    this.detailsHint,
    this.detailsTitle,
  });

  @override
  _ImageCaptureTile createState() => _ImageCaptureTile();
}

/// mixin with [AutomaticKeepAliveClientMixin] keeps state of widget
class _ImageCaptureTile extends State<ImageDetailsTile>
    with AutomaticKeepAliveClientMixin {
  ///I had some issues getting this to work due to some null errors, not sure what the correct
  ///solution is but I'm just using this rare character to check if the variable has been changed
  String detailsTextFieldValue = 'ɔː';

  final FocusNode _focusNodeDetails = new FocusNode();

  File _image;
  final picker = ImagePicker();

  //we have to capture the context outside of the build method to be used by onFocusChange
  BuildContext currentContext;

  /// keeps the state of our widget alive even when it is off of the screen
  ///
  /// temporary fix for bug where our widget reset its state after going off screen
  /// TODO: analyse the performance of this and possibly look for a different solution
  @override
  bool get wantKeepAlive => true;

  ///we call initstate to add the listener to our focus node
  initState() {
    super.initState();
    _focusNodeDetails.addListener(_onDetailsFocusChange);
  }

  ///called when focus changes from details textField
  _onDetailsFocusChange() {
    //check it has been changed, check the user hasn't just deleted the previously stored value
    if (!(detailsTextFieldValue == 'ɔː') && !(detailsTextFieldValue == '')) {
      print('focus changed');
      Provider.of<SurveyData>(currentContext, listen: false)
          .addDetailsQuestionResultToFirebase(
              documentID: widget.documentID, content: detailsTextFieldValue);
    }
  }

  ///Get the image from the user using [image_picker] package then adds the image to firebase storage
  ///and the link to firebase database
  ///
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (!(pickedFile == null)) {
      setState(() {
        _image = File(pickedFile.path);
      });
      //remember we need to set the listen to false when we aren't listening for changes in the provider model
      Provider.of<SurveyData>(currentContext, listen: false)
          .addImageToFirebaseStorage(
              image: _image, documentID: widget.documentID);
    }
  }

  ///
  ///checks if our local image is available, if not checks if our network image is available,
  ///if not displays a button that when pressed gets an image from the camera
  ///
  ///Regarding buttons, I use three in this class, the one shown here, the onTap method of the ListTile
  ///and the onTap method of the trailing icon widget, probably it would be better to only use the listTile one
  ///partly a UI decision which to actually use though so at the moment I'm leaving all three until I decide on
  ///the best option.
  Widget _checkForImage() {
    if (!(_image == null)) {
      return Image.file(_image);
    } else if (!(widget.imageUrl == null)) {
      return Image.network(widget.imageUrl);
    } else {
      return FlatButton(
        color: Colors.lightBlue,
        onPressed: () {
          getImage();
        },
        child: Text(
          'Select an Image',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
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
            getImage();
          },
          //not sure if it looks cleaner without the icon as it takes a section of our widget
          //away
          trailing: FlatButton(
            onPressed: () {
              getImage();
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Container(
                height: 250,
                child: FlatButton(
                  onPressed: () {
                    getImage();
                  },
                  child: Center(
                    child: _checkForImage(),
                    //our old code, 99% sure we corrected it but just in case
                    // _image == null
                    //     ? FlatButton(
                    //         color: Colors.lightBlue,
                    //         onPressed: () {
                    //           getImage();
                    //         },
                    //         child: Text(
                    //           'Select an Image',
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //       )
                    //     : Image.file(_image),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.detailsTitle == null
                      ? 'Details/Notes:'
                      : widget.detailsTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Material(
                elevation: 5,
                shadowColor: Colors.black,
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.0),
                child: TextField(
                  style: TextStyle(fontSize: 20),
                  onChanged: (value) {
                    detailsTextFieldValue = value;
                  },
                  focusNode: _focusNodeDetails,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: widget.detailsHint == null
                        ? 'Please enter response'
                        : widget.detailsHint, //labelText: widget.hint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
