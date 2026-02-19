import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/storage/preferences.dart';
import '../../../utils/appUtils.dart';
import '../../data/models/dataModels/application_model.dart';
import '../../data/models/dataModels/get_all_details_model.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../../data/models/repository/iAuthRepository.dart';
import '../../domain/repository/authRepository.dart';


class AuthCtrl extends GetxController{
  static AuthCtrl get find  => Get.put(AuthCtrl(), permanent: true);
  final AuthRepository _repo = IAuthRepository();

  var searchedUsers = <Map<String, dynamic>>[].obs;


  RxBool isLoading = false.obs;

  Future login(String username, String password) async {
    final response = await _repo.loginUser(
      user: username,
      password: password,
    );

    if (response.isSuccess) {
      final data = response.data;
      AppUtils.log("Login successful: $data");
      Preferences.savePrefOnLogin = data;
      return;

    } else {
      final error = response.getError;
      AppUtils.toastError(error);
      // Get.snackbar("","${error}",
      // backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,
      //   snackStyle:SnackStyle.FLOATING
      // );
      AppUtils.log("error>>>>$error");
      throw '';
    }
  }

  Future<String?> verifyUser(String username, String action, String mobile) async {
    final response = await _repo.verifyUser(
      action: action,
      username: username,
      mobile: mobile,
    );

    if (response.isSuccess) {
      final data = response.data;
      AppUtils.log("Verify successful: $data");
      final hash = data?.hash;
      AppUtils.log("Hash: $hash");

      return hash;
    } else {
      final error = response.getError;
      AppUtils.toastError(error);
      if (error != null) {
        AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw Exception('Verification failed');
    }
  }

  Future<String?> VerifyOtp(String action, String mobile, int otp, String hash) async {
    final response = await _repo.VerifyOtp(
      action: action,
      mobile: mobile,
      hash: hash,
      otp: otp,
    );

    if (response.isSuccess) {
      final data = response.data;
      AppUtils.log("Otp send:  $data");

      final responseHash = data?.hash;

      if (responseHash != null) {
        AppUtils.log("Hash::::::::: $responseHash");
      } else {
        AppUtils.log("Hash not found in response");
      }

      return responseHash;
    } else {
      final error = response.getError;
      if (error != null) {
        AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw '';
    }
  }






  Future<String> changePassword(int userId, String type, String newPassword, String mobile, String hash) async {
    final response = await _repo.changePassword(
      action: type,
      userID: userId,
      password: newPassword,
      mobile: mobile,
      hash: hash,
    );

    if (response.isSuccess) {
      final data = response.data;
      AppUtils.log("password successful: $data");
      final hash = data?.hash;
      AppUtils.log("Hash: $hash");
      return hash ?? '';
    } else {
      final error = response.getError;
      AppUtils.toastError(error);
      if (error != null) {
        AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw Exception('Verification failed');
    }
  }




  Future<String> profileChangePassword(String existingPassword, String newPassword) async {
    final response = await _repo.profileChangePassword(
      existingPassword: existingPassword,
      newPassword: newPassword
    );

    if (response.isSuccess) {
      final data = response.data;
      final hash = data?.hash;
      return hash ?? '';
    } else {
      final error = response.getError;
      AppUtils.toastError(error);
      AppUtils.log("Password change failed: $error");
      if (error != null) {
        AppUtils.toastError(error is Exception ? error : Exception(error.toString()));
      } else {
        AppUtils.toastError(Exception('Unknown error'));
      }
      throw Exception(error?.toString() ?? 'Verification failed');
    }

  }



  Future<ResponseData<List<ApplicationModel>>> getApplication() async {
    final response = await _repo.getApplication();

    if (response.isSuccess) {


      AppUtils.log("get Application successful: ${jsonEncode(response.data?.map((e) => e.toJson()).toList())}");

      return response;
    } else {
      final error = response.getError;
      AppUtils.toastError(error);
      if (error != null) {
        AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw Exception('Verification failed');
    }
  }

  Future<void> fetchAllDetails() async {
    try {
      final response = await _repo.getAllDetails();

      if (response.isSuccess && response.data != null) {
        final GetAllDetailsModel details = response.data!;
        AppUtils.log("Fetched All Details Successfully");

        AppUtils.log("Consumer Name: ${details.connectionDetails?.consumerDetails?.name}");
        AppUtils.log("Total Payable: ${details.totalPayable}");

      } else {
        AppUtils.toastError("Failed to fetch details");
      }
    } catch (e) {
      AppUtils.toastError("Something went wrong: $e");
      AppUtils.log("Error fetching all details: $e");
    }
  }


}




