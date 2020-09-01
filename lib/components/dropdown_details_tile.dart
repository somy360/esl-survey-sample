import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esl_survey/constants.dart';
import 'package:esl_survey/model/survey_data.dart';

///
///A Dropdown Question tile with an Textfield for more details, for use in the survey screen
///
///
///
///
class DropdownDetailsTile extends StatefulWidget {
  final String question;
  final String hint;
  final String documentID;
  final List<String> listItems;
  final String details;
  final String detailsHint;
  final String detailsTitle;

  //remember to access these immutable variables in our state object we use widget.hint etc
  DropdownDetailsTile({
    @required this.question,
    this.hint,
    this.documentID,
    @required this.listItems,
    this.details,
    this.detailsHint,
    this.detailsTitle,
  });

  @override
  _DropdownDetailsTileState createState() => _DropdownDetailsTileState();
}

/// mixin with [AutomaticKeepAliveClientMixin] keeps state of widget
class _DropdownDetailsTileState extends State<DropdownDetailsTile>
    with AutomaticKeepAliveClientMixin {
  ///I had some issues getting this to work due to some null errors, not sure what the correct
  ///solution is but I'm just using this rare character to check if the variable has been changed
  String dropdownValue = 'ɔː';
  String detailsTextFieldValue = 'ɔː';

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
    _focusNodeDetails.addListener(_onDetailsFocusChange);

    print(widget.listItems.toString());
    widget.hint != null
        ? dropdownValue = widget.hint
        : dropdownValue = widget.listItems[0];
  }

  ///when the focus changes we add the previous focuses data to firestore
  _onValueChange() {
    //check it has been changed, check the user hasn't just deleted the previously stored value
    if (!(dropdownValue == 'ɔː') && !(dropdownValue == '')) {
      print('focus changed');
      Provider.of<SurveyData>(currentContext, listen: false)
          .addQuestionResultToFirebase(
              documentID: widget.documentID, content: dropdownValue);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Material(
                shadowColor: Colors.black,
                elevation: 5,
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DropdownButton(
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      iconEnabledColor: eslBlue,
                      //get rid of underline
                      underline: Text(''),
                      //put the text to left icon to right
                      isExpanded: true,
                      iconSize: 40,
                      elevation: 20,
                      value: dropdownValue,
                      items: widget.listItems
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                        _onValueChange();
                      },
                    ),
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
