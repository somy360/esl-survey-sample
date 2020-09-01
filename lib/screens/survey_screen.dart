import 'package:esl_survey/model/survey_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

///Survey screen for displaying the list of widgets we get from our SurveyData model
class SurveyScreen extends StatefulWidget {
  static const String id = 'surveyScreen';

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  void clearList() {
    Provider.of<SurveyData>(context, listen: false).clearList();
  }

  void getSurveyListFromFirebase(String jobTitle) {
    Provider.of<SurveyData>(context, listen: false)
        .getSurveyListFromFirebase(jobTitle: jobTitle);
  }

  @override
  Widget build(BuildContext context) {
    //TODO: add comments
    return FutureBuilder<void>(
      future: Provider.of<SurveyData>(context, listen: false).getCurrentUser(),
      builder: (context, AsyncSnapshot<void> snapshot) {
        if (!(Provider.of<SurveyData>(context).isListPopulated)) {
          clearList();
          String jobTitle = ModalRoute.of(context).settings.arguments;
          getSurveyListFromFirebase(jobTitle);
          return CircularProgressIndicator();
        } else {
          return Consumer<SurveyData>(
            builder: (context, surveyData, child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('ESL Services - Survey'),
                  backgroundColor: eslBlue,
                ),
                body: ListView.builder(
                  padding: EdgeInsets.only(left: 20, bottom: 20, right: 20),
                  itemBuilder: (context, index) {
                    //list view of the widgets in our survery list
                    return surveyData.survey.elementAt(index);
                  },
                  itemCount: surveyData.taskCount,
                ),
              );
            },
          );
        }
      },
    );
  }
}

//store results as csv????
