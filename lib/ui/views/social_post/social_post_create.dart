import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/managers/social_post/social_bloc.dart';
import 'package:lipa_quick/core/managers/social_post/social_event.dart';
import 'package:lipa_quick/core/managers/social_post/social_state.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';
import 'package:lipa_quick/ui/views/payment/transaction_summary.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateFeedbackPage extends StatelessWidget {
  PaymentRequest? paymentRemarks;
  Widget? nextWidget;

  CreateFeedbackPage({this.paymentRemarks, this.nextWidget, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => SocialPostBloc(locator<Api>()),
        child: FeedbackPageWidget(paymentRemarks: paymentRemarks, nextWidget: nextWidget,),
      ),
    );
  }
}

class FeedbackPageWidget extends StatefulWidget {
  PaymentRequest? paymentRemarks;
  Widget? nextWidget;

  FeedbackPageWidget({this.paymentRemarks, this.nextWidget, super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPageWidget> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _RemarkController = TextEditingController();
  String _privacy = '2';

  @override
  Widget build(BuildContext context) {
    final SocialPostBloc feedbackBloc =
        BlocProvider.of<SocialPostBloc>(context);
    debugPrint('Reached Feed Back Page Till Here');
    var headline2 = Theme.of(context).textTheme.displayMedium!;

    return PopScope(onPopInvoked: AppRouter().onBackPressed,child: Scaffold(
      appBar: AppTheme.getAppBarWithActions(
          title: '', subTitle: "", enableBack: true, context: context),
      body: BlocListener<SocialPostBloc, PostState>(
        listener: (context, state) async {
          if (state.status == PostApiStatus.success) {
            debugPrint('Reached Feed Back PostApiStatus.success');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                  Text(AppLocalizations.of(context)!.success_hint),
                  showCloseIcon: true),
            );
            //Navigator.pop(context, false);

            if(widget.nextWidget != null){
              Navigator.pop(context, false);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => widget.nextWidget!),
                      (Route<dynamic> route) => route.isFirst);
            }else{
              Navigator.pop(context, false);
            }
          }
          else if (state.status == PostApiStatus.authFailed) {
            debugPrint('Reached Feed Back PostApiStatus.authFailed ');
            //Show Dialog For Authfailed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                  Text(AppLocalizations.of(context)!.session_time_out_hint),
                  showCloseIcon: true),
            );
            //Navigator.pop(context, false);
            Navigator.pop(context, false);
          }
          else if (state.status == PostApiStatus.failure) {
            debugPrint('Reached Feed Back PostApiStatus.failure ');
            //Show Dialog For Authfailed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.something_went_wrong_hint),
                  showCloseIcon: true),
            );
            //Navigator.pop(context, false);
            Navigator.pop(context, false);
          }
        },
        child:  BlocBuilder<SocialPostBloc, PostState>(
          builder: (BuildContext context, PostState state) {
            if(state.status == PostApiStatus.loading){
              return SafeArea(
                child: Visibility(
                    visible: state.status == PostApiStatus.loading,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: const CircularProgressIndicator(),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: appSurfaceWhite,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: appBackgroundBlack200,
                          borderRadius: BorderRadius.circular(8)),
                    )),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        maxLength: 160, // Allow multiple lines of input
                        decoration: InputDecoration(
                          labelText: '',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      // TextField(
                      //   controller: _RemarkController,
                      //   maxLines: 1,
                      //   maxLength: 160, // Allow multiple lines of input
                      //   decoration: InputDecoration(
                      //     labelText: 'Remarks',
                      //     border: OutlineInputBorder(),
                      //   ),
                      // ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                              foregroundColor: appGreen400,
                              surfaceTintColor: appSurfaceWhite),
                          onPressed: () {
                            _showPrivacyBottomSheet(context);
                          },
                          child: RichText(
                            text: TextSpan(
                                children: [
                                  WidgetSpan(child: getPrivacyIcon(_privacy), alignment: PlaceholderAlignment.middle),
                                  TextSpan(
                                      text: getPrivacy(_privacy),
                                      style: GoogleFonts.poppins(
                                          textStyle: headline2.copyWith(
                                              fontSize: 16, color: appSurfaceWhite))
                                  )
                                ]
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700, fontSize: 19)),
                        onPressed: () {
                          String feedback = _feedbackController.text;
                          String remark =
                              '${widget.paymentRemarks!.sender} paid to ${widget.paymentRemarks!.receiver}';
                          feedbackBloc.add(CreatePostEvent(
                              content: feedback,
                              postStatus: _privacy,
                              remark: remark,
                              paymentId: widget.paymentRemarks!.transactionId!));
                        },
                        child: Text('Post'),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    ),);
  }

  void _showPrivacyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.public),
                title: Text('Public'),
                onTap: () {
                  setState(() {
                    _privacy = '2';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Private'),
                onTap: () {
                  setState(() {
                    _privacy = '0';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Friends'),
                onTap: () {
                  setState(() {
                    _privacy = '1';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /*
   This is based on following Mapping
   0 - Private
   1 - Friends
   2 - Public
   */
  String getPrivacy(String privacy) {
    int flag = int.parse(privacy);
    if (flag == 0) {
      return " Private";
    } else if (flag == 1) {
      return " Friends";
    } else {
      return " Public";
    }
  }

  Icon getPrivacyIcon(String privacy) {
    int flag = int.parse(privacy);
    if (flag == 0) {
      return Icon(Icons.lock, size: 14, color: appSurfaceWhite);
    } else if (flag == 1) {
      return Icon(Icons.group, size: 14, color: appSurfaceWhite);
    } else {
      return Icon(Icons.public, size: 14, color: appSurfaceWhite);
    }
  }
}

class _PaymentSocialPageState extends State<FeedbackPageWidget> {
  final TextEditingController _feedbackController = TextEditingController();
  String _privacy = '2';

  _PaymentSocialPageState();

  @override
  Widget build(BuildContext context) {
    final SocialPostBloc feedbackBloc =
        BlocProvider.of<SocialPostBloc>(context);

    return Scaffold(
      appBar: AppTheme.getAppBarWithActions(
          title: '', subTitle: "", enableBack: true, context: context),
      body: BlocBuilder<SocialPostBloc, PostState>(
        builder: (BuildContext context, PostState state) {
          // if (state.status == PostApiStatus.success) {
          //   Navigator.of(context).pop();
          // }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TransactionUserDetails(
                        paymentRequest: widget.paymentRemarks!),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      maxLength: 160, // Allow multiple lines of input
                      decoration: InputDecoration(
                        labelText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            foregroundColor: appGreen400,
                            surfaceTintColor: appSurfaceWhite),
                        onPressed: () {
                          _showPrivacyBottomSheet(context);
                        },
                        child: Text(getPrivacy(_privacy)),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, fontSize: 19)),
                      onPressed: () {
                        String feedback = _feedbackController.text;
                        String remark = getPostRemarks(widget.paymentRemarks!);
                        feedbackBloc.add(CreatePostEvent(
                            content: feedback,
                            postStatus: _privacy,
                            remark: remark,
                            paymentId: widget.paymentRemarks!.transactionId!));
                      },
                      child: Text('Post'),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SafeArea(
                child: Visibility(
                    visible: state.status == PostApiStatus.loading,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: const CircularProgressIndicator(),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: appSurfaceWhite,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: appBackgroundBlack200,
                          borderRadius: BorderRadius.circular(8)),
                    )),
              )
            ],
          );
        },
      ),
    );
  }

  void _showPrivacyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.public),
                title: Text('Public'),
                onTap: () {
                  setState(() {
                    _privacy = '2';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Private'),
                onTap: () {
                  setState(() {
                    _privacy = '0';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Friends'),
                onTap: () {
                  setState(() {
                    _privacy = '1';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /*
   This is based on following Mapping
   0 - Private
   1 - Friends
   2 - Public
   */
  String getPrivacy(String privacy) {
    int flag = int.parse(privacy);
    if (flag == 0) {
      return "Private";
    } else if (flag == 1) {
      return "Friends";
    } else {
      return "Public";
    }
  }

  String getPostRemarks(PaymentRequest paymentRequest) {
    return '${paymentRequest.sender!.senderName} paid to ${paymentRequest.receiver!.receiverName}';
  }
}
