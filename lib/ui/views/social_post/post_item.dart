import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/core/models/social_post/social_post_response.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/application_states/animated_icons_widget.dart';
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

enum PopUpItems { itemOne }

typedef PostItemValue = PostListItem Function(PostListItem);

class PostListItem extends StatelessWidget {
  final PostItem? post;
  final void Function(bool)? onLiked;
  final void Function(bool)? onThumbsUp;
  final void Function(bool)? onAppluad;
  final PopUpItems? selectedMenu;
  final PostItemValue? onRemoveSelected;
  final AnimationController? controller;

  PostListItem(this.post,
      {Key? key, this.selectedMenu, this.onRemoveSelected, this.onLiked, this.onThumbsUp, this.onAppluad, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Item Details : ${post.toString()}');
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
              padding: const EdgeInsets.all(8),
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
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: ImageUtil().imageFromBase64String(ImageUtil().getBase64Logo(post!.avatar!), 50, 50),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  post!.userName ?? '',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                Text(
                                  post!.remarks ?? '',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  post!.postContent ?? '',
                                  style: GoogleFonts.mulish(
                                      color: const Color(0xff142c06),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.justify,
                                  softWrap: true,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    SocialInteractionIcons(
                                      activeIcon: Icons.favorite,
                                      inActiveIcons: Icons.favorite_border,
                                      count: post!.like,
                                      scaleAnimation: Tween(begin: 0.7, end: 1.0).animate(
                                        CurvedAnimation(parent: controller!, curve: Curves.easeOut),
                                      ),
                                      isItemChecked: post!.isLiked ?? false,
                                      onPressed: (checked) {
                                        onLiked!(checked);
                                      },
                                    ),
                                    SocialInteractionIcons(
                                      activeIcon: Icons.thumb_up,
                                      inActiveIcons: Icons.thumb_up_outlined,
                                      count: post!.thumbsUp,
                                      scaleAnimation: Tween(begin: 0.7, end: 1.0).animate(
                                        CurvedAnimation(parent: controller!, curve: Curves.easeOut),
                                      ),
                                      isItemChecked: post!.isThumbsUp ?? false,
                                      onPressed: (checked) {
                                        onThumbsUp!(checked);
                                      },
                                    ),
                                    SocialInteractionIcons(
                                      activeIcon: Assets.icon.clap,
                                      inActiveIcons: Assets.icon.clap,
                                      count: post!.applaud,
                                      scaleAnimation: Tween(begin: 0.7, end: 1.0).animate(
                                        CurvedAnimation(parent: controller!, curve: Curves.easeOut),
                                      ),
                                      isItemChecked: post!.isApplauded ?? false,
                                      onPressed: (checked) {
                                        onAppluad!(checked);
                                      },
                                    )
                                  ],
                                ),
                                Text(
                                  // _formatDateTime(DateFormat('yyyy-MM-dd hh:mm:ss aaa')
                                  //     .parse(post!.modifiedAt!)),
                                  '',
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(fontSize: 14, color: Colors.grey)),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate = DateFormat('dd, MMM, YYYY').add_jm().format(dateTime);
    return formattedDate;
  }
}
