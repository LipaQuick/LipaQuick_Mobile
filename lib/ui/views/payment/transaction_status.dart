import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/payment/payment_status_response.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/view_models/TransactionViewModel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart'; // Replace with your own API package
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/shared/button.dart';

class TransactionStatusPage extends StatefulWidget {
  RecentTransaction recentTransaction;


  TransactionStatusPage(this.recentTransaction);

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionStatusPage> {
  TransactionStatus? _items;

  final TransactionViewModel _viewModel = locator<TransactionViewModel>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onBackPressed(bool canPop) {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(true);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(onPopInvoked: _onBackPressed, child: Scaffold(
      appBar: AppTheme.getAppBarWithActions(
          context: context,
          title: AppLocalizations.of(context)!.nav_profile_transactions,
          subTitle: '',
          enableBack: true,
          callback: null),
      body: Column(
        children: [
          // Add your date range selection widgets here
          // For example, you can use two DatePickers to select start and end dates
          // and update _startDate and _endDate accordingly
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _viewModel.getTransactionStatus(
                      widget.recentTransaction.id);
                });
              },
              child: FutureBuilder<dynamic>(
                future: _viewModel.getTransactionStatus(
                    widget.recentTransaction.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator();
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data is APIException) {
                        var data = snapshot.data as APIException;
                        if (data.statusCode == 401) {
                          return EmptyViewFailedWidget(
                            title: AppLocalizations.of(context)!
                                .nav_profile_transactions,
                            message: AppLocalizations.of(context)!
                                .transaction_history_empty,
                            icon: Icons.add_chart,
                            buttonHint: null,
                          );
                        }
                        else {
                          return EmptyViewFailedWidget(
                            title: AppLocalizations.of(context)!
                                .nav_profile_transactions,
                            message: data.message!,
                            icon: Icons.add_chart,
                            buttonHint: null,
                          );
                        }
                      } else {
                        _items = snapshot.data as TransactionStatus;
                        //var data = snapshot.data as RecentTransactionResponse;
                        //_items.addAll(data.data!);
                        // print("Build List Items: "+data.toJson().toString());
                        return ListView(
                          children: [
                            getTransactionItem(_items!),
                            Visibility(visible: _items!.status!.toLowerCase() == 'success',
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  width: MediaQuery.of(context).size.width/2.7,
                                  child: Button.outlined(onPressed: (){}, label: 'Create a post'),
                                ),
                              ),)
                          ],
                        );
                      }
                    } else {
                      return EmptyViewFailedWidget(
                        title: AppLocalizations.of(context)!
                            .nav_profile_transactions,
                        message: AppLocalizations.of(context)!
                            .transaction_history_empty,
                        icon: Icons.add_chart,
                        buttonHint: '',
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: ColorsLib.appGrey100,
    ));
  }


  Widget _buildLoadingIndicator() {
    return Center(
      child: _viewModel.isLoading
          ? CircularProgressIndicator()
          : Text(AppLocalizations.of(context)!.transaction_history_empty),
    );
  }

  Widget getStatusIcon(TransactionStatus item) {
  Widget widget = Container();
  if (item.status!.isNotEmpty && item.status! == 'PENDING') {
  widget = Container(
  decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(10),
  color: ColorsLib.transactionPendingLight,
  ),
  padding: const EdgeInsets.all(12),
  child: Row(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
  Center(
  child: Icon(
  Icons.access_time_filled,
  color: ColorsLib.transactionPendingDark,
  ))
  ],
  ),
  );
  } else if (item.status!.isNotEmpty && item.status! == 'FAIL') {
  widget = Container(
  decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(10),
  color: ColorsLib.transactionFailureLight,
  ),
  padding: const EdgeInsets.all(12),
  child: Row(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
  Center(
  child: Icon(
  Icons.cancel_rounded,
  color: ColorsLib.transactionFailureDark,
  ))
  ],
  ),
  );
  } else {
  widget = Container(
  decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(10),
  color: ColorsLib.transactionSuccessLight,
  ),
  padding: const EdgeInsets.all(12),
  child: Row(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
  Center(
  child: Icon(
  Icons.check_circle,
  color: ColorsLib.transactionSuccessDark,
  ))
  ],
  ),
  );
  }
  return widget;
  }

  Color getStatusColor(TransactionStatus item, bool isBackground) {
  Color widget = ColorsLib.appBackgroundWhite;
  if (item.status!.isNotEmpty && item.status! == 'PENDING') {
  widget = isBackground
  ? ColorsLib.transactionPendingLight
      : ColorsLib.transactionPendingDark;
  } else if (item.status!.isNotEmpty && item.status! == 'FAIL') {
  widget = isBackground
  ? ColorsLib.transactionFailureLight
      : ColorsLib.transactionFailureDark;
  } else {
  widget = isBackground
  ? ColorsLib.transactionSuccessLight
      : ColorsLib.transactionSuccessDark;
  }
  return widget;
  }

  Widget getTransactionItem(TransactionStatus item) {
    return Card(
      color: ColorsLib.appBackgroundWhite,
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListTile(
            title: Container(
              padding: EdgeInsets.only(top: 8),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.transaction_code(
                        item.bankReferenceId!.substring(0, 6)),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff5d5c5d),
                      fontSize: 12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: getStatusColor(item, true),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.status!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: getStatusColor(item, false),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            subtitle: footer(item),
            onTap: () {
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context) => CreateFeedbackPage(
              //         paymentRemarks: item.toPaymentRequest())));

              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => FeedbackPageWidget(
              //             paymentRemarks: item.toPaymentRequest())));
            },
            // Add other item widgets here
          )
        ],
      ),
    );
  }

  Widget footer(TransactionStatus item) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SizedBox(height: 8),
          Divider(height: 4, color: ColorsLib.appSurfaceBlack),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getStatusIcon(item),
              SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.isDebit!
                                ? 'Receiver: ${item.receiver!}'
                                : 'Sender: ${item.sender!}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff142c06),
                              fontSize: 16,
                              fontFamily: "Mulish",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Text(
                                    'Rwf${item.amount}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Color(0xff5d5c5d),
                                      fontSize: 14,
                                      fontFamily: "Mulish",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                              SizedBox(width: 4),
                              Text(
                                '${item.modifiedAt!}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xff5d5c5d),
                                  fontSize: 12,
                                  fontFamily: "Mulish",
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          Visibility(visible: (item.remarks != null && item.remarks!.isNotEmpty)
                              , child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 8),
                                  Flexible(
                                      child: Text(
                                        'Desc: ${item.remarks}',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Color(0xff5d5c5d),
                                          fontSize: 14,
                                          fontFamily: "Mulish",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )),
                                ],
                              )),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class TransactionDetails extends StatelessWidget {
  final TransactionStatus transaction;

  TransactionDetails(this.transaction);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sender: ${transaction.sender}',
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.black,
                fontSize: 21,
                fontWeight: FontWeight.bold)),
        Text('Receiver: ${transaction.receiver}'),
        Text('Amount: \$${transaction.amount}'),
        Text('Status: ${transaction.status}'),
        Text('Date: ${transaction.createdAt}'),
      ],
    );
  }
}
