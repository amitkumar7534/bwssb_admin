import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../services/storage/preferences.dart';
import '../../../utils/appUtils.dart';
import '../../data/models/dataModels/dashboard_count_model.dart';
import '../../data/models/dataModels/get_all_details_model.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../../data/models/repository/iAuthRepository.dart';
import '../../domain/repository/authRepository.dart';
import '../screens/loginScreen/login_screen.dart';


class GetApplicationCtrl extends GetxController {
  final AuthRepository _repo = IAuthRepository();

  Rxn<GetAllDetailsModel> getAllDetailsModel = Rxn<GetAllDetailsModel>();
  RxBool isLoading = false.obs;
  Rxn<DashboardCountModel> dashboardCountModel = Rxn<DashboardCountModel>();
  RxBool isDashboardLoading = false.obs;

  Future<void> fetchAllDetails(String ? id) async {
    try {
      isLoading.value = true;

      final ResponseData<GetAllDetailsModel> response =
      await _repo.getAllDetails(id: id);

      if (response.isSuccess && response.data != null) {
        getAllDetailsModel.value = response.data!;
        AppUtils.log("Fetched All Details Successfully");
        AppUtils.log("Consumer Name: ${response.data?.connectionDetails?.consumerDetails?.name}");
        AppUtils.log("Total Payable: ${response.data?.totalPayable}");
      } else {
        AppUtils.toastError("Failed to fetch application details");
      }
    } catch (e) {
      AppUtils.toastError("Something went wrong: $e");
      AppUtils.log("Error fetching details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _handleSessionExpired() async {
    AppUtils.toastError("Session expired, please log in again");
    await Preferences.clearAll();

    Get.offAll(() => LoginScreen());

  }



  Future<void> fetchDashboardCount() async {
    try {
      isDashboardLoading.value = true;

      final ResponseData<DashboardCountModel> response =
      await _repo.getDashBoardCount();



      if (response.isSuccess && response.data != null) {
        dashboardCountModel.value = response.data!;
        AppUtils.log("Dashboard Count Fetched Successfully");
        AppUtils.log("Total Applications: ${response.data?.totalApplication}");
      } else {
        _handleSessionExpired();
      }
    } catch (e) {
      AppUtils.toastError("Something went wrong: $e");
      AppUtils.log("Error fetching dashboard count: $e");
    } finally {
      isDashboardLoading.value = false;
    }
  }

}
