import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esl_survey/constants.dart';
import 'package:esl_survey/model/job_data.dart';
import 'package:esl_survey/model/survey_data.dart';
import 'package:esl_survey/screens/survey_screen.dart';
import 'package:esl_survey/components/job_tile.dart';

///
///Retrieves the list of jobs from JobData
///
class SelectionScreen extends StatefulWidget {
  static const String id = 'selectionScreen';

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  //JobData jobData = new JobData();

  ///clears the list of jobs in JobData
  void clearList() {
    Provider.of<JobData>(context, listen: false).clearList();
  }

  ///retrieves the list of jobs from firebase for the current user
  void getJobsListFromFirebase() {
    Provider.of<JobData>(context, listen: false).getJobsListFromFirebase();
  }

  ///gets the current user we await so our program doesn't skip ahead without setting the current user variable in SurveyData first
  Future<void> getCurrentUser() async {
    return await Provider.of<JobData>(context, listen: false).getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    //todo add further comments
    ///to add async inside build method we wrap the method inside the FutureBuilder() class set the future to be the method which returns the
    ///future, we but the code for the actual widget inside the builder Functions callback method like below
    return FutureBuilder<void>(
      future: getCurrentUser(),
      builder: (context, AsyncSnapshot<void> snapshot) {
        if (!(Provider.of<JobData>(context).isListPopulated)) {
          //add await to current user
          //getCurrentUser();
          ///clear the list and then get the new list from firebase each time we rebuild this screen/widget
          clearList();
          getJobsListFromFirebase();
          return CircularProgressIndicator();
        } else {
          return Consumer<JobData>(
            builder: (context, jobData, child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('ESL Services - Job List'),
                  backgroundColor: eslBlue,
                ),
                body: ListView.builder(
                  padding: EdgeInsets.only(left: 20, bottom: 20, right: 20),
                  itemBuilder: (context, index) {
                    //find way to log out/back as different user
                    //jobData.clearList();
                    //jobData.getJobsListFromFirebase();
                    //while (!jobData.listPoulated) {}
                    //sleep(const Duration(seconds: 5));
                    return JobTile(
                      title: jobData.jobs.elementAt(index).title,
                      subtitle: jobData.jobs.elementAt(index).subTitle,
                      onTapCallBack: () {
                        print('Job Selected: ' +
                            jobData.jobs.elementAt(index).title);

                        ///when tile is pressed set listPopulated to false so that SurveyScreen will call for the list to be repopulated from
                        ///firebase
                        Provider.of<SurveyData>(context, listen: false)
                            .setListPopulatedFalse();

                        ///push the survey screen onto the navigation stack add the job title as the argument
                        Navigator.pushNamed(context, SurveyScreen.id,
                            arguments: jobData.jobs.elementAt(index).title);
                      },
                    );
                  },
                  itemCount: jobData.taskCount,
                ),
              );
            },
          );
        }
      },
    );
  }
}
