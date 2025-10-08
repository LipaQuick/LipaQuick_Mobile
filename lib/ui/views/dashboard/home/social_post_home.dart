import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/views/social_post/social_post_create.dart';
import 'package:lipa_quick/ui/views/social_post/social_post_list.dart';

class SocialPostHome extends StatelessWidget {
  //TODO- Implement Bloc Provider for this Social Post
  @override
  Widget build(BuildContext context) {
    return FloatingBottomNavigationWidget();
  }
}

class FloatingBottomNavigationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NavigationBarWidget();
}

class NavigationBarWidget extends State<FloatingBottomNavigationWidget> {
  var currentPage = 0;
  bool _showFab = true;
  late List<Widget> _kTabsPages;

  void _updateTabs() {
    _kTabsPages = <Widget>[
      PostListPage('2', '0', key: const PageStorageKey('public')),
      PostListPage('1', '0', key: const PageStorageKey('Friends')),
      PostListPage('0', '0', key: const PageStorageKey('private'))
    ];
  }

  @override
  void initState() {
    _updateTabs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(currentPage);
    Duration duration = Duration(milliseconds: 300);
    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification){
          final ScrollDirection direction = notification.direction;
          setState(() {
            if (direction == ScrollDirection.reverse) {
              _showFab = false;
            } else if (direction == ScrollDirection.forward) {
              _showFab = true;
            }
          });
          return true;
        },
        child: _kTabsPages.elementAt(currentPage),
      ),
      floatingActionButton: AnimatedSlide(
        duration: duration,
        offset: _showFab ? Offset.zero : Offset(0, 2),
        child: AnimatedOpacity(
          duration: duration,
          opacity: _showFab ? 1 : 0,
          child: buildBottomFloatingAction(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Container buildBottomFloatingAction() {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 0),
          decoration: BoxDecoration(
            color: appGreen50,
            borderRadius: BorderRadius.circular(50),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            height: 40,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.public, color: appSurfaceWhite), label: ''),
              NavigationDestination(
                  icon: Icon(Icons.group, color: appSurfaceWhite), label: ''),
              NavigationDestination(
                  icon: Icon(Icons.person, color: appSurfaceWhite), label: '')
            ],
            selectedIndex: currentPage,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            indicatorColor: appGreen400,
            shadowColor: appSurfaceWhite,
            onDestinationSelected: (int index) {
              setState(() {
                currentPage = index;
              });
            },
          ),
        );
  }
}
