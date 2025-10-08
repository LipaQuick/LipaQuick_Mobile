import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/discount/discount_model.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/text_styles/text_style.dart';

class DiscountListingPage extends StatefulWidget {
  List<DiscountItems>? discounts;
  DiscountItems? selectedDiscount;
  DiscountItems? currentSelectedDiscount;

  DiscountListingPage(this.discounts, {this.currentSelectedDiscount});

  @override
  _DiscountListingPageState createState() => _DiscountListingPageState();
}

class _DiscountListingPageState extends State<DiscountListingPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.currentSelectedDiscount != null){
      setState(() {
        widget.selectedDiscount = widget.currentSelectedDiscount;
        debugPrint('State ${widget.selectedDiscount!.discountId}');
        debugPrint('Current ${widget.currentSelectedDiscount!.discountId}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.getAppBar(
          context: context, title: 'Discount', subTitle: '', enableBack: true),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.discounts!.length,
              itemBuilder: (context, index) {
                final discount = widget.discounts![index];
                final isSelected = discount.discountId == widget.selectedDiscount?.discountId!;
                print('Item ${discount.discountId}');
                print('Selected ${widget.selectedDiscount?.discountId!}');
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getHeaderWidget(discount),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(isSelected ? 'Applied' : 'Apply',
                                style: ThemeText.subHeadingTextStyle),
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        widget.selectedDiscount = discount;
                        Navigator.pop(context, widget.selectedDiscount!);
                      });
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  getHeaderWidget(DiscountItems discount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.discount, color: appGreen400),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '${getAmountOff(discount)} OFF',
                style: ThemeText.subHeadingTextStyle,
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 50),
          child:  Text('${getHintMessage(discount)}', style:  GoogleFonts.poppins(textStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14))),
        ),
        SizedBox(height: 10,),
        Container(
          margin: EdgeInsets.only(left: 50),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              border: Border.all(color: appGreen400)),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              discount.discountCode!.toUpperCase(),
              style: ThemeText.titleTextStyle,
            ),
          ),
        )
      ],
    );
  }

  String getAmountOff(DiscountItems discount) {
    if (discount.amountPercentageActive!) {
      return 'Get ${discount.amountPercentage} %';
    } else {
      return 'Flat ${discount.flatAmount}';
    }
  }

  String getHintMessage(DiscountItems discount) {
    if (discount.amountPercentageActive!) {
      return 'Get upto ${discount.amountPercentage} % off, when you pay using LipaQuick';
    } else {
      return 'Get Flat ${discount.flatAmount} off, when you pay using LipaQuick';
    }
  }
}
