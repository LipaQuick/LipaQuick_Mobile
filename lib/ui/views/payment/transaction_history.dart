import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/view_models/TransactionViewModel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart'; // Replace with your own API package
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/views/payment/transaction_status.dart';
import 'package:lipa_quick/ui/views/social_post/social_post_create.dart';

class TransactionListPage extends StatefulWidget {
  final String? restorationId = 'Date';

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage>
    with RestorationMixin {
  List<RecentTransaction> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  late RestorableDateTimeN _endDate, _startDate;

  @override
  String? get restorationId => widget.restorationId;

  _TransactionListPageState() {
    _endDate = RestorableDateTimeN(DateTime.now());
    var currentDate = DateTime.now();
    _startDate = RestorableDateTimeN(
        DateTime(currentDate.year, currentDate.month, currentDate.day - 7));
  }

  ScrollController? _scrollController;
  final TransactionViewModel _viewModel = locator<TransactionViewModel>();

  late final RestorableRouteFuture<DateTimeRange?>
      _restorableDateRangePickerRouteFuture =
      RestorableRouteFuture<DateTimeRange?>(
    onComplete: _selectDateRange,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator
          .restorablePush(_dateRangePickerRoute, arguments: <String, dynamic>{
        'initialStartDate': _startDate.value?.millisecondsSinceEpoch,
        'initialEndDate': _endDate.value?.millisecondsSinceEpoch,
      });
    },
  );

  void _selectDateRange(DateTimeRange? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _startDate.value = newSelectedDate.start;
        _endDate.value = newSelectedDate.end;
      });

      _viewModel.getItems(_startDate.value!, _endDate.value!);
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_startDate, 'start_date');
    registerForRestoration(_endDate, 'end_date');
    registerForRestoration(
        _restorableDateRangePickerRouteFuture, 'date_picker_route_future');
  }

  static Route<DateTimeRange?> _dateRangePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTimeRange?>(
      context: context,
      builder: (BuildContext context) {
        return DateRangePickerDialog(
          restorationId: 'date_picker_dialog',
          initialDateRange:
              _initialDateTimeRange(arguments! as Map<dynamic, dynamic>),
          firstDate: DateTime(2000),
          currentDate: DateTime.now(),
          lastDate: DateTime.now(),
        );
      },
    );
  }

  static DateTimeRange? _initialDateTimeRange(Map<dynamic, dynamic> arguments) {
    if (arguments['initialStartDate'] != null &&
        arguments['initialEndDate'] != null) {
      return DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(
            arguments['initialStartDate'] as int),
        end: DateTime.fromMillisecondsSinceEpoch(
            arguments['initialEndDate'] as int),
      );
    }

    return null;
  }

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
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
          callback: null,
          actions: getActionItem()),
      body: Column(
        children: [
          // Add your date range selection widgets here
          // For example, you can use two DatePickers to select start and end dates
          // and update _startDate and _endDate accordingly
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _viewModel.refreshItems();
                });

              },
              child: FutureBuilder<dynamic>(
                future: _viewModel.getItems(_startDate.value!, _endDate.value!),
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
                        } else {
                          return EmptyViewFailedWidget(
                            title: AppLocalizations.of(context)!
                                .nav_profile_transactions,
                            message: data.message!,
                            icon: Icons.add_chart,
                            buttonHint: null,
                          );
                        }
                      } else {
                        _items = snapshot.data as List<RecentTransaction>;
                        //var data = snapshot.data as RecentTransactionResponse;
                        //_items.addAll(data.data!);
                        // print("Build List Items: "+data.toJson().toString());
                        return ListView.builder(
                          itemCount: _items.length + 1,
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(5.0),
                          // Add 1 for loading indicator
                          itemBuilder: (context, index) {
                            if (index == _items.length) {
                              return _buildLoadingIndicator();
                            } else {
                              return getCardTransactionItem(_items[index]);
                            }
                          },
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
    ));
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: _viewModel.isLoading
          ? CircularProgressIndicator()
          : _hasMoreData
              ? SizedBox()
              : Text(AppLocalizations.of(context)!.transaction_history_empty),
    );
  }

  void _scrollListener() {
    if (_scrollController?.position.maxScrollExtent ==
        _scrollController?.offset) {
      /***
       * we need to get new data on page scroll end but if the last
       * time when data is returned, its count should be Constants.itemsCount' (10)
       *
       * So we calculate every time
       *
       * productList.length >= (Constants.itemsCount*pageNumber)
       *
       * list must contain the products == Constants.itemsCount if the page number is 1
       * but if page number is increased then we need to calculate the total
       * number of products we have received till now example:
       * first time on page scroll if last count of productList is Constants.itemsCount
       * then increase the page number and get new data.
       * Now page number is 2, now we have to check the count of the productList
       * if it is==Constants.itemsCount*pageNumber (20 in current case) then we have
       * to get data again, if not then we assume, server has not more data then
       * we currently have.
       *
       */
      if (_items.length > 0 &&
          _items.length >= (_viewModel.totalPageSize) &&
          !_viewModel.isLoading) {
        _viewModel.loadMoreItems();
      }
    }
  }

  Widget getTransactionItem(RecentTransaction item) {
    return ListTile(
      title: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .transaction_code(item.bankReferenceId!.substring(0, 6)),
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
                color: Color(0xfffffbe0),
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
                      color: Color(0xffffd233),
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
      // Add other item widgets here
    );
  }

  Widget getCardTransactionItem(RecentTransaction item) {
    print(item.toJson());
    return Card(
      color: ColorsLib.appBackgroundWhite,
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
              debugPrint('Pressed');

              Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TransactionStatusPage(item)));

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

  Widget footer(RecentTransaction item) {
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
                                ? AppLocalizations.of(context)!
                                    .hint_sent_to(item.receiver!)
                                : AppLocalizations.of(context)!
                                    .hint_received_from(item.sender!),
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
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getStatusIcon(RecentTransaction item) {
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

  Color getStatusColor(RecentTransaction item, bool isBackground) {
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

  List<Widget>? getActionItem() {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.calendar_today_rounded, color: appGreen400),
        onPressed: () {
          _restorableDateRangePickerRouteFuture.present();
        },
      )
    ];
  }
}
