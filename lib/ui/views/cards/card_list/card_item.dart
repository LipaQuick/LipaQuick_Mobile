import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';
import 'package:lipa_quick/ui/views/cards/utils/card_utils.dart';

class BottomLoader extends StatelessWidget {
  const BottomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}

enum PopUpItems { itemOne }

typedef CardDetailsValue = CardDetailsModel Function(CardDetailsModel);

class CardListItem extends StatelessWidget {
  final CardDetailsModel? post;
  final PopUpItems? selectedMenu;
  final CardDetailsValue? onRemoveSelected;

  const CardListItem(this.post, {Key? key, this.selectedMenu, this.onRemoveSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    CardType type = CardUtils.getCardTypeFrmNumber(post!.cardNumber ?? '');
    return Card(
        margin: EdgeInsets.only(top: 10),
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 0),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 40,
                            height: 40,
                            child: CardUtils.getCardIcon(type)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post!.nameOnCard ?? '',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.mulish(
                                  color: const Color(0xff142c06),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 245,
                              child: Text(
                                post!.cardNumber ?? '',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Visibility(child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            post!.isPrimary != null ? post!.isPrimary!?'Primary':'':'',
                            style: GoogleFonts.poppins(
                                color: Color(0xffbebebe),
                                fontSize: 12,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ), visible: post!.isPrimary!,)
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class PaymentCardListItem extends StatelessWidget {
  final CardDetailsModel? post;
  final PopUpItems? selectedMenu;
  final CardDetailsValue? onRemoveSelected;

  const PaymentCardListItem(this.post, {Key? key, this.selectedMenu, this.onRemoveSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    CardType type = CardUtils.getCardTypeFrmNumber(post!.cardNumber ?? '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post!.nameOnCard ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mulish(
                          color: const Color(0xff142c06),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 245,
                      child: Text(
                        post!.cardNumber ?? '',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 40,
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 40,
                    height: 40,
                    child: CardUtils.getCardIcon(type)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
