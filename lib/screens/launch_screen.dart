import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'excel_screen.dart';
// import 'sample.dart';
import '../shared/authentication.dart';
// import '../firebase_options.dart';


class LaunchScreen extends StatefulWidget {
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(),),
    );
  // @override
  // Widget build(BuildContext context) {
  //   final String imageLogoName = 'assets/images/public/PurpleLogo.svg';
  //
  //   var screenHeight = MediaQuery.of(context).size.height;
  //   var screenWidth = MediaQuery.of(context).size.width;
  //
  //   return WillPopScope(
  //     onWillPop: () async => false,
  //     child: MediaQuery(
  //       data: MediaQuery.of(context).copyWith(textScaleFactor:1.0),
  //       child: Scaffold(
  //         backgroundColor: hexToColor('#6F22D2'),
  //         body: Container(
  //           //height : MediaQuery.of(context).size.height,
  //           //color: kPrimaryColor,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: <Widget>[
  //               SizedBox(height: screenHeight * 0.384375),
  //               Container(
  //                 child: SvgPicture.asset(
  //                   imageLogoName,
  //                   width: screenWidth * 0.616666,
  //                   height: screenHeight * 0.0859375,
  //                 ),
  //               ),
  //               Expanded(child: SizedBox()),
  //               Align(
  //                 child: Text("© Copyright 2020, 내방니방(MRYR)",
  //                     style: TextStyle(
  //                       fontSize: screenWidth*( 14/360), color: Color.fromRGBO(255, 255, 255, 0.6),)
  //                 ),
  //               ),
  //               SizedBox( height: MediaQuery.of(context).size.height*0.0625,),
  //             ],
  //           ),
  //
  //         ),
  //       ),
  //     ),
  //   );
  }


  @override
  void initState() {
    super.initState();
    //await Firebase.initializeApp();
    Authentication auth = Authentication();

    auth.getUser().then((user) {
      MaterialPageRoute route;
      if (user != null) {
        route = MaterialPageRoute(builder: (context) => ExcelScreen([user.uid, user.email!]));
      }
      else {
        route = MaterialPageRoute(builder: (context) => LoginScreen());
      }
      Navigator.pushReplacement(context, route);
    }).catchError((err)=> print(err));
  }

}