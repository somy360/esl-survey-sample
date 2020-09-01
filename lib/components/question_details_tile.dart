import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esl_survey/constants.dart';
import 'package:esl_survey/model/survey_data.dart';

///
///A Question tile with an extra TextField for additional information, for use in the survey screen
///
///Creates a tile with a 2 TextField's for getting user input, once the user finishes entering
///some input into a any textfield that info is sent back to SurveyData class to store it in our
///firebase database
///
class QuestionDetailsTile extends StatefulWidget {
  final String question;
  final String hint;
  final String details;
  final String detailsHint;
  final String detailsTitle;
  final String documentID;

  //remember to access these immutable variables in our state object we use widget.hint etc
  QuestionDetailsTile(
      {@required this.question,
      this.hint,
      this.documentID,
      this.details,
      this.detailsHint,
      this.detailsTitle});

  @override
  _QuestionDetailsTileState createState() => _QuestionDetailsTileState();
}

/// mixin with [AutomaticKeepAliveClientMixin] keeps state of widget
class _QuestionDetailsTileState extends State<QuestionDetailsTile>
    with AutomaticKeepAliveClientMixin {
  ///I had some issues getting this to work due to some null errors, not sure what the correct
  ///solution is but I'm just using this rare character to check if the variable has been changed
  String textFieldValue = 'ɔː';
  String detailsTextFieldValue = 'ɔː';

  final FocusNode _focusNodeQuestion = new FocusNode();
  final FocusNode _focusNodeDetails = new FocusNode();

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
    _focusNodeQuestion.addListener(_onQuestionFocusChange);
    _focusNodeDetails.addListener(_onDetailsFocusChange);
  }

  ///when the focus changes we add the previous focuses data to firestore
  _onQuestionFocusChange() {
    //check it has been changed, check the user hasn't just deleted the previously stored value
    if (!(textFieldValue == 'ɔː') && !(textFieldValue == '')) {
      print('focus changed');
      Provider.of<SurveyData>(currentContext, listen: false)
          .addQuestionResultToFirebase(
              documentID: widget.documentID, content: textFieldValue);
    }
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
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.question,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                    textFieldValue = value;
                  },
                  focusNode: _focusNodeQuestion,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: widget.hint == null
                        ? 'Please enter response'
                        : widget.hint,
                    //labelText: widget.hint,
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
