import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../components/styles/appColors.dart';
enum TextWeight {regular,medium, semiBold, bold,}

extension TextStyles on num{
  TextStyle get txtRegularBlackText => _textStyle(this, AppColors.black, Family.regular);

  TextStyle get txtRegularError => _textStyle(this, AppColors.red, Family.regular);

  TextStyle get txtRegularWhite => _textStyle(this,AppColors.white,Family.regular);
  TextStyle get txtRegularcolor => _textStyle(this,AppColors.primaryColor,Family.regular);
  TextStyle get txtRegularBlack => _textStyle(this,AppColors.black,Family.regular);

  TextStyle get txtMediumWhite => _textStyle(this,AppColors.white,Family.medium);
  TextStyle get txtSBoldBlack => _textStyle(this,AppColors.black,Family.semiBold);
  TextStyle get txtBoldWhite => _textStyle(this,AppColors.white,Family.bold);
  TextStyle get txtBoldBlack => _textStyle(this,AppColors.black,Family.bold);
  TextStyle get txtRegularGrey => _textStyle(this, AppColors.grey, Family.regular);
  TextStyle get txtMediumBlack => _textStyle(this,AppColors.black,Family.medium);

  TextStyle get mediumBlack => _textStyle(this,Colors.orange,Family.medium);
}

extension TextWeights on TextWeight{
  FontWeight get fontWeight {
    if(this == TextWeight.regular){
      return FontWeight.w400;
    }else if(this == TextWeight.medium){
      return FontWeight.w500;
    }else if(this == TextWeight.semiBold){
      return FontWeight.w600;
    }else if(this == TextWeight.bold){
      return FontWeight.w700;
    }else{
      return FontWeight.w400;
    }
  }
}



class Family {
  static const String light = 'Sen-Light';
  static const String regular = 'Sen-Regular';
  static const String medium = 'Sen-Medium';
  static const String semiBold = 'Sen-SemiBold';
  static const String bold = 'Sen-Bold';
  static const String extraBold = 'Sen-ExtraBold';
  static const String variable = 'Sen-VariableFont_wght';
}



TextStyle _textStyle(num size, color, family) => TextStyle(
    fontSize: size.numToDouble,
    color: color,
    fontFamily: family
);