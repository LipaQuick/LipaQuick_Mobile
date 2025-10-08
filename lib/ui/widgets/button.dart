
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum CustomButtonState {
  Default,
  Processing,
}

enum CustomButtonType {
  Raised,
  Flat,
  Outline,
}

class CustomLoadingButton extends StatefulWidget {
  final Widget? defaultWidget;
  final Widget? progressWidget;
  final Function? onPressed;
  final CustomButtonType type;
  final Color? color;
  final double width;
  final double height;
  final double borderRadius;
  final bool animate;

  CustomLoadingButton({
    Key? key,
    this.defaultWidget,
    this.progressWidget,
    this.onPressed,
    this.type = CustomButtonType.Raised,
    this.color = const Color(0xFF3BB143),
    this.width = double.infinity,
    this.height = 40.0,
    this.borderRadius = 2.0,
    this.animate = true,
  }) : super(key: key);

  @override
  _CustomLoadingButtonState createState() => _CustomLoadingButtonState();
}

class _CustomLoadingButtonState extends State<CustomLoadingButton>
    with TickerProviderStateMixin {
  GlobalKey _globalKey = GlobalKey();
  Animation? _anim;
  AnimationController? _animController;
  Duration _duration = const Duration(milliseconds: 250);
  CustomButtonState? _state;
  double? _width;
  double? _height;
  double? _borderRadius;

  @override
  dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _reset();
    super.deactivate();
  }

  @override
  void initState() {
    _reset();
    super.initState();
  }

  void _reset() {
    _state = CustomButtonState.Default;
    _width = widget.width;
    _height = widget.height;
    _borderRadius = widget.borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_borderRadius!),
      child: SizedBox(
        key: _globalKey,
        height: _height,
        width: _width,
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    var padding = const EdgeInsets.all(0.0);
    var color = widget.color;
    var shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius!));
    var buttonStyle = ButtonStyle(padding: MaterialStateProperty.all(padding)
        , backgroundColor: MaterialStateProperty.all(color), shape: MaterialStateProperty.all(shape));

    var elevatedButtonStyle = ButtonStyle(padding: MaterialStateProperty.all(padding)
        , backgroundColor: MaterialStateProperty.all(color)
        , shape: MaterialStateProperty.all(shape)
        , elevation: MaterialStateProperty.all(8.0));

    switch (widget.type) {
      case CustomButtonType.Raised:
        return ElevatedButton(
          style: elevatedButtonStyle,
          child: _buildChildren(context)!,
          onPressed: _onButtonPressed(),
        );
      case CustomButtonType.Flat:
        return ElevatedButton(
          style: buttonStyle,
          child: _buildChildren(context)!,
          onPressed: _onButtonPressed(),
        );
      case CustomButtonType.Outline:
        return TextButton(
          style: buttonStyle,
          child: _buildChildren(context)!,
          onPressed: _onButtonPressed(),
        );
    }
  }

  Widget? _buildChildren(BuildContext context) {
    Widget? ret;
    switch (_state) {
      case CustomButtonState.Default:
        ret = widget.defaultWidget!;
        break;
      case CustomButtonState.Processing:
        ret = widget.progressWidget ?? widget.defaultWidget!;
        break;
    }
    return ret;
  }

  Future<void> Function()? _onButtonPressed() {
    return widget.onPressed == null
        ? null
        : () async {
      if (_state != CustomButtonState.Default) {
        return;
      }

      // The result of widget.onPressed() will be called as VoidCallback after button status is back to default.
      VoidCallback? onDefault;
      if (widget.animate) {
        _toProcessing();
        _forward((status) {
          if (status == AnimationStatus.dismissed) {
            _toDefault();
            if (onDefault != null && onDefault is VoidCallback) {
              onDefault();
            }
          }
        });
        onDefault = await widget.onPressed!();
        _reverse();
      } else {
        _toProcessing();
        onDefault = await widget.onPressed!();
        _toDefault();
        if (onDefault != null && onDefault is VoidCallback) {
          onDefault();
        }
      }
    };
  }

  void _toProcessing() {
    setState(() {
      _state = CustomButtonState.Processing;
    });
  }

  void _toDefault() {
    if (mounted) {
      setState(() {
        _state = CustomButtonState.Default;
      });
    } else {
      _state = CustomButtonState.Default;
    }
  }

  void _forward(AnimationStatusListener stateListener) {
    double initialWidth = _globalKey.currentContext!.size!.width;
    double initialBorderRadius = widget.borderRadius;
    double targetWidth = _height!;
    double targetBorderRadius = _height! / 2;

    _animController = AnimationController(duration: _duration, vsync: this);
    _anim = Tween(begin: 0.0, end: 1.0).animate(_animController!)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - targetWidth) * _anim!.value!);
          _borderRadius = initialBorderRadius -
              ((initialBorderRadius - targetBorderRadius) * _anim!.value!);
        });
      })
      ..addStatusListener(stateListener);

    _animController!.forward();
  }

  void _reverse() {
    _animController!.reverse();
  }
}