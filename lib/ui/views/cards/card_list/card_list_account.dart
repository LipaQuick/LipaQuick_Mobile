import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/cards/bloc/card_list_bloc.dart';
import 'package:lipa_quick/core/models/cards/bloc/card_list_event.dart';
import 'package:lipa_quick/core/models/cards/bloc/card_list_state.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/views/cards/add_card.dart';
import 'package:lipa_quick/ui/views/cards/card_list/card_item.dart';
import '../../../../core/services/blocs/account/account_list_event.dart';
import '../../../shared/app_colors.dart';
import '../../../shared/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../login_view.dart';

class CardListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.getAppBar(
          context: context,
          title: AppLocalizations.of(context)!.cards_title,
          subTitle: "",
          enableBack: true),
      body: BlocProvider(
        create: (_) => CardBloc()..add(CardsFetched()),
        child: const ListCardPage(),
      ),
    );
  }
}

class ListCardPage extends StatefulWidget {
  const ListCardPage({Key? key}) : super(key: key);

  @override
  State<ListCardPage> createState() => _ListCardPageState();
}

class _ListCardPageState extends State<ListCardPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardBloc, CardsState>(listener:(context, state){
      if(state.status == ApiStatus.failure){
        if(state.errorMessage!.contains("delete")){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text(state.errorMessage!),
                showCloseIcon: true),
          );
        }
      }
    } , child: BlocBuilder<CardBloc, CardsState>(
      builder: (context, state) {
        if (state.status == ApiStatus.authFailed) {
          return AuthorizationFailedWidget(callback: () async {
            // LocalSharedPref().clearLoginDetails().then((value) => {
            //       Navigator.of(context).pushAndRemoveUntil(
            //           MaterialPageRoute(builder: (context) => LoginPage()),
            //           (Route<dynamic> route) => false)
            //     });
            //await LocalSharedPref().clearLoginDetails();
            goToLoginPage(context);
          });
        }
        else if (state.status == ApiStatus.empty) {
          return EmptyViewFailedWidget(
              title: AppLocalizations.of(context)!.cards_error_title,
              message: AppLocalizations.of(context)!.something_went_wrong_hint,
              icon: Icons.account_balance,
              buttonHint: AppLocalizations.of(context)!.go_back_hint,
              callback: () {
                Navigator.of(context).pop();
              });
        }
        else if (state.status == ApiStatus.success) {
          if (state.cardList.isEmpty) {
            return EmptyViewFailedWidget(
                title: AppLocalizations.of(context)!.cards_error_title,
                message:
                AppLocalizations.of(context)!.no_cards_added,
                icon: Icons.account_balance,
                buttonHint: AppLocalizations.of(context)!.add_card_title,
                callback: () {
                  addCards();
                });
          }
          //Text('Remove',
          //                         style: GoogleFonts.poppins(
          //                             fontWeight: FontWeight.w700,
          //                             fontSize: 14,
          //                             color: appGreen400))
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext con, int index) {
                    return InkWell(
                      child: CardListItem(state.cardList[index],
                          onRemoveSelected: (value) =>
                              onItemDeleted(value))
                      , onTap: () {
                      showMoreActions(
                          state.cardList[index], context.read<CardBloc>());
                    },);
                  },
                  itemCount: state.cardList.length),
              const SizedBox(height: 10),
              _rectBorderWithPaddingWidget
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    ),);
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
                addCards();
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.add_new_card_title,
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
    if (_isBottom) context.read<CardBloc>().add(AccountFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future addCards() async {
    final bool? result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (context) => AddCardPage(goToHome: false,),
            settings: const RouteSettings(name: 'AddCard')));

    if (result != null && result) {
      context.read<CardBloc>().add(CardsFetched());
    }
  }

  onItemDeleted(CardDetailsModel value) {
    context.read<CardBloc>().add(CardDeleteEvent(value));
  }

  void showMoreActions(CardDetailsModel cardList, CardBloc read) {
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
                AppLocalizations.of(context)!.dropdown_more_hint,
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
                      cardList.isPrimary = true;
                      read.add(CardDefaultEvent(cardList));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: Text(AppLocalizations.of(context)!.remove_card_hint),
                    onTap: (){
                      Navigator.of(context).pop();
                      read.add(CardDeleteEvent(cardList));
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
