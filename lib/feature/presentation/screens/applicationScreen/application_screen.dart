import 'package:bwssb/components/appLoader.dart';
import 'package:bwssb/components/coreComponents/EditText.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/appUtils.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../data/models/dataModels/application_model.dart';
import '../../../data/models/dataModels/responseDataModel.dart';
import '../../cards/ApplicationCard.dart';
import '../../controller/Get_application_ctrl.dart';
import '../../controller/auth_ctrl.dart';
import 'application_form_screen.dart';
import 'package:intl/intl.dart';


class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  List<ApplicationModel> applications = [];
  List<ApplicationModel> filteredApplications = [];
  bool isLoading = true;
  String? errorMessage;
  final getApplicationCtrl = Get.put(GetApplicationCtrl());

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> getAllApplications(String? applicationId) async {
    AppUtils.log("Fetching details for applicationId: $applicationId");
    await getApplicationCtrl.fetchAllDetails(applicationId);

    final details = getApplicationCtrl.getAllDetailsModel.value;
    if (details != null) {
      AppUtils.log("Consumer Name: ${details.connectionDetails?.consumerDetails?.name}");
      AppUtils.log("Total Payable: ${details.totalPayable}");
    } else {
      AppUtils.log("No data found in getAllDetailsModel.");
    }
  }

  Future<void> fetchApplications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      ResponseData<List<ApplicationModel>> response = await AuthCtrl.find.getApplication();

      if (response.isSuccess && response.data != null) {
        setState(() {
          applications = response.data!;
          filteredApplications = applications;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message ?? response.getError?.toString() ?? 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredApplications = applications;
      } else {
        final lowerQuery = query.toLowerCase();
        filteredApplications = applications.where((app) {
          final appCode = app.applicationCode?.toString() ?? '';
          final appName = app.applicantName?.toLowerCase() ?? '';
          return appCode.contains(lowerQuery) || appName.contains(lowerQuery);
        }).toList();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: 10.top,
                  child: ImageView(
                    url: AppImages.backButton,
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
            ),
            Padding(
              padding: 10.top,
              child: ImageView(
                url: AppImages.homeScreenAppBar,
                height: 40,
                width: 180,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          20.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child:
            TextField(
              controller: searchController,
              // keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintStyle: 16.txtRegularBlack,
                hintText: "Search Application",
                prefixIcon: Icon(Icons.search),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: AppColors.btnColor),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onChanged: filterSearch,
            ),

          ),

          Row(
            children: [
              TextView(
                text: AppStrings.Application,
                style: 20.txtBoldBlack,
                margin: 10.bottom + 20.left,
              ),
            ],
          ),

          Expanded(
            child: isLoading
                ? Center(child: AppLoader.loaderWidget())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : filteredApplications.isEmpty
                ? Center(
              child: TextView(
                text: "No Application Found",
                style: 20.txtBoldBlack,
                margin: 40.bottom,
              ),
            )
                : ListView.builder(
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) {
                final app = filteredApplications[index];
                return ApplicationCard(
                  SubmittedDate: app.submissionDate,
                  applicantName: app.applicantName ?? 'No Name',
                  applicantId: app.applicationCode.toString(),
                  processMapped: app.processDescription ?? 'N/A',
                  appliedBy: app.appliedBy,
                  dueDate: app.dueDate,
                  onViewTap: () async {
                    AppLoader.showLoader(context);
                    try {
                      final selectedApplication = filteredApplications[index];
                      final applicationId =
                      selectedApplication.applicationId?.toString();

                      if (applicationId == null) {
                        AppLoader.hideLoader(context);
                        AppUtils.toast("Invalid application ID.");
                        return;
                      }

                      await getAllApplications(applicationId);
                      final details =
                          getApplicationCtrl.getAllDetailsModel.value;

                      AppLoader.hideLoader(context);

                      if (details == null) {
                        AppUtils.toast("No details found for this application.");
                        return;
                      }

                      context.pushNavigator(
                        ApplicationFormScreen(
                          application: selectedApplication,
                          details: details,
                        ),
                      );
                    } catch (e) {
                      AppLoader.hideLoader(context);
                      AppUtils.toast(
                          "Failed to load application details: $e");
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

