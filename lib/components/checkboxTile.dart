import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esl_survey/constants.dart';
import 'package:esl_survey/model/survey_data.dart';

///
///A Yes/No checkbox tile, for use in the survey screen
///
///Creates a tile with a question and a yes and no checkbox which can be toggled betwween
///initial state both are false
///
class CheckboxTile extends StatefulWidget {
  final String question;
  final bool hint;
  final String documentID;

  //remember to access these immutable variables in our state object we use widget.hint etc
  CheckboxTile({
    @required this.question,
    this.hint,
    this.documentID,
  });

  @override
  _CheckboxTileState createState() => _CheckboxTileState();
}

/// mixin with [AutomaticKeepAliveClientMixin] keeps state of widget
class _CheckboxTileState extends State<CheckboxTile>
    with AutomaticKeepAliveClientMixin {
  bool yesBoxValue;
  bool noBoxValue;

  //we have to capture the context outside of the build method to be used by onFocusChange
  BuildContext currentContext;

  /// keeps the state of our widget alive even when it is off of the screen
  ///
  /// temporary fix for bug where our widget reset its state after going off screen
  /// TODO: analyse the performance of this and possibly look for a different solution
  @override
  bool get wantKeepAlive => true;

  /// if the hint is null (ie there is no content set in firebase yet) then we set
  /// both to false, otherwise we set [yesBoxValue] to the hint and [noBoxValue] to
  /// !hint
  initState() {
    super.initState();
    if (widget.hint == null) {
      yesBoxValue = false;
      noBoxValue = false;
    } else {
      yesBoxValue = widget.hint;
      noBoxValue = !widget.hint;
    }
  }

  ///when the focus changes we add the previous focuses data to firestore
  _onValueChange() {
    //check it has been changed, check the user hasn't just deleted the previously stored value
    print('focus changed');
    Provider.of<SurveyData>(currentContext, listen: false)
        .addQuestionResultToFirebase(
            documentID: widget.documentID, content: yesBoxValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    //super.build(context);
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
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Yes:',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Checkbox(
                          activeColor: eslBlue,
                          value: yesBoxValue,
                          onChanged: (value) {
                            setState(
                              () {
                                yesBoxValue = value;
                                noBoxValue = !value;
                              },
                            );
                            _onValueChange();
                          },
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'No:',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Checkbox(
                          activeColor: eslBlue,
                          value: noBoxValue,
                          onChanged: (value) {
                            setState(
                              () {
                                noBoxValue = value;
                                yesBoxValue = !value;
                              },
                            );
                            _onValueChange();
                          },
                        )
                      ],
                    ),
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
