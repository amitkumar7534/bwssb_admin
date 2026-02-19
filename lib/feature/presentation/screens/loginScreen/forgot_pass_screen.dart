import 'dart:developer' as AppUtils;
import 'package:bwssb/components/coreComponents/AppButton.dart';
import 'package:bwssb/components/coreComponents/EditText.dart';
import 'package:bwssb/components/coreComponents/ImageView.dart';
import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/coreComponents/appBar2.dart';
import 'package:bwssb/components/styles/appImages.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:flutter/material.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../components/styles/ui_theme.dart';
import '../../controller/auth_ctrl.dart';
import 'forgot_pass_new_old_screen.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}



class _ForgotPassScreenState extends State<ForgotPassScreen> {



  final TextEditingController userController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _isFormValid =>
      userController.getText.isNotNullEmpty &&
          mobileController.getText.isNotNullEmpty ;

  bool isButtonEnabled = false;
  bool isRememberMeError = false;
  void _validateForm() {
    setState(() {
      final username = userController.text.trim();
      final mobile = mobileController.text;
      isButtonEnabled = username.length >= 3 && mobile.length >= 10;
    });
  }


  @override
  void initState() {
    super.initState();
    userController.addListener(_validateForm);
    mobileController.addListener(_validateForm);
  }

  void _submitForm() async {
    setState(() {
      isRememberMeError = !isRememberMe;
      _isFormValid;
    });

    if (_formKey.currentState?.validate() ?? false) {
      AppUtils.log("Login attempt...");
      try {
        final hash = await AuthCtrl.find.verifyUser(
          userController.getText,
          "VERIFY_USER",
          mobileController.getText,
        );
        AppUtils.log("Hash from verifyUser: $hash");

        if (hash != null) {
          context.pushNavigator(ForgotPassNewOldScreen(
            mobile: mobileController.getText,
            hash: hash,
          ));
        } else {
          AppUtils.log("Hash is null, cannot proceed.");
        }
      } catch (error) {
        AppUtils.log("Error during verification: $error");
      }
    } else {
      AppUtils.log("Form is invalid");
    }
  }



  @override
  void dispose() {
    userController.dispose();
    mobileController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context).extension<UiTheme>()!;
    return Scaffold(
      backgroundColor: uiTheme.backGroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                width: double.infinity,
                alignment: Alignment.bottomLeft,
                child: Image.asset(
                  AppImages.bottomImage,
                  alignment: Alignment.bottomLeft,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 130,
              ),
              reverse: true,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar2(
                      leadIcon: IconButton(
                        icon: ImageView(
                          url: AppImages.backButton,
                          width: 40,
                          height: 40,
                        ),
                        onPressed: () {
                         context.pop();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageView(
                          url: AppImages.appImage,
                          height: 116,
                          width: 116,
                          margin: 40.top,
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
                      text: "Forgot Password",
                      style: 24.txtSBoldBlack,
                      margin: 30.top + 10.bottom,
                    ),

                    EditText(
                      padding: 25.top + 25.bottom + 12.left,
                      label: AppStrings.userId,
                      labelStyle: 13.txtRegularBlack,
                      hint: AppStrings.enterUserId,
                      borderColor: Colors.transparent,
                      margin: 20.bottom + 15.left + 15.right,
                      controller: userController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your User Name'.toUpperCase();
                        } else if (value.trim().isEmpty) {
                          return 'Spaces are not allowed'.toUpperCase();
                        }
                        return null;
                      },
                    ),
                    EditText(
                      padding: 25.top + 25.bottom + 12.left,
                      label: AppStrings.mobileNumber,
                      labelStyle: 13.txtRegularBlack,
                      hint: AppStrings.enterMobileNumber,
                      borderColor: Colors.transparent,
                      inputType: TextInputType.number,
                      maxLength: 10,
                      margin: 20.bottom + 15.left + 15.right,
                      controller: mobileController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Mobile Number'.toUpperCase();
                        }
                        return null;
                      },
                    ),

                    AppButton(
                      label: AppStrings.verify,
                      labelStyle: 16.txtBoldWhite,
                      buttonColor: isButtonEnabled
                          ? AppColors.btnColor
                          : AppColors.btnColor.withOpacity(0.5),
                      radius: 10.sdp,
                      padding: 20.top + 20.bottom + 12.left,
                      margin: 20.bottom + 15.left + 15.right,
                      onTap: isButtonEnabled ? _submitForm : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
