import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/services/blocs/account/account_list_state.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/add_account/account_list/account_item.dart';
import 'package:lipa_quick/ui/views/add_account/add_account.dart';
import 'package:lipa_quick/ui/views/login_view.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/services/blocs/account/account_list_bloc.dart';
import '../../../../core/services/blocs/account/account_list_event.dart';
import '../../../AppColorBuilder.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.getAppBar(
          context: context,
          title: AppLocalizations.of(context)!.user_account_hint,
          subTitle: "",
          enableBack: true),
      body: BlocProvider(
        create: (_) => AccountBloc()..add(AccountFetched()),
        child: const ListAccountPage(),
      ),
    );
  }
}

class ListAccountPage extends StatefulWidget {
  const ListAccountPage({Key? key}) : super(key: key);

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
                //await LocalSharedPref().clearLoginDetails();
                // var router = GoRouter.of(context);
                // var navigator = Navigator.of(context);
                // while (
                // router.routerDelegate.currentConfiguration.matches.last.matchedLocation !=
                //     LipaQuickAppRouteMap.login) {
                //   if (!navigator.canPop()) {
                //     return;
                //   }
                //   navigator.pop();
                // }
                //context.go(LipaQuickAppRouteMap.login);
                goToLoginPage(context);
              // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage())
              //     , (Route<dynamic> route) => route.isFirst)
            });
          case ApiStatus.failure:
          case ApiStatus.empty:
            return EmptyViewFailedWidget(title:AppLocalizations.of(context)!.bank_account_hint
                , message:AppLocalizations.of(context)!.something_went_wrong_hint
                , icon:Icons.account_balance
                , buttonHint:AppLocalizations.of(context)!.go_back_hint
                , callback: (){
                  Navigator.of(context).pop();
                });
          case ApiStatus.success:
            if (state.accountList.isEmpty) {
              return EmptyViewFailedWidget(title:AppLocalizations.of(context)!.bank_account_hint
                  , message:AppLocalizations.of(context)!.empty_bank_account_hint
                  , icon:Icons.account_balance
                  , buttonHint:AppLocalizations.of(context)!.add_account_hint
                  , callback: (){
                    addBankAccount();
              });
            }
            return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(10.0),
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext con, int index) {
                      return InkWell(
                        child: AccountListItem(state.accountList[index]),
                        onTap: (){
                          showMoreActions(state.accountList[index], context.read<AccountBloc>());
                        },
                      );
                    },
                    itemCount: state.accountList.length),
                const SizedBox(height: 10),
                _rectBorderWithPaddingWidget
              ],
            );
          case ApiStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget get _rectBorderWithPaddingWidget {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      padding: EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Container(
          height: 40,
          width: double.infinity,
          alignment: Alignment.center,
          child: TextButton.icon(
              onPressed: () {
                addBankAccount();
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.add_account_hint,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: appSurfaceBlack,
                      fontWeight: FontWeight.w600))),
        ),
      ),
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

  Future addBankAccount() async {
    final bool? result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (context) => AddAccountPage(false)));

    if (result != null && result) {
      context.read<AccountBloc>().add(AccountFetched());
    }
  }

  void showMoreActions(AccountDetails accountList, AccountBloc bloc) {
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
                    title: Text(AppLocalizations.of(context)!.set_as_default_hint),
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
                    title: Text(AppLocalizations.of(context)!.delete_hint),
                    onTap: (){
                      Navigator.of(context).pop();
                      if(accountList.primary!){
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content:
                            Text(AppLocalizations.of(context)!.default_account_delete_hint),
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
                      }else{
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
}
