import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/models/user.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDrawerHeader extends StatefulWidget {
  const MainDrawerHeader({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawerHeader> {
  late SharedPreferences sharedPreferences;
  var userModel = UserDetails.initial();

  @override
  void initState() {
    //fetchDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return FutureBuilder<UserDetails>(
        future: fetchDetails(),
        builder: (context, snapshot){
          return SizedBox(
            height: height/5.8,
            child: DrawerHeader(
              child: RefreshIndicator(
                onRefresh: () async {},
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: !snapshot.hasData
                      ? const CircularProgressIndicator()
                      : SizedBox(
                            width: double.infinity,
                            height: height/2,
                            child: Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                              Container(
                                width: 50,
                                height: 50,
                                child: Card(
                                  child: userModel.profilePicture != null &&
                                      userModel.profilePicture.isNotEmpty
                                      ? ImageUtil().imageFromBase64String(userModel.getProfilePictureLogo(), 40, 40)
                                      : const Icon(Icons.question_mark),
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        userModel.firstName+' '+userModel.lastName,
                                        style: GoogleFonts.poppins(color: appSurfaceBlack,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600,),
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        userModel.email.isEmpty?userModel.phoneNumber:userModel.email,
                                        style: GoogleFonts.poppins(color: Color(0xff535763),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ]
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Row buildHeaderBottomRow(UserDetailsModel value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            "Branch Name",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        GestureDetector(
          onTap: _launchAddBank,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<UserDetails>? fetchDetails() async {
    final Completer<UserDetails> completer =
    Completer<UserDetails>();
    var prefs = await SharedPreferences.getInstance();
    //print('Checking User Details ${prefs.getString('userDetails')}');
    // print('Null Preference, Loading Default EN');
    String rawData = prefs.getString("userDetails")!;
    //print('Raw Data Print: $rawData');
    var data = jsonDecode(rawData);
    //print('JSON Decode Data Print: $data');
    //print(data);
    userModel = UserDetails.fromJson(data);
    completer.complete(userModel);
    return completer.future;
  }


  jsonStringToMap(String data) {
    List<String> str = data
        .replaceAll("{", "")
        .replaceAll("}", "")
        .replaceAll("\"", "")
        .replaceAll("'", "")
        .split(",");
    Map<String, dynamic> result = {};
    for (int i = 0; i < str.length; i++) {
      List<String> s = str[i].split(":");
      result.putIfAbsent(s[0].trim(), () => s[1].trim());
    }
    return result;
  }

  void _launchAddBank() {

  }
}
