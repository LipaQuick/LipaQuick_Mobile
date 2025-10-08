import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/core/models/profile/profile_item_model.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/privacy/change_password.dart';
import 'package:lipa_quick/ui/views/user_profile/customer_profile_details.dart';

class PrivacyPage extends StatefulWidget {
  final AccountViewModel _viewModel = locator<AccountViewModel>();
  final ProfileDetailsResponse? userDetails;

  PrivacyPage(this.userDetails, {Key? key}) : super(key: key);

  @override
  PrivacyPageState createState() => PrivacyPageState();
}

class PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTheme.getAppBar(
            context: context, title: "", subTitle: "", enableBack: true),
        body: FutureBuilder<List<ProfileItemModels>>(
          future: widget._viewModel.getPrivacyList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(flex: 1, child: _getProfileListView(snapshot.data))
                ],
              );
            } else {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: appBackgroundBlack200,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: appSurfaceWhite,
                        borderRadius: BorderRadius.circular(20)),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              );
            }
          },
        ));
  }

  ListTile _tile(ProfileItemModels models) => ListTile(
        dense: true,
        title: Text(models.title,
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        subtitle: Text(models.subTitle,
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400)),
        leading: Container(
          decoration: BoxDecoration(
              color: Color(models.parentColorCode),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          padding: const EdgeInsets.all(10),
          child: Icon(
            models.icon,
            color: Color(models.iconColorCode),
          ),
        ),
      );

  Widget _getProfileListView(List<ProfileItemModels>? data) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: data!.length,
        itemBuilder: (context, index) {
          // print('Build List Item${_tile(data[index]).title}');
          return GestureDetector(
            onTap: () {
              onListItemTap(context, index, widget.userDetails!);
            },
            child: Card(
              color: Colors.white,
              child: _tile(data[index]),
            ),
          );
        });
  }
}

void onListItemTap(BuildContext context, int data, ProfileDetailsResponse detailsResponse) {
  switch (data) {
    case 0:
      //TODO Launch Profile Details page.

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserDetails(detailsResponse),
              settings: const RouteSettings(name: 'UserDetails')));
      break;
      case 1:
      //TODO Launch Change Password page.
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ChangePasswordPage(),
                settings: const RouteSettings(name: 'PrivacyPage')));
      break;
  }
}
