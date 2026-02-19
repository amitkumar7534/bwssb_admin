import 'dart:io';

import '../../data/models/dataModels/ButtonDataModel.dart';
import '../../data/models/dataModels/application_model.dart';
import '../../data/models/dataModels/dashboard_count_model.dart';
import '../../data/models/dataModels/get_all_details_model.dart';
import '../../data/models/dataModels/login_model/login_model.dart';
import '../../data/models/dataModels/responseDataModel.dart';


abstract class AuthRepository {

  Future<ResponseData<LoginModel>> loginUser({
    required String user,
    required String password,
  });

  Future<ResponseData<LoginModel>> verifyUser({
    required String action,
    required String username,
    required String mobile,
  });


  Future<ResponseData<LoginModel>> VerifyOtp({
    required String action,
    required String mobile,
    required String hash,
    required int? otp,

  });


  Future<ResponseData<LoginModel>> changePassword({
    required int userID,
    required String action,
    required String password,
    required String mobile,
    required String hash,

  });


  Future<ResponseData<LoginModel>> profileChangePassword({
    required String existingPassword,
    required String newPassword,

  });



  Future<ResponseData<List<ApplicationModel>>> getApplication();

  Future<ResponseData<GetAllDetailsModel>> getAllDetails ({String? id});

  Future<ResponseData<DashboardCountModel>> getDashBoardCount();

  Future<ResponseData<List<Map<String, dynamic>>>> uploadPhoto({
    required File imageFile,
    String? documentType,
    int? applicationID,
    String ? transactionID,
  });


  Future<ResponseData> deleteImage({String ? deleteImgId });


  Future<ResponseData<DashboardCountModel>> submit({
    required String applicationID,
    required String transactionID,
    required String latitude,
    required String longitude,
    required List<Map<String, dynamic>> documents,
    required String action,
    required Map<String, dynamic> checklist,
  });


  Future<ResponseData<DashboardCountModel>> submitUpdate({
    required String inspectionID,
    required String applicationID,
    required String transactionID,
    required String latitude,
    required String longitude,
    required List<Map<String, dynamic>> documents,
    required String action,
    required Map<String, dynamic> checklist,
  });


  Future<ResponseData<ButtonData>> getButton({
    String? applicationID,
    String? transactionID,
  });
}