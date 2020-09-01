import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esl_survey/constants.dart';

///
///A single job tile, for use in the job selection screen
///
class JobTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function onTapCallBack;

  JobTile({@required this.title, @required this.subtitle, this.onTapCallBack});

  @override
  Widget build(BuildContext context) {
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
          leading: Icon(
            Icons.assignment,
            color: Colors.white,
          ),
          title: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onTap: onTapCallBack,
        ),
      ),
    );
  }
}
