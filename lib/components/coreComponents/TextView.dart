import 'package:bwssb/components/styles/textStyles.dart';
import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  final String text;
  final dynamic color;
  final dynamic underlineColor;
  final TextStyle? style;
  final bool? underline;
  final bool? strikeThrough;
  final dynamic textSize;
  final bool? capitalise;
  final int? maxlines;
  final TextAlign? textAlign;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? lineHeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final TextOverflow? overflow;
  final EdgeInsets? margin;
  final Function()? onTap;
  final bool visible;
  final Gradient? gradient;

  const TextView({
    super.key,
    required this.text,
    this.color,
    this.style,
    this.maxlines,
    this.textAlign,
    this.underline,
    this.textSize,
    this.fontFamily,
    this.fontWeight,
    this.lineHeight,
    this.fontStyle,
    this.underlineColor,
    this.strikeThrough,
    this.capitalise,
    this.letterSpacing,
    this.overflow,
    this.margin,
    this.onTap,
    this.visible = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: gradient != null
              ? ShaderMask(
            shaderCallback: (bounds) {
              return gradient!.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              );
            },
            child: Text(
              capitalise != null && capitalise! ? text.toUpperCase() : text,
              maxLines: maxlines,
              overflow: maxlines != null ? TextOverflow.ellipsis : null,
              textAlign: textAlign,
              style: (style ?? 14.txtBoldWhite).copyWith(
                color: Colors.white, // Important for ShaderMask
              ),
            ),
          )
              : Text(
            capitalise != null && capitalise! ? text.toUpperCase() : text,
            maxLines: maxlines,
            overflow: maxlines != null ? TextOverflow.ellipsis : null,
            textAlign: textAlign,
            style: style ?? 14.txtBoldWhite,
          ),
        ),
      ),
    );
  }
}
