import 'package:bwssb/components/coreComponents/ImageView.dart';
import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/styles/appColors.dart';
import 'package:bwssb/components/styles/appImages.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controller/Get_application_ctrl.dart';
import '../profileScreen/profile_Screen.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
  final ctrl = Get.put(GetApplicationCtrl());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double boxHeight = size.height * 0.18;
    final double boxWidth = size.width * 0.4;
    ctrl.fetchDashboardCount();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ImageView(
                    url: AppImages.menuIcon,
                    height: 40,
                    width: 40,
                    onTap: () {
                      context.pushNavigator(ProfileScreen());
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageView(
                        url: AppImages.homeScreenAppBar,
                        height: 40,
                        width: 180,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Obx(() {
              final dashboard = ctrl.dashboardCountModel.value;
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 40,
                childAspectRatio: boxWidth / boxHeight,
                children: [
                  _buildDashboardCard(
                    imagePath: AppImages.totalImage,
                    title: "Total",
                    count: "${dashboard?.totalApplication ?? 0}",
                    countColor: Colors.blue,
                    boxHeight: boxHeight,
                    boxWidth: boxWidth,
                  ),
                  _buildDashboardCard(
                    imagePath: AppImages.pendingImage,
                    title: "Pending",
                    count: "${dashboard?.totalApplicationPending ?? 0}",
                    countColor: Colors.amber,
                    boxHeight: boxHeight,
                    boxWidth: boxWidth,
                  ),
                  _buildDashboardCard(
                    imagePath: AppImages.forwardImage,
                    title: "Rejected",
                    count: "${dashboard?.totalApplicationRejected ?? 0}",
                    countColor: Colors.red,
                    boxHeight: boxHeight,
                    boxWidth: boxWidth,
                  ),
                  _buildDashboardCard(
                    imagePath: AppImages.ApprovedImage,
                    title: "Approved",
                    count: "${dashboard?.totalApplicationApproved ?? 0}",
                    countColor: Colors.green,
                    boxHeight: boxHeight,
                    boxWidth: boxWidth,
                  ),
                ],
              );
            });

          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String imagePath,
    required String title,
    required String count,
    required Color countColor,
    required double boxHeight,
    required double boxWidth,
  }) {
    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: boxHeight * 0.30,
            child: Container(
              width: boxWidth,
              height: boxHeight * 0.80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: boxHeight * 0.35, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: boxHeight * 0.12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: boxHeight * 0.11,
                        fontWeight: FontWeight.bold,
                        color: countColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: (boxWidth - (boxWidth * 0.8)) / 2,
            child: Container(
              height: boxHeight * 0.60,
              width: boxWidth * 0.8,
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(10),
              child: Center(
                child: ImageView(
                  url: imagePath,
                  height: boxHeight * 0.40,
                  width: boxHeight * 0.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
