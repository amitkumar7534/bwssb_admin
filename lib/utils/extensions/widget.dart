
import 'package:bwssb/utils/extensions/size.dart';
import 'package:flutter/cupertino.dart';
extension OnNumWidget on num{
  SizedBox get height => SizedBox(height: getDouble.sdp,);
  SizedBox get width => SizedBox(width: getDouble.sdp,);
}