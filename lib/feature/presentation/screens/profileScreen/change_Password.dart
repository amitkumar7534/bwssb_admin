import 'dart:developer' as AppUtils;

import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/styles/appColors.dart';
import 'package:bwssb/components/styles/app_strings.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/EditText.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/common_password_input_field.dart';
import '../../../../components/styles/appImages.dart';
import '../../cards/show_pass_dialog.dart';
import '../../controller/auth_ctrl.dart';
import '../homeScreen/home_Screen.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();



  @override
  Widget build(BuildContext context) {


    void changePass() async {
      AppUtils.log("Validating form...");
      final isValid = _formKey.currentState?.validate() ?? false;
      AppUtils.log("Is form valid? $isValid");

      if (isValid) {
        AppUtils.log("changePass called");
        final hash = await AuthCtrl.find.profileChangePassword(
            currentPassController.getText,
            newPassController.getText
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ImageView(
                    url: AppImages.backButton,
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ImageView(
                url: AppImages.homeScreenAppBar,
                height: 40,
                width: 180,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: 20.horizontal,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: AppStrings.changePassword,
                          style: 20.txtBoldBlack,
                          margin: 20.top + 25.bottom,
                        ),
                        EditText(
                          controller: currentPassController,
                          padding: 25.top + 25.bottom + 12.left,
                          label: AppStrings.currentPassword,
                          labelStyle: 13.txtRegularBlack,
                          hint: AppStrings.EnterCurrentPassword,
                          borderColor: Colors.transparent,
                          margin: 20.bottom,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a Current password";
                            }
                            return null;
                          },
                        ),
                        CommonPasswordInputField(
                          marginBottom: 20,
                          padding: 25.top + 25.bottom + 12.left,
                          hint: AppStrings.EnterNewPassword,
                          label: AppStrings.newPassword,
                          labelStyle: 13.txtRegularBlack,
                          controller: newPassController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a new password";
                            }
                            return null;
                          },

                        ),
                        CommonPasswordInputField(
                          padding: 25.top + 25.bottom + 12.left,
                          hint: AppStrings.enterConfirmPassword,
                          label: AppStrings.confirmPass,
                          labelStyle: 13.txtRegularBlack,
                          controller: confirmPassController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            } else if (value != newPassController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppStrings.back,
                      labelStyle: 16.txtBoldBtncolor,
                      buttonColor: AppColors.white,
                      radius: 10.sdp,
                      padding: 13.top + 13.bottom,
                      margin: 20.top + 10.right,
                      buttonBorderColor: AppColors.btnColor,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      label: AppStrings.submit,
                      labelStyle: 16.txtBoldWhite,
                      buttonColor: AppColors.btnColor,
                      radius: 10.sdp,
                      padding: 15.top + 15.bottom + 12.left,
                      margin: 20.top + 10.left,
                      onTap: () { changePass();
                        },
                    ),
                  ),
                ],
              ),
              30.height,
            ],
          ),
        ),
      ),
    );
  }
}
