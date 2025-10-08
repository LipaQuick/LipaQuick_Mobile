import 'package:flutter/material.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';
import 'package:lipa_quick/ui/views/user_profile/edit_customer_details.dart';

class UserDetails extends StatefulWidget {

  ProfileDetailsResponse detailsResponse;

  UserDetails(this.detailsResponse, {super.key});

  @override
  UserDetailsScreen createState() => UserDetailsScreen(detailsResponse);
}

class UserDetailsScreen extends State<UserDetails> {

  ProfileDetailsResponse detailsResponse;

  bool? isEditing = false;

  UserDetailsScreen(this.detailsResponse);

  @override
  Widget build(BuildContext context) {
    return PopScope(onPopInvoked: AppRouter().onBackPressed,child: Scaffold(
      appBar: AppBar(
          title: Text(''
            , style: Theme.of(context).textTheme.titleLarge,),
          backgroundColor: Colors.white,
          iconTheme: Theme.of(context).iconTheme.copyWith(
              color: Colors.black
          ),
        actions: getActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
              margin: EdgeInsets.all(6.0),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Section(
                  title: 'Basic Info',
                  details: detailsResponse.toCommonDetailsJson(),
                  icon: Icons.person,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(6.0),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Section(
                  title: 'Address',
                  details: detailsResponse.toAddressDetailsJson(),
                  icon: Icons.home,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(6.0),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: IdentitySection(
                  identity: detailsResponse.toIdentityDetailsJson(),
                  photoUrl: detailsResponse.getIdentityLogo(),
                  icon: Icons.badge,
                ),
              ),
            )
          ],
        ),
      ),
    ),);
  }

  List<Widget>? getActions() {
    return <Widget>[
      IconButton(
        icon: Icon(
          isEditing!?Icons.check:Icons.edit,
          color: appGreen400,
        ),
        tooltip: 'Sync Contacts Again',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCustomerDetails(profileDetails: detailsResponse),
            ),
          );
        },
      )
    ];
  }
}

class Section extends StatelessWidget {
  final String title;
  final Map<String, String> details;
  final IconData icon;

  const Section({
    required this.title,
    required this.details,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              children: [
                Icon(icon, size: 30,  color: appGreen400),
                SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleLarge!.copyWith(
                      color: appGreen400
                  ),
                )
              ]
          ),
          SizedBox(height: 10.0),
          ...details.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    entry.key,
                    style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
                  ),
                  SizedBox(height: 7.0),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        width: 2,
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              )
              /*Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    child:
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: entry.key,
                      ),
                      controller: TextEditingController(text: entry.value),
                      readOnly: true,
                      enabled: false,
                    )
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       entry.key,
                    //       style: theme.textTheme.titleMedium!.copyWith(
                    //         fontSize: 19
                    //       ),
                    //     ),
                    //     Text(
                    //       entry.value,
                    //       style: theme.textTheme.titleMedium,
                    //     ),
                    //   ],
                    // ),
                  ),
                ],
              ),*/
            );
          }).toList(),
        ],
      ),
    );
  }
}

class SectionEdit extends StatefulWidget {
  final String title;
  final Map<String, String> details;
  final IconData icon;
  final bool isEditing;

  const SectionEdit({
    required this.title,
    required this.details,
    required this.icon,
    required this.isEditing,
  });

  @override
  _SectionState createState() => _SectionState();
}

class _SectionState extends State<SectionEdit> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var entry in widget.details.entries)
        entry.key: TextEditingController(text: entry.value),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 30, color: appGreen400),
              SizedBox(width: 10),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge!.copyWith(
                  color: appGreen400,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          ...widget.details.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    entry.key,
                    style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
                  ),
                  SizedBox(height: 7.0),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        width: 2,
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                    child: widget.isEditing
                        ? TextFormField(
                      controller: _controllers[entry.key],
                    )
                        : Text(
                      entry.value,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Map<String, String> getEditedValues() {
    return {
      for (var entry in _controllers.entries) entry.key: entry.value.text,
    };
  }
}

class IdentitySection extends StatelessWidget {
  final Map<String, String> identity;
  final String photoUrl;
  final IconData icon;

  const IdentitySection({
    required this.identity,
    required this.photoUrl,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30,  color: appGreen400),
              SizedBox(width: 10.0),
              Text(
                'Identity',
                style: theme.textTheme.titleLarge!.copyWith(
                  color: appGreen400
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Center(
                  child: photoUrl != null &&
                      photoUrl.isNotEmpty
                      ? ImageUtil().imageFromBase64String(
                      photoUrl,
                      MediaQuery.of(context).size.width / 3.2,
                      MediaQuery.of(context).size.width / 3.2)
                      : const Icon(Icons.question_mark),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...identity.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: theme.textTheme.titleMedium!.copyWith(
                                fontSize: 16
                            ),
                          ),
                          Divider(
                            color: Colors.transparent,
                            height: 3,
                          ),
                          Text(
                            entry.value,
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: Colors.grey[600]
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}