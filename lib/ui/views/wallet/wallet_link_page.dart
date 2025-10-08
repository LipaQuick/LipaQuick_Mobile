import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';

class WalletLinkPage extends StatefulWidget {
  final UserDetails? userDetails;

  bool? goToHome = false;

  WalletLinkPage({super.key, this.userDetails, this.goToHome});

  @override
  State<WalletLinkPage> createState() => _WalletLinkPageState();
}

class _WalletLinkPageState extends State<WalletLinkPage> {
  Future<dynamic> fetchData(String phoneNumber) async {
    Api api = locator<Api>();
    return await api.checkWalletAccount(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(child: Scaffold(
      appBar: AppTheme.getAppBar(
          context: context,
          title: 'MTN Wallet',
          subTitle: '',
          enableBack: true),
      body: FutureBuilder<dynamic>(
        future: fetchData(widget.userDetails!.phoneNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Details(userDetails: widget.userDetails, snapShotData: snapshot.data, onRetry: (){
              print('Retry');
              setState(() {
                fetchData(widget.userDetails!.phoneNumber);
              });
            }, onWalletLink: (){
              if(widget.goToHome!){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage()),
                        (Route<dynamic> route) => false);
              }else{
                Navigator.of(context).pop();
              }
            },);
          }
        },
      ),
    )
      , onPopInvoked: AppRouter().onBackPressed);
  }
}

class Details extends StatelessWidget {
  const Details({
    super.key,
    required this.userDetails,
    required this.snapShotData,
    required this.onRetry,
    required this.onWalletLink,
  });

  final UserDetails? userDetails;
  final dynamic snapShotData;
  final VoidCallback onRetry;
  final VoidCallback onWalletLink;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.all(20),
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Color(0xD8FFFFFF)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icon.mtnmomo.svg(width: 60, height: 60),
                  Text('${userDetails!.firstName} ${userDetails!.lastName}',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${userDetails!.email}',
                      style: GoogleFonts.poppins(fontSize: 16)),
                  Text('${userDetails!.phoneNumber}',
                      style: GoogleFonts.poppins(fontSize: 16)),
                  SizedBox(
                    height: 40,
                  ),
                  Visibility(
                    visible: snapShotData is ApiResponse,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Wallet Linked Successfully',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16))
                            ],
                          ),
                          Text((snapShotData is ApiResponse) ? (snapShotData as ApiResponse).message!: '',
                              style: GoogleFonts.poppins(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: snapShotData is APIException,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Wallet Link Error',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16)),
                              ElevatedButton(
                                onPressed:(){
                                  onRetry();
                                },
                                child: Text('Retry'),
                              )
                            ],
                          ),
                          Text((snapShotData is APIException) ? (snapShotData as APIException).message!: '',
                              style: GoogleFonts.poppins(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        snapShotData is ApiResponse ? buttonLink : null,
                    child: Text(snapShotData is ApiResponse ? 'OK' : ''),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void buttonLink() {
    onWalletLink();
  }
}

class SuccessStage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stage 3: Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            Text('Success!'),
          ],
        ),
      ),
    );
  }
}
