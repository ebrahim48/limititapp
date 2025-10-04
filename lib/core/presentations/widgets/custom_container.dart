import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.child,
    this.color,
    this.linearColors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.bordersColor,
    this.border,
    this.height,
    this.width,
    this.radiusAll,
    this.borderWidth = 1.0,
    this.shape = BoxShape.rectangle,
    this.horizontalPadding,
    this.verticalPadding,
    this.horizontalMargin,
    this.verticalMargin,
    this.alignment,
    this.onTap,
    this.marginLeft,
    this.marginRight,
    this.paddingLeft,
    this.paddingRight,
    this.boxShadow,
    this.topLeftRadius,
    this.topRightRadius,
    this.bottomLeft,
    this.bottomRight,
    this.elevation = false,
    this.paddingAll,
    this.marginAll,
  });

  final Widget? child;
  final Color? color;
  final List<Color>? linearColors;
  final Alignment begin;
  final Alignment end;
  final Alignment? alignment;
  final Color? bordersColor;
  final double borderWidth;
  final BoxBorder? border;
  final BoxShape shape;
  final double? radiusAll;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? horizontalMargin;
  final double? marginLeft;
  final double? marginRight;
  final double? marginAll;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingAll;
  final double? verticalMargin;
  final double? height;
  final double? width;
  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomLeft;
  final double? bottomRight;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: horizontalPadding != null || verticalPadding != null
            ? EdgeInsets.symmetric(
                horizontal: horizontalPadding ?? 0,
                vertical: verticalPadding ?? 0,
              )
            : paddingLeft != null || paddingRight != null
                ? EdgeInsets.only(
                    left: paddingLeft ?? 0,
                    right: paddingRight ?? 0,
                  )
                : paddingAll != null
                    ? EdgeInsets.all(paddingAll ?? 0)
                    : null,
        margin: horizontalMargin != null || verticalMargin != null
            ? EdgeInsets.symmetric(
                horizontal: horizontalMargin ?? 0,
                vertical: verticalMargin ?? 0,
              )
            : marginLeft != null || marginRight != null
                ? EdgeInsets.only(
                    left: marginLeft ?? 0,
                    right: marginRight ?? 0,
                  )
                : marginAll != null
                    ? EdgeInsets.all(marginAll ?? 0)
                    : null,
        alignment: alignment,
        decoration: BoxDecoration(
          boxShadow: boxShadow ??
              (elevation
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ]
                  : null),
          shape: shape,
          border: border ??
              (bordersColor != null
                  ? Border.all(color: bordersColor!, width: borderWidth)
                  : null),
          color: color,
          gradient: linearColors != null
              ? LinearGradient(
                  colors: linearColors!,
                  begin: begin,
                  end: end,
                )
              : null,
          borderRadius: (shape == BoxShape.rectangle && radiusAll != null)
              ? BorderRadius.circular(radiusAll!.r)
              : (topLeftRadius != null ||
                      topRightRadius != null ||
                      bottomLeft != null ||
                      bottomRight != null)
                  ? BorderRadius.only(
                      topLeft: Radius.circular(topLeftRadius ?? 0),
                      topRight: Radius.circular(topRightRadius ?? 0),
                      bottomLeft: Radius.circular(bottomLeft ?? 0),
                      bottomRight: Radius.circular(bottomRight ?? 0),
                    )
                  : null,
        ),
        child: child,
      ),
    );
  }
}
