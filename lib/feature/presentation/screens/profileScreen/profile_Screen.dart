import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/styles/appColors.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/feature/presentation/screens/profileScreen/change_Password.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../services/storage/preferences.dart';
import '../../cards/common_confirmation_dialog.dart';
import '../applicationScreen/application_screen.dart';
import '../loginScreen/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ImageView(url: AppImages.menuIcon,height: 40,width: 40,onTap: (){
                    // context.pushNavigator(ProfileScreen());
                  },),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageView(url: AppImages.homeScreenAppBar,height: 40,width: 180,)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageView(
                    url: AppImages.ProfilePersionImage,
                    radius: screenWidth * 0.12,
                    height: 110,
                    width: 110,
                  ),
                  SizedBox(width: screenWidth * 0.08),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: Preferences.profile?.name ?? '',
                          style: 18.txtBoldBlack,
                          maxlines: 5,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextView(
                          text: Preferences.profile?.role ?? '',
                          style: 14.txtRegularGrey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBaground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      onTap: () {context.pushNavigator(ChangePassword());},
                      imagePath: AppImages.PasswordImg,
                      text: 'Change Password',
                      screenWidth: screenWidth,
                    ),
                    _buildMenuItem(
                      imagePath: AppImages.dashBoardImage,
                      text: 'Dashboard',
                      screenWidth: screenWidth,
                      onTap: (){context.pop();}
                    ),
                    _buildMenuItem(
                      imageColor: Colors.blue,
                      imagePath:  AppImages.totalImage,
                      text: 'Application',
                      screenWidth: screenWidth,
                      onTap: (){
                        context.pushNavigator(ApplicationScreen());
                      }
                    ),
                    _buildMenuItem(
                       imageColor: AppColors.red,
                        imagePath: AppImages.exitImgLogout,
                        text: 'Log out',
                        screenWidth: screenWidth,
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) => CommonConfirmationDialog(
                              btnColor: AppColors.btnColor,
                              iconColor: AppColors.red,
                              imagePath: AppImages.exitImgLogout,
                              title: "Log Out",
                              subtitle: "Are you sure you want to log out?",
                              onYes: () async {
                                await Preferences.clearAll().applyLoader;
                                context.pushAndClearNavigator(const LoginScreen());
                              },
                              onNo: () {
                               context.pop();
                              },
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String imagePath,
     VoidCallback? onTap ,
     Color? imageColor,
    required String text,
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child:  ImageView(
                url: imagePath,
                height: 20,
                width: 20,
                tintColor: imageColor,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: TextView(
                text: text,
                style: 16.txtRegularBlack
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
