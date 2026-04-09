import 'dart:io';

import '../../data/models/dataModels/ButtonDataModel.dart';
import '../../data/models/dataModels/application_model.dart';
import '../../data/models/dataModels/dashboard_count_model.dart';
import '../../data/models/dataModels/get_all_details_model.dart';
import '../../data/models/dataModels/login_model/login_model.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../../presentation/screens/applicationScreen/application_form_screen.dart';

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

  Future<ResponseData<GetAllDetailsModel>> getAllDetails({String? id});

  Future<ResponseData<DashboardCountModel>> getDashBoardCount();

  // Keep original deleteImage so nothing else breaks.
  Future<ResponseData> deleteImage({String? deleteImgId});

  /// Delete an existing uploaded document by fileID.
  /// DELETE {{URL}}/api/mobile/v2/file/{fileID}?applicationID=...&documentType=...
  Future<ResponseData> deleteExistingDocument({
    required String fileID,
    required String applicationID,
    required String documentType,
  });

  Future<ResponseData<LocationSaveData>> saveLocation({
    required String ui,
    required String section,
    required String applicationID,
    required String transactionID,
    required String latitude,
    required String longitude,
    required bool isUpdate,
    String? inspectionID,
  });

  Future<ResponseData<DashboardCountModel>> submitWithFiles({
    String? inspectionID,
    required String applicationID,
    required String transactionID,
    required String ui,
    required String latitude,
    required String longitude,
    required String checklist,
    String? documentMetadata,
    required List<File> files,
    String? remarks
  });

  Future<ResponseData<ButtonData>> getButton({
    String? applicationID,
    String? transactionID,
  });
}