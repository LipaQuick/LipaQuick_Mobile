import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/services/blocs/payment_method_bloc.dart';
import 'package:lipa_quick/core/services/events/payment_method_events.dart';
import 'package:lipa_quick/core/services/states/payment_method_states.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  PaymentMethodBloc? bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<PaymentMethodBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bloc!..add(PaymentFetchEvent());
    return Scaffold(
        appBar: AppBar(
          title: Text(l10n.payment_methods_title),
        ),
        backgroundColor: appGrey100,
        body: BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
            builder: (_, state) {
          switch (state.status) {
            case PaymentMethodsStatus.loading:
              return Container(
                child: CircularProgressIndicator(),
              );
            case PaymentMethodsStatus.success:
              if (state.defaultUserPaymentMethod == null &&
                  state.paymentMethods.isNotEmpty) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(2),
                      child: Card(
                        margin: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(8),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  getPaymentModelIcons(state
                                      .defaultUserPaymentMethod!.methodName!),
                                  color: Colors.white,
                                ),
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appGreen300,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    getAccountDetails(
                                        state.defaultUserPaymentMethod!),
                                    style: GoogleFonts.poppins(fontSize: 16)),
                                Text(
                                    state.defaultUserPaymentMethod!.methodName!,
                                    style: GoogleFonts.poppins(fontSize: 14)),
                                Text(
                                  l10n.default_payment_hint,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: appGrey400),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          child: ListView.builder(
                            itemCount: state.paymentMethods.length,
                            itemBuilder: (context, index) {
                              UserPaymentMethods paymentMethod =
                              state.paymentMethods[index];

                              return InkWell(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: (state.defaultUserPaymentMethod !=
                                            null &&
                                            paymentMethod.id ==
                                                state.defaultUserPaymentMethod!
                                                    .id)
                                            ? appGreen300
                                            : Colors.transparent),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: appGrey100,
                                  margin: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Icon(
                                            getPaymentModelIcons(state
                                                .defaultUserPaymentMethod!
                                                .methodName!),
                                            color: Colors.white,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (state.defaultUserPaymentMethod !=
                                              null &&
                                              paymentMethod.id ==
                                                  state
                                                      .defaultUserPaymentMethod!
                                                      .id)
                                              ? appGreen300
                                              : appGrey400,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                              getAccountDetails(
                                                  state.defaultUserPaymentMethod!),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16)),
                                          Text(
                                              state.defaultUserPaymentMethod!
                                                  .methodName!,
                                              style:
                                              GoogleFonts.poppins(fontSize: 14))
                                        ],
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(
                                          (state.defaultUserPaymentMethod !=
                                              null &&
                                              paymentMethod.id ==
                                                  state
                                                      .defaultUserPaymentMethod!
                                                      .id)
                                              ? Icons.check_circle
                                              : null,
                                          color: appGreen400,
                                        ),
                                        iconSize: 32,
                                        onPressed: () {},
                                      )
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  paymentMethod.isDefault = true;
                                  bloc!.add(PaymentUpdateEvent(paymentMethod));
                                },
                              );
                            },
                          ),
                        ))
                  ],
                );
              }
              if (state.defaultUserPaymentMethod != null &&
                  state.paymentMethods.isNotEmpty) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(2),
                      child: Card(
                        margin: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(8),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  getPaymentModelIcons(state
                                      .defaultUserPaymentMethod!.methodName!),
                                  color: Colors.white,
                                ),
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appGreen300,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    getAccountDetails(
                                        state.defaultUserPaymentMethod!),
                                    style: GoogleFonts.poppins(fontSize: 16)),
                                Text(
                                    state.defaultUserPaymentMethod!.methodName!,
                                    style: GoogleFonts.poppins(fontSize: 14)),
                                Text(
                                  l10n.default_payment_hint,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: appGrey400),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                  child: ListView.builder(
                              itemCount: state.paymentMethods.length,
                              itemBuilder: (context, index) {
                                UserPaymentMethods paymentMethod =
                                    state.paymentMethods[index];

                                return InkWell(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: (state.defaultUserPaymentMethod !=
                                                      null &&
                                                  paymentMethod.id ==
                                                      state.defaultUserPaymentMethod!
                                                          .id)
                                              ? appGreen300
                                              : Colors.transparent),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    color: appGrey100,
                                    margin: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(8),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Icon(
                                              getPaymentModelIcons(state
                                                  .defaultUserPaymentMethod!
                                                  .methodName!),
                                              color: Colors.white,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (state.defaultUserPaymentMethod !=
                                                        null &&
                                                    paymentMethod.id ==
                                                        state
                                                            .defaultUserPaymentMethod!
                                                            .id)
                                                ? appGreen300
                                                : appGrey400,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                getAccountDetails(
                                                    state.defaultUserPaymentMethod!),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16)),
                                            Text(
                                                state.defaultUserPaymentMethod!
                                                    .methodName!,
                                                style:
                                                    GoogleFonts.poppins(fontSize: 14))
                                          ],
                                        ),
                                        Spacer(),
                                        IconButton(
                                          icon: Icon(
                                            (state.defaultUserPaymentMethod !=
                                                null &&
                                                paymentMethod.id ==
                                                    state
                                                        .defaultUserPaymentMethod!
                                                        .id)
                                                ? Icons.check_circle
                                                : null,
                                            color: appGreen400,
                                          ),
                                          iconSize: 32,
                                          onPressed: () {},
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: (){
                                    paymentMethod.isDefault = true;
                                    bloc!.add(PaymentUpdateEvent(paymentMethod));
                                  },
                                );
                              },
                            ),
                    ))
                  ],
                );
              } else {
                return EmptyViewFailedWidget(
                  title: l10n.payment_methods_title,
                  message: l10n.payment_methods_not_found,
                  icon: Icons.payments_outlined,
                  buttonHint: l10n.add_payment,
                  callback: (){

                  },

                );
              }
            case PaymentMethodsStatus.failure:
              return EmptyViewFailedWidget(
                title: l10n.payment_methods_title,
                message: l10n.something_went_wrong_hint,
                icon: Icons.payments_outlined,
                buttonHint: l10n.button_continue,
                callback: (){
                  Navigator.of(context).pop();
                },
              );
            default:
              return SizedBox();
          }
        }));
  }

  IconData? getPaymentModelIcons(String methodName) {
    return methodName == 'Bank Account'
        ? Icons.account_balance
        : methodName == "Credit Card"
            ? Icons.credit_card
            : Icons.wallet;
  }

  String getAccountDetails(UserPaymentMethods userPaymentMethods) {
    return userPaymentMethods.accountNumber != null
        ? '${userPaymentMethods.accountNumber!}'
        : userPaymentMethods.cardNumber != null
            ? '**** **** **** ${userPaymentMethods.accountNumber!.substring(12)}'
            : userPaymentMethods.phoneNumber!;
  }
}
