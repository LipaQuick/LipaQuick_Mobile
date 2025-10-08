import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';


class SuccessPage extends StatelessWidget {
  final VoidCallback positiveCallback;
  final VoidCallback negativeCallback;
  final ContactsAPI receiverDetails;
  final UserDetails senderDetails;
  final String tranReferenceNumber;
  final String? positiveButton;
  final String? negativeButton;
  final IconData icon;

  const SuccessPage({Key? key, required this.positiveCallback, required this.negativeCallback
    , required this.receiverDetails
    , required this.senderDetails
    , required this.tranReferenceNumber
    , required this.icon, this.positiveButton, this.negativeButton }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(icon);
    final TextStyle headline2 = Theme.of(context).textTheme.displayMedium!;
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ));
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Padding(padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Icon(
                  icon,
                  size: 90,
                  color: appGreen400,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
            gradient: LinearGradient(
            begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x8be3ffe7),
                  Color(0x8be3ffe7)
                ]
            )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To',
                    style: GoogleFonts.poppins(
                        textStyle: headline2.copyWith(fontSize: 21, fontWeight: FontWeight.bold, color: appSurfaceBlack)),
                    textAlign: TextAlign.center,
                  ),
                  UserDetailsWidget(profilePicture: receiverDetails.profilePicture
                      , name: receiverDetails.name
                      , phoneNumber: receiverDetails.phoneNumber),
                  const SizedBox(height: 20),
                  Text(
                    'From',
                    style: GoogleFonts.poppins(
                        textStyle: headline2.copyWith(fontSize: 21, fontWeight: FontWeight.bold, color: appSurfaceBlack)),
                    textAlign: TextAlign.center,
                  ),
                  UserDetailsWidget(profilePicture: senderDetails.profilePicture
                      , name: '${senderDetails.firstName} ${senderDetails.lastName}'
                      , phoneNumber: senderDetails.phoneNumber),
                  const SizedBox(height: 20),
                  Text(
                    'Transaction Details',
                    style: GoogleFonts.poppins(
                        textStyle: headline2.copyWith(fontSize: 21, fontWeight: FontWeight.bold, color: appSurfaceBlack)),
                    textAlign: TextAlign.center,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(
                        "Transaction Ref No.: $tranReferenceNumber",
                        style: GoogleFonts.poppins(
                            textStyle: headline2.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: appSurfaceBlack)),
                      ),
                      SizedBox(height: 5),
                      Text(
                        DateFormat('h:mm a, y/M/d').format(DateTime.now()),//"06:52 PM, 17 July 2022",
                        style: GoogleFonts.poppins(
                            textStyle: headline2.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff999999)))
                        ,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Visibility(visible: negativeButton != null,child: DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                padding: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    height: 35,
                    width: 150,
                    alignment: Alignment.center,
                    child: TextButton(
                        onPressed: () {
                          negativeCallback();
                        },
                        child: Text(negativeButton!,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: appSurfaceBlack,
                                fontWeight: FontWeight.w600))),
                  ),
                ),
              )),
            ),
            Center(
              child: Visibility(visible: positiveButton != null,child: ElevatedButton(
                style: style,
                onPressed: (){positiveCallback();},
                child: Text(positiveButton!,
                    style: GoogleFonts.poppins(
                        textStyle: headline2.copyWith(fontSize: 19,fontWeight: FontWeight.bold, color: Colors.white))),
              ),),
            ),
          ],
        ),),
      ),
    );
  }
}

class UserDetailsWidget extends StatelessWidget {
  const UserDetailsWidget({
  super.key,
  this.profilePicture,
  this.name,
  this.phoneNumber
  });
  final String? profilePicture, name, phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Padding(padding: EdgeInsets.all(5), child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.width/6,
        child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Container(
                width: 50,
                height: 50,
                child: CircleAvatar(
                  backgroundColor: appGrey100,
                  child: profilePicture != null
                      ? ImageUtil().imageFromBase64String(ImageUtil().getBase64Logo(profilePicture!), 50, 50)
                      : const Icon(Icons.question_mark),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        name!,
                        style: GoogleFonts.poppins(color: appSurfaceBlack,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        phoneNumber!,
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
      ),),
    );
  }
}