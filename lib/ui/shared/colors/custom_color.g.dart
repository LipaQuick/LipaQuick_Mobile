import 'package:flutter/material.dart';

const CustomColor1 = Color(0xFFA461B8);

CustomColors lightCustomColors = const CustomColors(
  CustomColor1: Color(0xFF844398),
  onCustomColor1: Color(0xFFFFFFFF),
  CustomColor1Container: Color(0xFFFAD7FF),
  onCustomColor1Container: Color(0xFF330044),
);

CustomColors darkCustomColors = const CustomColors(
  CustomColor1: Color(0xFFF0B0FF),
  onCustomColor1: Color(0xFF500E66),
  CustomColor1Container: Color(0xFF6A2A7E),
  onCustomColor1Container: Color(0xFFFAD7FF),
);

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.CustomColor1,
    required this.onCustomColor1,
    required this.CustomColor1Container,
    required this.onCustomColor1Container,
  });

  final Color? CustomColor1;
  final Color? onCustomColor1;
  final Color? CustomColor1Container;
  final Color? onCustomColor1Container;

  @override
  CustomColors copyWith({
    Color? CustomColor1,
    Color? onCustomColor1,
    Color? CustomColor1Container,
    Color? onCustomColor1Container,
  }) {
    return CustomColors(
      CustomColor1: CustomColor1 ?? this.CustomColor1,
      onCustomColor1: onCustomColor1 ?? this.onCustomColor1,
      CustomColor1Container: CustomColor1Container ?? this.CustomColor1Container,
      onCustomColor1Container: onCustomColor1Container ?? this.onCustomColor1Container,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      CustomColor1: Color.lerp(CustomColor1, other.CustomColor1, t),
      onCustomColor1: Color.lerp(onCustomColor1, other.onCustomColor1, t),
      CustomColor1Container: Color.lerp(CustomColor1Container, other.CustomColor1Container, t),
      onCustomColor1Container: Color.lerp(onCustomColor1Container, other.onCustomColor1Container, t),
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(
    );
  }
}