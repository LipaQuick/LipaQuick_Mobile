/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class $AssetsIconGen {
  const $AssetsIconGen();

  /// File path: assets/icon/Bank.png
  AssetGenImage get bank => const AssetGenImage('assets/icon/Bank.png');

  /// File path: assets/icon/Bills.png
  AssetGenImage get bills => const AssetGenImage('assets/icon/Bills.png');

  /// File path: assets/icon/Call.png
  AssetGenImage get call => const AssetGenImage('assets/icon/Call.png');

  /// File path: assets/icon/Payment.png
  AssetGenImage get payment => const AssetGenImage('assets/icon/Payment.png');

  /// File path: assets/icon/QR.png
  AssetGenImage get qr => const AssetGenImage('assets/icon/QR.png');

  /// File path: assets/icon/Store.png
  AssetGenImage get store => const AssetGenImage('assets/icon/Store.png');

  /// File path: assets/icon/Timeout.png
  AssetGenImage get timeout => const AssetGenImage('assets/icon/Timeout.png');

  /// File path: assets/icon/Users.png
  AssetGenImage get users => const AssetGenImage('assets/icon/Users.png');

  /// File path: assets/icon/brand_new.png
  AssetGenImage get brandNew =>
      const AssetGenImage('assets/icon/brand_new.png');

  /// File path: assets/icon/clap.svg
  SvgGenImage get clap => const SvgGenImage('assets/icon/clap.svg');

  /// File path: assets/icon/clap_filled.svg
  SvgGenImage get clapFilled =>
      const SvgGenImage('assets/icon/clap_filled.svg');

  /// File path: assets/icon/dead_end.svg
  SvgGenImage get deadEnd => const SvgGenImage('assets/icon/dead_end.svg');

  /// File path: assets/icon/ecobank_logo.svg
  SvgGenImage get ecobankLogo =>
      const SvgGenImage('assets/icon/ecobank_logo.svg');

  /// File path: assets/icon/english.png
  AssetGenImage get english => const AssetGenImage('assets/icon/english.png');

  /// File path: assets/icon/france.png
  AssetGenImage get france => const AssetGenImage('assets/icon/france.png');

  /// File path: assets/icon/indonesia.png
  AssetGenImage get indonesia =>
      const AssetGenImage('assets/icon/indonesia.png');

  /// File path: assets/icon/invalid_image.png
  AssetGenImage get invalidImage =>
      const AssetGenImage('assets/icon/invalid_image.png');

  /// File path: assets/icon/lauchericon.png
  AssetGenImage get lauchericon =>
      const AssetGenImage('assets/icon/lauchericon.png');

  /// File path: assets/icon/launchericon_n.png
  AssetGenImage get launchericonN =>
      const AssetGenImage('assets/icon/launchericon_n.png');

  /// File path: assets/icon/master_card_icon.png
  AssetGenImage get masterCardIcon =>
      const AssetGenImage('assets/icon/master_card_icon.png');

  /// File path: assets/icon/mtnmomo.svg
  SvgGenImage get mtnmomo => const SvgGenImage('assets/icon/mtnmomo.svg');

  /// File path: assets/icon/no_internet.svg
  SvgGenImage get noInternet =>
      const SvgGenImage('assets/icon/no_internet.svg');

  /// File path: assets/icon/onboarding.svg
  SvgGenImage get onboarding => const SvgGenImage('assets/icon/onboarding.svg');

  /// File path: assets/icon/rwanda.png
  AssetGenImage get rwanda => const AssetGenImage('assets/icon/rwanda.png');

  /// File path: assets/icon/verve_icon.png
  AssetGenImage get verveIcon =>
      const AssetGenImage('assets/icon/verve_icon.png');

  /// File path: assets/icon/visa_icon.png
  AssetGenImage get visaIcon =>
      const AssetGenImage('assets/icon/visa_icon.png');

  /// File path: assets/icon/wallet_link_illustration.svg
  SvgGenImage get walletLinkIllustration =>
      const SvgGenImage('assets/icon/wallet_link_illustration.svg');

  /// List of all assets
  List<dynamic> get values => [
        bank,
        bills,
        call,
        payment,
        qr,
        store,
        timeout,
        users,
        brandNew,
        clap,
        clapFilled,
        deadEnd,
        ecobankLogo,
        english,
        france,
        indonesia,
        invalidImage,
        lauchericon,
        launchericonN,
        masterCardIcon,
        mtnmomo,
        noInternet,
        onboarding,
        rwanda,
        verveIcon,
        visaIcon,
        walletLinkIllustration
      ];
}

class Assets {
  Assets._();

  static const $AssetsIconGen icon = $AssetsIconGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final BytesLoader loader;
    if (_isVecFormat) {
      loader = AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
