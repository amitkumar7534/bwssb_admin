import 'package:bwssb/components/coreComponents/AppButton.dart';
import 'package:bwssb/components/coreComponents/EditText.dart';
import 'package:bwssb/components/coreComponents/ImageView.dart';
import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/coreComponents/common_password_input_field.dart';
import 'package:bwssb/components/styles/appImages.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/appUtils.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../components/coreComponents/custom_check_box.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../components/styles/ui_theme.dart';
import '../../controller/auth_ctrl.dart';
import '../homeScreen/home_Screen.dart';
import 'forgot_pass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

bool isRememberMe = false;

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isButtonEnabled = false;
  bool isRememberMeError = false;

  bool get _isFormValid =>
      userController.getText.isNotEmpty &&
          passwordController.getText.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
    userController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      final username = userController.text.trim();
      final password = passwordController.text;
      isButtonEnabled = username.length >= 3 && password.length >= 8;
    });
  }

  Future<void> _loadRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      String username = prefs.getString('username') ?? '';
      String password = prefs.getString('password') ?? '';

      setState(() {
        isRememberMe = true;
        userController.text = username;
        passwordController.text = password;
      });
    }
  }

  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isRememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('username', userController.getText);
      await prefs.setString('password', passwordController.getText);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  void _submitForm() async {
    setState(() {
      isRememberMeError = !isRememberMe;
      _isFormValid;
    });

    if (_formKey.currentState != null &&
        _formKey.currentState!.validate() &&
        isRememberMe) {
      try {
        AppUtils.log("Login attempt...");
        await _saveCredentials();
        await AuthCtrl.find.login(
          userController.getText,
          passwordController.getText,
        ).applyLoader.then((value) {
          context.pushAndClearNavigator( HomeScreen());
        });
      } catch (e) {
        AppUtils.log("Error: $e");
      }
    } else {
      AppUtils.log("Form or checkbox validation failed");
    }
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
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
            Padding(
              padding: 15.horizontal,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 130,
                ),
                reverse: true,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageView(
                            url: AppImages.appImage,
                            height: 116,
                            width: 116,
                            margin: 100.top,
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
                        text: "Namaskara!",
                        style: 24.txtSBoldBlack,
                        margin: 30.top + 10.bottom,
                      ),
                      EditText(
                        controller: userController,
                        padding: 25.top + 25.bottom + 12.left,
                        label: AppStrings.userId,
                        labelStyle: 13.txtRegularBlack,
                        hint: AppStrings.enterUserId,
                        borderColor: Colors.transparent,
                        margin: 20.bottom,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your User Name'.toUpperCase();
                          } else if (value.trim().isEmpty) {
                            return 'Spaces are not allowed'.toUpperCase();
                          }
                          return null;
                        },
                      ),
                      CommonPasswordInputField(
                        padding: 25.top + 25.bottom + 12.left,
                        hint: AppStrings.enterPass,
                        label: AppStrings.password,
                        labelStyle: 13.txtRegularBlack,
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password'.toUpperCase();
                          } else if (value.trim().isEmpty) {
                            return 'Spaces are not allowed'.toUpperCase();
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isRememberMe = !isRememberMe;
                                    isRememberMeError = false;
                                  });
                                },
                                child: Padding(
                                  padding: 5.top + 5.bottom,
                                  child: Row(
                                    children: [
                                      CustomCheckbox(
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isRememberMe = value ?? false;
                                            isRememberMeError = false;
                                          });
                                        },
                                        value: isRememberMe,
                                      ),
                                      10.width,
                                      TextView(
                                        text: AppStrings.rememberMe,
                                        style: 13.txtRegularGrey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isRememberMeError)
                                Padding(
                                  padding: 8.left,
                                  child: TextView(
                                    text: "Please check this box to continue.",
                                    style: 12.txtRegularError,
                                  ),
                                ),
                            ],
                          ),
                          TextView(
                            text: AppStrings.forgotPassword,
                            style: 14.txtRegularError,
                            onTap: () {
                             // FirebaseCrashlytics.instance.crash();

                              context.pushNavigator(const ForgotPassScreen());
                            },
                          ),
                        ],
                      ),
                      AppButton(
                        label: AppStrings.logIn,
                        labelStyle: 16.txtBoldWhite,
                        buttonColor: isButtonEnabled
                            ? AppColors.btnColor
                            : AppColors.btnColor.withOpacity(0.5),
                        radius: 10.sdp,
                        padding: 20.top + 20.bottom + 12.left,
                        margin: 20.top,
                        onTap: isButtonEnabled ? _submitForm : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
