import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_bloc.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_event.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/ui/AppColorBuilder.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/add_account/banks/bank_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BankPage extends StatelessWidget {
  String titleMessage;
  final ValueChanged<BankDetails> voidCallback;
  BankPage(this.voidCallback, this.titleMessage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appGrey200,
      body: BlocProvider(
        create: (_) => BankBloc(httpClient: http.Client())..add(BanksFetched()),
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
                    titleMessage,
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
            Expanded(child: BanksList(voidCallback))
          ],
        ),
      ),
    );
  }
}

class BanksList extends StatefulWidget {
  final ValueChanged<BankDetails> voidCallback;
 const BanksList(this.voidCallback, {Key? key}) : super(key: key);

  @override
  State<BanksList> createState() => _BanksListState();
}

class _BanksListState extends State<BanksList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        switch (state.status) {
          case ApiStatus.authFailed:
            return Center(child: Text(AppLocalizations.of(context)!.session_time_out_hint));
          case ApiStatus.failure:
          case ApiStatus.empty:
            return Center(child: Text(AppLocalizations.of(context)!.something_went_wrong_hint));
        case ApiStatus.success:
            if (state.banks.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.banks_not_found_hint));
            }
            int crossAxizCount = MediaQuery.of(context).size.width.toInt() >= 600 ? 5 : 4;
            //debugPrint('CrossAxizCount $crossAxizCount');
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxizCount),
              itemBuilder: (BuildContext con, int index) {
                return BankListItem(state.banks[index], widget.voidCallback);
              },
            itemCount: state.banks.length);
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
    if (_isBottom) context.read<BankBloc>().add(BanksFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}