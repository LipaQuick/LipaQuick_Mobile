import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/managers/social_post/social_bloc.dart';
import 'package:lipa_quick/core/managers/social_post/social_event.dart';
import 'package:lipa_quick/core/managers/social_post/social_state.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/cards/bloc/card_list_bloc.dart';
import 'package:lipa_quick/core/models/cards/bloc/card_list_event.dart';
import 'package:lipa_quick/core/models/cards/bloc/card_list_state.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/core/models/social_post/social_post_response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/cards/add_card.dart';
import 'package:lipa_quick/ui/views/cards/card_list/card_item.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/social_post/post_item.dart';
import 'package:lipa_quick/ui/views/social_post/social_post_create.dart';
import '../../../../core/services/blocs/account/account_list_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SocialPostListPage extends StatelessWidget {
  String visibility;
  String sortBy;

  SocialPostListPage(this.visibility, this.sortBy);

  @override
  Widget build(BuildContext context) {
    debugPrint('Visibilty $visibility and Sort By $sortBy');
    return Scaffold(
      body: BlocProvider(
        create: (_) => SocialPostBloc(locator<Api>()),
        child: PostListPage(visibility, sortBy),
      ),
    );
  }
}

class PostListPage extends StatefulWidget {
  String visibility;
  String sortBy;

  PostListPage(this.visibility, this.sortBy, {Key? key}) : super(key: key);

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> with SingleTickerProviderStateMixin{
  final _scrollController = ScrollController();
  late final AnimationController _controller;

  @override
  void initState() {
    context
        .read<SocialPostBloc>()
        .add(GetPostEvent(widget.visibility, widget.sortBy));
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocialPostBloc, PostState>(listener: (context, state){
      if(state.status == PostApiStatus.interactionFailed ){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.messages),
              showCloseIcon: true),
        );
      }
    }, child: BlocBuilder<SocialPostBloc, PostState>(
      builder: (context, state) {
        if (state.status == PostApiStatus.authFailed) {
          return AuthorizationFailedWidget(callback: () async {
            // LocalSharedPref().clearLoginDetails().then((value) => {
            //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage())
            //       , (Route<dynamic> route) => route.isFirst)
            //     });
            //await LocalSharedPref().clearLoginDetails();
            goToLoginPage(context);
          });
        }
        else if (state.status == PostApiStatus.failure) {
          return EmptyViewFailedWidget(
            title: AppLocalizations.of(context)!.social_post,
            message: state.messages,
            icon: Icons.social_distance,
            buttonHint: AppLocalizations.of(context)!.reload_hint,
            callback: () {
              context
                  .read<SocialPostBloc>()
                  .add(GetPostEvent(widget.visibility, widget.sortBy));
            },
          );
        } else if (state.status == PostApiStatus.empty) {
          return EmptyViewFailedWidget(
            title: AppLocalizations.of(context)!.social_post,
            message: AppLocalizations.of(context)!.no_social_post_found,
            icon: Icons.social_distance,
            buttonHint: AppLocalizations.of(context)!.reload_hint,
            callback: () {
              context
                  .read<SocialPostBloc>()
                  .add(GetPostEvent(widget.visibility, widget.sortBy));
            },
          );
        } else if (
            state.status == PostApiStatus.success) {
          print('Refreshing List');
          if (state.socialPosts.isEmpty) {
            return EmptyViewFailedWidget(
              title: AppLocalizations.of(context)!.social_post,
              message: AppLocalizations.of(context)!.no_social_post_found,
              icon: Icons.social_distance,
              buttonHint: AppLocalizations.of(context)!.reload_hint,
              callback: () {
                context
                    .read<SocialPostBloc>()
                    .add(GetPostEvent(widget.visibility, widget.sortBy));
              },
            );
          }
          return SafeArea(
            minimum: EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        foregroundColor: appGreen400,
                      ),
                      onPressed: () {
                        _showPrivacyBottomSheet(context);
                      },
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Icon(Icons.swap_vert),
                          Text(
                            getSortBy(widget.sortBy),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilder: (BuildContext con, int index) {
                        //print('Item Details : ${state.socialPosts[index].toString()}');
                        return InkWell(
                          child: PostListItem(
                            state.socialPosts[index],
                            controller: _controller,
                            onLiked: (liked) {
                              print('Item Details : ${state.socialPosts[index].toString()}');
                              context.read<SocialPostBloc>().add(
                                SocialPostLikeEvent(
                                  socialPostCreate: state.socialPosts[index],
                                  isLiked: liked,
                                  position: index,
                                ),
                              );
                            },
                            onThumbsUp: (thumbsUp) {
                              print('Item Details : ${state.socialPosts[index].toString()}');
                              context.read<SocialPostBloc>().add(
                                SocialThumbsUpEvent(
                                  socialPostCreate: state.socialPosts[index],
                                  isThumbsUp: thumbsUp,
                                  position: index,
                                ),
                              );
                            },
                            onAppluad: (applauded) {
                              context.read<SocialPostBloc>().add(
                                SocialApplaudEvent(
                                  socialPostCreate: state.socialPosts[index],
                                  isApplaud: applauded,
                                  position: index,
                                ),
                              );
                            },
                          ),
                          onTap: () {},
                        );
                      },
                      itemCount: state.socialPosts.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state.status == PostApiStatus.initial ||
            state.status == PostApiStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Container(); // Fallback in case none of the conditions are met
      },
    ),);

  }

  void _showPrivacyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Wrap(
            children: <Widget>[
              Text(
                'Sort By',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: widget.sortBy == '0'
                    ? Icon(Icons.radio_button_checked, color: appGreen400)
                    : Icon(Icons.radio_button_off),
                title: Text('Most Recent'),
                onTap: () {
                  setState(() {
                    widget.sortBy = '0';
                  });
                  Navigator.pop(context);

                  context.read<SocialPostBloc>().add(GetPostEvent(widget.visibility, widget.sortBy));

                },
              ),
              ListTile(
                leading: widget.sortBy == '1'
                    ? Icon(
                        Icons.radio_button_checked,
                        color: appGreen400,
                      )
                    : Icon(Icons.radio_button_off),
                title: Text('Most Reacted'),
                onTap: () {
                  setState(() {
                    widget.sortBy = '1';
                  });
                  Navigator.pop(context);
                  context.read<SocialPostBloc>().add(GetPostEvent(widget.visibility, widget.sortBy));
                },
              ),
              Divider()
            ],
          ),
        );
      },
    );
  }

  /*
   This is based on following Mapping
   0 - Private
   1 - Friends
   2 - Public
   */
  String getSortBy(String privacy) {
    int flag = int.parse(privacy);
    return flag == 0 ? "Most Recent" : "Most Reacted";
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

    _controller.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context
          .read<SocialPostBloc>()
          .add(GetPagedPostContent(widget.visibility, widget.sortBy));
    }
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
            builder: (context) => AddCardPage(goToHome: true,),
            settings: const RouteSettings(name: 'AddCard')));

    if (result != null && result) {
      context.read<CardBloc>().add(CardsFetched());
    }
  }

  onItemDeleted(PostListItem value) {
    //context.read<CardBloc>().add(CardDeleteEvent(value));
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
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.check_circle,
                  //     color: appGreen400,
                  //   ),
                  //   title: Text('Set as Default'),
                  //   onTap: () {
                  //     Navigator.of(context).pop();
                  //     read.add(AccountDefaultEvent(cardList));
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: Text(AppLocalizations.of(context)!.remove_card_hint),
                    onTap: () {
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
