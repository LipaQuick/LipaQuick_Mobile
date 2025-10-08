import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';

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

class AccountListItem extends StatelessWidget {
  final AccountDetails? post;
  AccountDetails? preselected;

  AccountListItem(this.post, {Key? key, this.preselected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
        margin: EdgeInsets.only(top: 10),
      color: Colors.white,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: getBorderSelection(post, preselected),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              SizedBox(
                width: 40,
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      child: post!.getLogo() != null?ImageUtil().imageFromBase64String(post!.getLogo()!, 40, 40)
                          :const FlutterLogo(size: 30),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          post!.bank ?? '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mulish(
                              color:Color(0xff142c06) ,
                              fontSize: 16,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                        SizedBox(height: 4),
                        SizedBox(
                          width: 245,
                          child: Text(
                            post!.accountNumber != null ? post!.accountNumber!.substring(post!.accountNumber!.length-4):'',
                            style: GoogleFonts.poppins(
                                fontSize: 12
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Visibility(child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        post!.primary != null ? post!.primary!?'Primary':'':'',
                        style: GoogleFonts.poppins(
                            color: Color(0xffbebebe),
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ), visible: post!.primary!,),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  BoxBorder getBorderSelection(AccountDetails? post, AccountDetails? preselected) {
    print('Post ${post.toString()}, preselected ${preselected.toString()}');
    if(preselected == null){
      return post!.primary!
          ?Border.all(color: const Color(0xff3bb143), width: 1)
          :Border.all(color: Colors.white, width: 0);
    }else {
      return preselected.id == post!.id
          ? Border.all(color: const Color(0xff3bb143), width: 1)
          : Border.all(color: Colors.white, width: 0);
    }
  }
}

class PaymentAccountListItem extends StatelessWidget {
  final AccountDetails? post;
  AccountDetails? preselected;

  PaymentAccountListItem(this.post, {Key? key, this.preselected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(
                      post!.bank ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mulish(
                          color:Color(0xff142c06) ,
                          fontSize: 16,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: 245,
                      child: Text(
                        post!.accountNumber != null ? post!.accountNumber!.substring(post!.accountNumber!.length-4):'',
                        style: GoogleFonts.poppins(
                            fontSize: 12
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Visibility(child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    post!.primary != null ? post!.primary!?'Primary':'':'',
                    style: GoogleFonts.poppins(
                        color: Color(0xffbebebe),
                        fontSize: 12,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ), visible: post!.primary!,),
              ],
            ),
          ),
          SizedBox(width: 16),
          SizedBox(
            width: 40,
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: post!.getLogo() != null?ImageUtil().imageFromBase64String(post!.getLogo()!, 40, 40)
                      :const FlutterLogo(size: 30),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  BoxBorder getBorderSelection(AccountDetails? post, AccountDetails? preselected) {
    print('Post ${post.toString()}, preselected ${preselected.toString()}');
    if(preselected == null){
      return post!.primary!
          ?Border.all(color: const Color(0xff3bb143), width: 1)
          :Border.all(color: Colors.white, width: 0);
    }else {
      return preselected.id == post!.id
          ? Border.all(color: const Color(0xff3bb143), width: 1)
          : Border.all(color: Colors.white, width: 0);
    }
  }
}
