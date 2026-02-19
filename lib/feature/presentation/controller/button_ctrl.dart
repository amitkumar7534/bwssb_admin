import 'package:get/get.dart';
import '../../../utils/appUtils.dart';

import '../../data/models/dataModels/ButtonDataModel.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../../data/models/repository/iAuthRepository.dart';
import '../../domain/repository/authRepository.dart';

class ButtonCtrl extends GetxController {
  final AuthRepository _repo = IAuthRepository();

  Rxn<ButtonData> buttonData = Rxn<ButtonData>();
  RxBool isLoading = false.obs;

  Future<void> fetchButton({String? applicationID, String? transactionID}) async {
    try {
      isLoading.value = true;

      final ResponseData<ButtonData> response = await _repo.getButton(
        applicationID: applicationID,
        transactionID: transactionID,
      );

      if (response.isSuccess && response.data != null) {
        buttonData.value = response.data;
        AppUtils.log("Button Data fetched successfully");
        AppUtils.log("Action: ${response.data?.ui}");
        AppUtils.log("Button Label: ${response.data?.button}");
      } else {
        buttonData.value = null;
        AppUtils.toastError(response.getError ?? "Failed to fetch button data");
      }
    } catch (e) {
      buttonData.value = null;
      AppUtils.toastError("Something went wrong: $e");
      AppUtils.log("Error fetching button data: $e");
    } finally {
      isLoading.value = false;
    }
  }


}
