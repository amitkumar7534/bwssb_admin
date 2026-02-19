import 'dart:developer' as AppUtils;

import 'package:bwssb/components/coreComponents/AppButton.dart';
import 'package:bwssb/components/coreComponents/EditText.dart';
import 'package:bwssb/components/coreComponents/ImageView.dart';
import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/coreComponents/common_password_input_field.dart';
import 'package:bwssb/components/styles/appImages.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/feature/presentation/screens/homeScreen/home_Screen.dart';
import 'package:bwssb/feature/presentation/screens/loginScreen/login_screen.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/app_strings.dart';
import '../../cards/show_pass_dialog.dart';
import '../../controller/auth_ctrl.dart';

class ForgotPassNewOldScreen extends StatefulWidget {
  final String mobile;
  final String hash;

  const ForgotPassNewOldScreen({super.key, required this.mobile, required this.hash});

  @override
  State<ForgotPassNewOldScreen> createState() => _ForgotPassNewOldState();
}



bool isRememberMe = false;
final PassController = TextEditingController();

class _ForgotPassNewOldState extends State<ForgotPassNewOldScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  String? verifiedHash;


  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? true) {
      try {
        final result = await AuthCtrl.find.VerifyOtp(
          "VERIFY_OTP",
          widget.mobile,
          112200,
          widget.hash,
        ).applyLoader;

        AppUtils.log("OTP verification result: $result");

        setState(() {
          verifiedHash = result;
        });

        if (verifiedHash != null) {
          AppUtils.log("OTP verification result hash: $verifiedHash");
        } else {
          AppUtils.log("Hash not found");
        }

      } catch (e, stacktrace) {
        AppUtils.log("Error during OTP verification: $e\n$stacktrace");
      }
    } else {
      AppUtils.log("Form is invalid");
    }
  }




  void changePass() async {
    AppUtils.log("Validating form...");
    final isValid = _formKey.currentState?.validate() ?? false;
    AppUtils.log("Is form valid? $isValid");
    if (isValid) {
      AppUtils.log("changePass called");
      final hash = await AuthCtrl.find.changePassword(
        843,
        "CHANGE_PASSWORD",
        newController.getText,
        widget.mobile,
        verifiedHash ?? '',
      ).applyLoader;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const PasswordChangedDialog();
        },
      );
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context, rootNavigator: true).pop();
      context.pushAndClearNavigator(HomeScreen());
    }
  }




  @override
  void initState() {
    super.initState();
    _submitForm().then((_) {
      AppUtils.log("hash????????$verifiedHash");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        forceMaterialTransparency: false,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        // leading: IconButton(
        //   icon: ImageView(
        //     url: AppImages.backButton,
        //     width: 40,
        //     height: 40,
        //   ),
        //   onPressed: () {
        //     context.pop();
        //   },
        // ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.bottomLeft,
              height: 150,
              width: double.infinity,
              child: Image.asset(
                AppImages.bottomImage,
                alignment: Alignment.bottomLeft,
              ),
            ),
          ),

          Padding(
            padding: 15.horizontal,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageView(
                          url: AppImages.appImage,
                          height: 116,
                          width: 116,
                          margin: 10.top,
                        ),
                      ],
                    ),
                    ImageView(
                      url: AppImages.signuptext,
                      height: 18,
                      width: 133,
                      margin: 20.top,
                    ),
                    TextView(
                      text: AppStrings.forgotPassword,
                      style: 24.txtSBoldBlack,
                      margin: 40.top + 20.bottom,
                    ),
                  EditText(
                    controller: newController,
                    padding: 25.top + 25.bottom + 12.left,
                    label: AppStrings.newPass,
                    labelStyle: 13.txtRegularBlack,
                    hint: AppStrings.enterNewPassword,
                    borderColor: Colors.transparent,
                    margin: 20.bottom,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a new password".toUpperCase();
                      }
                      return null;
                    },
                  ),
                    EditText(
                      controller: confirmController,
                      padding: 25.top + 25.bottom + 12.left,
                      label: AppStrings.confirmPass,
                      labelStyle: 13.txtRegularBlack,
                      hint: AppStrings.enterConfirmPassword,
                      borderColor: Colors.transparent,
                      margin: 20.bottom,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password".toUpperCase();
                        } else if (value != newController.text) {
                          return "Passwords do not match".toUpperCase();
                        }
                        return null;
                      },
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: AppStrings.back,
                            labelStyle: 16.txtBoldBtncolor,
                            buttonColor: AppColors.white,
                            radius: 10.sdp,
                            padding: 18.top + 18.bottom,
                            margin: 20.top + 10.left + 150.bottom,
                            buttonBorderColor: AppColors.btnColor,
                            onTap: () {
                              context.pop();
                            },
                          ),
                        ),
                        Expanded(
                          child: AppButton(
                            label: AppStrings.submit,
                            labelStyle: 16.txtBoldWhite,
                            buttonColor: AppColors.btnColor,
                            radius: 10.sdp,
                            padding: 20.top + 20.bottom + 12.left,
                            margin: 20.top + 10.left + 150.bottom,
                            onTap: () {
                              AppUtils.log("Submit button tapped");
                              changePass();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




