import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/payment/default_payments.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/blocs/account/account_list_state.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/services/blocs/payment/payment_bloc.dart';
import 'package:lipa_quick/core/services/blocs/payment/payment_state.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/views/add_account/account_list/account_item.dart';
import 'package:lipa_quick/ui/views/add_account/add_account.dart';
import 'package:lipa_quick/ui/views/cards/add_card.dart';
import 'package:lipa_quick/ui/views/cards/card_list/card_item.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/payment/payment_link_page.dart';
import 'package:lipa_quick/ui/views/wallet/wallet_link_page.dart';

import '../../../../core/services/blocs/account/account_list_bloc.dart';
import '../../../../core/services/blocs/account/account_list_event.dart';
import '../../../AppColorBuilder.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DefaultPaymentDropDown extends StatelessWidget {
  dynamic preselected;
  ValueChanged<dynamic>? voidCallback;

  DefaultPaymentDropDown({super.key, this.voidCallback, this.preselected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => PaymentBloc()..add(DefaultPaymentFetchEvent()),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Select Account",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: appGreen400,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: DefaultPaymentListPage(
              voidCallback: voidCallback,
              preselected: preselected,
              showAppBar: false,
            ))
          ],
        ),
      ),
    );
  }
}

class DefaultPaymentListPage extends StatelessWidget {
  dynamic preselected;
  ValueChanged<dynamic>? voidCallback;
  bool showAppBar = true;

  DefaultPaymentListPage(
      {this.preselected, this.voidCallback, required this.showAppBar});

  @override
  Widget build(BuildContext context) {
    Widget view;
    if (showAppBar) {
      view = Scaffold(
        appBar: AppTheme.getAppBarWithActions(
            context: context,
            title: "Your Accounts",
            subTitle: "",
            enableBack: true, actions: getActions(context)),
        body: BlocProvider(
          create: (_) => PaymentBloc()..add(DefaultPaymentFetchEvent()),
          child: PaymentDefaultPage(
              showAppBar: showAppBar, voidCallback: voidCallback),
        ),
      );
    } else {
      view = Scaffold(
        body: BlocProvider(
          create: (_) => PaymentBloc()..add(DefaultPaymentFetchEvent()),
          child: PaymentDefaultPage(
              showAppBar: showAppBar, voidCallback: voidCallback),
        ),
      );
    }
    return view;
  }

  List<Widget>? getActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(
          Icons.dataset_linked,
          color: appGreen400,
        ),
        tooltip: 'Sync Contacts Again',
        onPressed: () {
          openPaymentLinkPage(context);
        },
      )
    ];
  }
}

class PaymentDefaultPage extends StatefulWidget {
  dynamic preselected;
  ValueChanged<dynamic>? voidCallback;
  bool showAppBar = true;

  PaymentDefaultPage(
      {Key? key, this.preselected, this.voidCallback, required this.showAppBar})
      : super(key: key);

  @override
  State<PaymentDefaultPage> createState() => _PaymentDefaultPageState();
}

class _PaymentDefaultPageState extends State<PaymentDefaultPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        switch (state.status) {
          case ApiStatus.authFailed:
            return AuthorizationFailedWidget(callback: () async {
              // LocalSharedPref().clearLoginDetails().then((value) => {
              //       Navigator.of(context).pushAndRemoveUntil(
              //           MaterialPageRoute(builder: (context) => LoginPage()),
              //           (Route<dynamic> route) => false)
              //     });
              //await LocalSharedPref().clearLoginDetails();
              goToLoginPage(context);
            });
          case ApiStatus.failure:
            return EmptyViewFailedWidget(
                title: "Payment Methods",
                message: state.errorMessage ?? '',
                icon: Icons.account_balance,
                buttonHint: "OK",
                callback: () {
                  Navigator.of(context).pop();
                });
          case ApiStatus.empty:
            return EmptyViewFailedWidget(
                title: "Payments",
                message:
                "You have not linked any Bank or Wallet into your account, Please link your any payment methods to start transferring money.",
                icon: Icons.account_balance,
                buttonHint: "LINK ACCOUNT's",
                callback: () {
                  openPaymentLinkPage(context);
                });
          case ApiStatus.success:
            return Column(
              children: [
                Visibility(
                    child: InkWell(
                      child: AccountListItem(state
                          .responsePaymentMethodDto?.data?.DefaultBankAccount),
                      onTap: () {
                        widget.voidCallback!(state.responsePaymentMethodDto
                            ?.data?.DefaultBankAccount);
                      },
                    ),
                    visible: state.responsePaymentMethodDto?.data
                            ?.DefaultBankAccount!.accountNumber !=
                        null),
                Visibility(
                    child: InkWell(
                      child: CardListItem(
                          state.responsePaymentMethodDto?.data?.Defaultcarddetails),
                      onTap: () {
                        widget.voidCallback!(state
                            .responsePaymentMethodDto?.data?.Defaultcarddetails);
                      },
                    ),
                    visible: state.responsePaymentMethodDto?.data
                        ?.Defaultcarddetails!.cardNumber !=
                        null),
                Visibility(
                    child: InkWell(
                      child: WalletItemView(state
                          .responsePaymentMethodDto?.data?.DefaultWalletDetails),
                      onTap: () {
                        widget.voidCallback!(state
                            .responsePaymentMethodDto?.data?.DefaultWalletDetails);
                      },
                    ),
                    visible: isWalletValid(state.responsePaymentMethodDto!))
              ],
            );
          case ApiStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future addBankAccount() async {
    final bool? result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (context) => AddAccountPage(false),
            settings: const RouteSettings(name: 'AddAccount')));

    if (result != null && result) {
      context.read<AccountBloc>().add(AccountFetched());
    }
  }

  void showMoreActions(BuildContext context, AccountDetails accountList, AccountBloc bloc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'More',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              Wrap(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: appGreen400,
                    ),
                    title: Text('Set as Default'),
                    onTap: () {
                      Navigator.of(context).pop();
                      bloc.add(AccountDefaultEvent(accountList));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: Text('Delete'),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (accountList.primary!) {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content: const Text(
                                'This is primary account linked to the account. Please choose another default account, and then delete this account.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        bloc.add(AccountDeleteEvent(accountList));
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  isWalletValid(ResponsePaymentMethodDto paymentDto) {
    debugPrint('Data: ${paymentDto.data != null}\n'
        'Wallet: ${paymentDto.data!.DefaultWalletDetails != null}\n'
        'Number: ${paymentDto.data!.DefaultWalletDetails!.number != null}\n'
        'Number: ${paymentDto.data!.DefaultWalletDetails!.number!.isNotEmpty}'
    );
   return paymentDto.data != null
        && paymentDto.data!.DefaultWalletDetails != null
        && paymentDto.data!.DefaultWalletDetails!.number != null
        && paymentDto.data!.DefaultWalletDetails!.number!.isNotEmpty
   ;
  }
}

void openPaymentLinkPage(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16.0),
            Wrap(
              children: [
                ListTile(
                  leading: Assets.icon.mtnmomo.svg(height: 24, width: 24),
                  title: Text('Link Wallet'),
                  onTap: () async {
                    Navigator.of(context).pop();

                    var user = await LocalSharedPref().getUserDetails();
                    UserDetails userDetail =
                    UserDetails.fromJson(jsonDecode(user));
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WalletLinkPage(
                          userDetails: userDetail,
                          goToHome: true,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.store,
                    color: Colors.black,
                  ),
                  title: Text('Link Account'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddAccountPage(true),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.payment,
                    color: Colors.black,
                  ),
                  title: Text('Link Credit Card'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddCardPage(goToHome: false),
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}

class WalletItemView extends StatelessWidget {
  final MTNWalletDetails? _details;

  WalletItemView(this._details, {Key? key});

  @override
  Widget build(BuildContext context) {
    print('Number ${_details!.number}');
    return Card(
        child: Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Assets.icon.mtnmomo.svg(width: 60, height: 60),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MTN Wallet",
                textAlign: TextAlign.center,
                style: GoogleFonts.mulish(
                    color: const Color(0xff142c06),
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              Text('${(_details != null
                  && _details?.number != null
                  && _details!.number!.isNotEmpty)
                  ? _details!.number!.substring(8)
                  : ''} ',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.normal)),
            ],
          )
        ],
      ),
    ));
  }
}

class PaymentWalletView extends StatelessWidget {
  final MTNWalletDetails? _details;

  PaymentWalletView(this._details, {Key? key});

  @override
  Widget build(BuildContext context) {
    print('Number ${_details!.number}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MTN Wallet",
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(
                  color: const Color(0xff142c06),
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            Text('${(_details != null
                && _details?.number != null
                && _details!.number!.isNotEmpty)
                ? _details!.number!.substring(8)
                : ''} ',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.normal)),
          ],
        ),
        Assets.icon.mtnmomo.svg(width: 40, height: 40),
      ],
    );
  }
}
