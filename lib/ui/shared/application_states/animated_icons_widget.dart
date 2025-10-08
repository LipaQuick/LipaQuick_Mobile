import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';

class AnimatedInteractionIcons extends StatefulWidget {
  final dynamic activeIcon, inActiveIcons;
  final int count;
  final bool isWidgetChecked;
  final void Function(bool)? onPressed;

  const AnimatedInteractionIcons(
      {Key? key,
      required this.activeIcon,
      required this.inActiveIcons,
      required this.count,
      required this.isWidgetChecked,
      this.onPressed})
      : super(key: key);

  @override
  State<AnimatedInteractionIcons> createState() =>
      _AnimatedInteractionIconsState(isWidgetChecked);
}

class _AnimatedInteractionIconsState extends State<AnimatedInteractionIcons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);

  bool isItemChecked = false;

  _AnimatedInteractionIconsState(this.isItemChecked);


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('IsWidgetChecked ${isItemChecked} Count: ${widget.count}');
    return GestureDetector(
      onTap: () {
        setState(() {
          isItemChecked = !isItemChecked;
        });
        _controller.reverse().then((value) => _controller.forward());

        if (widget.onPressed != null) {
          widget.onPressed!(isItemChecked);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
              child: isItemChecked
                  ? getActiveIcons()
                  : getInActiveIcons(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: Text(
              '${widget.count}',
              style: GoogleFonts.poppins(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget getActiveIcons() {
    if(widget.activeIcon is IconData){
      return Icon(
        widget.activeIcon,
        size: 24,
        color: appGreen400,
      );
    }else{
      SvgGenImage currentIcon = widget.inActiveIcons;
      return currentIcon.svg(height: 24, width: 24, colorFilter: const ColorFilter.mode(appGreen400, BlendMode.srcIn));
    }
  }
  Widget getInActiveIcons() {
    if(widget.inActiveIcons is IconData){
      return Icon(
        widget.inActiveIcons,
        size: 24,
      );
    }else{
      SvgGenImage currentIcon = widget.inActiveIcons;
      return currentIcon.svg(height: 26, width: 26);
    }
  }
}

class SocialInteractionIcons extends StatelessWidget {
  final dynamic activeIcon, inActiveIcons;
  final int count;
  final bool isItemChecked;
  final Animation<double> scaleAnimation;
  final void Function(bool)? onPressed;

  const SocialInteractionIcons({
    Key? key,
    required this.activeIcon,
    required this.inActiveIcons,
    required this.count,
    required this.isItemChecked,
    required this.scaleAnimation,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('IsWidgetChecked $isItemChecked Count: $count');
    return GestureDetector(
      onTap: () {
        onPressed?.call(!isItemChecked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ScaleTransition(
              scale: scaleAnimation,
              child: isItemChecked ? getActiveIcons() : getInActiveIcons(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: Text(
              '$count',
              style: GoogleFonts.poppins(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget getActiveIcons() {
    if (activeIcon is IconData) {
      return Icon(
        activeIcon,
        size: 24,
        color: appGreen400,
      );
    } else {
      SvgGenImage currentIcon = activeIcon;
      return currentIcon.svg(
        height: 24,
        width: 24,
        colorFilter: const ColorFilter.mode(appGreen400, BlendMode.srcIn),
      );
    }
  }

  Widget getInActiveIcons() {
    if (inActiveIcons is IconData) {
      return Icon(
        inActiveIcons,
        size: 24,
      );
    } else {
      SvgGenImage currentIcon = inActiveIcons;
      return currentIcon.svg(height: 26, width: 26);
    }
  }
}

