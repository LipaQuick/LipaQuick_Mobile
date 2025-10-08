import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/services/blocs/account/account_list_state.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/views/add_account/account_list/account_item.dart';
import 'package:lipa_quick/ui/views/add_account/add_account.dart';
import 'package:lipa_quick/ui/views/login_view.dart';

import '../../../core/services/blocs/account/account_list_bloc.dart';
import '../../../core/services/blocs/account/account_list_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountListDropDown extends StatelessWidget {
  AccountDetails? preselected;
  ValueChanged<AccountDetails?>? voidCallback;

  AccountListDropDown({super.key, this.voidCallback, this.preselected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => AccountBloc()..add(AccountFetched()),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Text(
                    "Select Account",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: appGreen400,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)
                          )
                      ),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: ListAccountPage(voidCallback: voidCallback, preselected: preselected,))
          ],
        ),
      ),
    );
  }
}

class ListAccountPage extends StatefulWidget {
  AccountDetails? preselected;
  ValueChanged<AccountDetails?>? voidCallback;
  ListAccountPage({Key? key, this.voidCallback, this.preselected}) : super(key: key);

  @override
  State<ListAccountPage> createState() => _ListAccountPageState();
}

class _ListAccountPageState extends State<ListAccountPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        switch (state.status) {
          case ApiStatus.authFailed:
            return AuthorizationFailedWidget(callback: () async {
              // LocalSharedPref().clearLoginDetails().then((value) => {
              //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage())
              //       , (Route<dynamic> route) => false)
              // });
              //await LocalSharedPref().clearLoginDetails();
              goToLoginPage(context);
            });
          case ApiStatus.failure:
            return const Center(child: Text('Failed to fetch accounts'));
          case ApiStatus.empty:
            return const Center(child: Text('Failed to fetch accounts'));
          case ApiStatus.success:
            if (state.accountList.isEmpty) {
              return EmptyViewFailedWidget(title:"Bank Accounts", message:"No Banks Accounts are Linked."
                  , icon:Icons.account_balance
                  , buttonHint:"ADD BANK ACCOUNTS"
                  , callback: (){

                  });
            }
            // if(widget.preselected == null){
            //   widget.preselected = state.accountList.firstWhere((element) => element.primary!);
            //   widget.voidCallback!(widget.preselected);
            // }
            return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(10.0),
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext con, int index) {
                      return GestureDetector(
                        child: AccountListItem(state.accountList[index],  preselected: widget.preselected),
                        onTap: (){
                          widget.voidCallback!(state.accountList[index]);
                        },
                      );
                    },
                    itemCount: state.accountList.length
                ),
                const SizedBox(height: 10)
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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<AccountBloc>().add(AccountFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
