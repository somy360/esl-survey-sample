import 'package:esl_survey/constants.dart';
import 'package:flutter/material.dart';
import 'package:esl_survey/model/job_data.dart';
import 'package:esl_survey/model/survey_data.dart';
import 'package:esl_survey/screens/selection_screen.dart';
import 'package:esl_survey/screens/survey_screen.dart';
import 'package:esl_survey/screens/welcome_screen.dart';
import 'package:esl_survey/screens/login_screen.dart';
import 'package:esl_survey/screens/registration_screen.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:flutter/services.dart';

void main() => runApp(EslSurvey());

class EslSurvey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //we can also use [SystemChrome] to set the orientations our app uses

    //set the statusbar and navigationbar colours
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: eslBlue,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: eslBlue,
        systemNavigationBarIconBrightness: Brightness.light));

    ///we can nest providers if using multiple models or use MultiProvider to do the same thing
    ///return our models for accessing data
    ///TODO: check why displaying data type <> after change notifier causes errors, which is correct implementation
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return JobData();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return SurveyData();
          },
        )
      ],
      //the start of our app, define routes for all our screens
      child: MaterialApp(
        routes: {
          SurveyScreen.id: (context) => SurveyScreen(),
          SelectionScreen.id: (context) => SelectionScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
        },
        //first route that will be shown on app start
        initialRoute: WelcomeScreen.id,
      ),
    );
  }
}
