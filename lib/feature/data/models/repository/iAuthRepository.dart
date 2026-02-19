// import 'dart:developer' as AppUtils;

import 'dart:convert';
import 'dart:io';

import 'package:bwssb/utils/appUtils.dart';
import 'package:bwssb/utils/extensions/extensions.dart';

import '../../../../services/networking/apiMethods.dart';
import '../../../../services/networking/urls.dart';
import '../../../../services/storage/preferences.dart';
import '../../../domain/repository/authRepository.dart';
import '../dataModels/ButtonDataModel.dart';
import '../dataModels/application_model.dart';
import '../dataModels/dashboard_count_model.dart';
import '../dataModels/get_all_details_model.dart';
import '../dataModels/login_model/login_model.dart';
import '../dataModels/responseDataModel.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


class IAuthRepository implements AuthRepository {
  final IApiMethod _apiMethod = IApiMethod(baseUrl: Urls.api);


  @override
  Future<ResponseData<LoginModel>> loginUser({
    required String user,
    required String password,
  }) async {
    final body = {
      'username': user,
      'password': password,
    };

    AppUtils.log("Login API URL: ${Urls.login}");
    final result = await _apiMethod.post(
      url: Urls.login,
      body: body,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = rawData['data']?['user'] ?? {};
      final token = rawData['data']?['token'] ?? "";
      final userid = rawData['data']?['user']['user_id'].toString() ?? "";
      AppUtils.log("Token: $token");
      AppUtils.log("Parsed user data: $userData");

      final data = LoginModel.fromJson(userData);
      Preferences.authToken = token;
      Preferences.profile = data;
      Preferences.uid = userid;
      AppUtils.log("Saved user id : $userid");
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }



  @override
  Future<ResponseData<LoginModel>> verifyUser({
    required String action,
    required String username,
    required String mobile,
  }) async {
    final body = {
      'action': action,
      'username': username,
      'mobile': mobile,
    };

    final result = await _apiMethod.post(
      url: Urls.verifyUser,
      body: body,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = rawData['data']?['user'] ?? {};
      final hash = rawData['data']?['hash'];
      AppUtils.log("verification data : $userData");
      AppUtils.log("hash>>>>>: $hash");

      final data = LoginModel.fromJson(userData).copyWith(hash: hash);

      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }


  @override
  Future<ResponseData<LoginModel>> VerifyOtp({
    required String action,
    required String mobile,
    required String hash,
    required int ?otp,

  }) async {
    final body = {
      'action': action,
      'mobile': mobile,
      'hash': hash,
      'otp': 112200,
    };

    final result = await _apiMethod.post(
      url: Urls.verifyOtp,
      body: body,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "10.0",
      },
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = rawData['data'] ?? {};
      AppUtils.log("data::::$userData");
      final data = LoginModel.fromJson(userData);
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }



  @override
  Future<ResponseData<LoginModel>> changePassword({
    required String action,
    required int userID,
    required String password,
    required String mobile,
    required String hash,


  }) async {
    final body = {
      'action': action,
      'userID': userID,
      'password': password,
      'mobile': mobile,
      'hash': hash,
    };

    final result = await _apiMethod.post(
      url: Urls.changePassword,
      body: body,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "10.0",
      },
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = (rawData['data'] is Map)
          ? (rawData['data'] as Map)['user'] ?? {}
          : {};

      final data = LoginModel.fromJson(Map<String, dynamic>.from(userData));
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }


  @override
  Future<ResponseData<LoginModel>> profileChangePassword({
    required String existingPassword,
    required String newPassword,

  }) async {
    final body = {
      'existingPassword': existingPassword,
      'newPassword': newPassword,
    };

    final result = await _apiMethod.patch(
      url: Urls.profileChangePassword,
      body: body,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
        "Content-Type":" application/json",
      },
      authToken: Preferences.authToken.bearer
    );
    AppUtils.log("body:::$body");
    AppUtils.log("API Result::::: ${result.toJson()}");

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = (rawData['data'] is Map)
          ? (rawData['data'] as Map)['user'] ?? {}
          : {};

      final data = LoginModel.fromJson(Map<String, dynamic>.from(userData));
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }




  Future<ResponseData<List<ApplicationModel>>> getApplication() async {
    final token = Preferences.authToken;
    // final id = Preferences.uid ?? "";
    final id = "17";
    final result = await _apiMethod.get(

    url: "${Urls.getApplication}/$id",
    body: {},
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
      authToken: token,
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final List<dynamic> appList = rawData['data'] ?? [];



      final List<ApplicationModel> applications = appList
          .map((json) => ApplicationModel.fromJson(json))
          .toList();

      AppUtils.log("datata>>>${applications}");

      return ResponseData(isSuccess: true, data: applications);

    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }

  Future<ResponseData<GetAllDetailsModel>> getAllDetails({String ? id}) async {
    final token = Preferences.authToken;
    AppUtils.log("token>>${token}");
    final actualId = id ?? "";
    try {
      final result = await _apiMethod.get(
        url: "${Urls.getAllDetails}/$actualId",
        body: {},
        headers: {
          "x-app-platform": "android",
          "x-app-version": "1.0",
        },
        authToken: token,
      );

      if (result.isSuccess) {
        final rawData = result.data;
        AppUtils.log(" API Raw Response:\n${rawData.toString()}");
        try {
          final dataJson = rawData?['data'];
          if (dataJson == null) {
            AppUtils.log(" No 'data' key found in response.");
            return ResponseData(
              isSuccess: false,
              error: Exception("No 'data' found in API response"),
            );
          }

          final GetAllDetailsModel details = GetAllDetailsModel.fromJson(dataJson);
          return ResponseData(isSuccess: true, data: details);

        } catch (e, stackTrace) {
          AppUtils.log(" Parsing Error: $e\nStack Trace:\n$stackTrace");
          return ResponseData(
            isSuccess: false,
            error: Exception("Parsing error: $e"),
          );
        }

      } else {
        AppUtils.log(" API Error: ${result.getError}");
        return ResponseData(
          isSuccess: false,
          error: result.getError,
        );
      }

    } catch (e, stackTrace) {
      AppUtils.log(" Unexpected Error in getAllDetails: $e\nStack Trace:\n$stackTrace");
      return ResponseData(
        isSuccess: false,
        error: Exception("Unexpected error: $e"),
      );
    }
  }


  Future<ResponseData<DashboardCountModel>> getDashBoardCount() async {
    final token = Preferences.authToken;
    final result = await _apiMethod.get(
      url: Urls.dashBoardCount,
      body: {},
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
      authToken: token,
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final dataJson = rawData['data'] ?? {};

      final dashboardData = DashboardCountModel.fromJson(dataJson);
      AppUtils.log("Dashboard Data >>> $dashboardData");

      return ResponseData(isSuccess: true, data: dashboardData);
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }


  @override
  Future<ResponseData<List<Map<String, dynamic>>>> uploadPhoto({
    required File imageFile,
    String? documentType,
    int? applicationID,
    String ? transactionID,
  }) async {
    final token = Preferences.authToken ?? "";

    final originalPath = imageFile.path;
    final extension = originalPath.split('.').last;
    final uppercaseExtension = extension.toUpperCase();
    final renamedPath = originalPath.replaceFirst(RegExp(r'\.[^.]+$'), '.$uppercaseExtension');
    final renamedFile = await imageFile.copy(renamedPath);

    String mimeType = 'application/octet-stream';
    if (['JPG', 'JPEG'].contains(uppercaseExtension)) {
      mimeType = 'image/jpeg';
    } else if (uppercaseExtension == 'PNG') {
      mimeType = 'image/png';
    } else if (uppercaseExtension == 'PDF') {
      mimeType = 'application/pdf';
    }

    final multipartFile = await http.MultipartFile.fromPath(
      'files',
      renamedFile.path,
      contentType: MediaType.parse(mimeType),
    );

    final formFields = <String, String>{
      if (applicationID != null) 'applicationID': applicationID.toString(),
      if (documentType != null) 'documentType': documentType,
      if (transactionID != null) 'transactionID': transactionID,
    };

    AppUtils.log("Uploading photo with form-data:");
    AppUtils.log("File path: ${renamedFile.path}");
    AppUtils.log("Fields: $formFields");
    AppUtils.log("MIME Type: $mimeType");

    final response = await _apiMethod.put(
      url: Urls.uploadImage,
      body: formFields,
      multipartFile: multipartFile,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
      authToken: token,
    );

    if (response.isSuccess&& response.data?["data"]) {
      final List<dynamic> list = response.data?["data"] ?? [];

      List<Map<String, dynamic>> uploadedFiles = [];

      for (var item in list) {
        if (item is Map<String, dynamic>) {

          uploadedFiles.add(item);
        }
      }

      AppUtils.log(" Upload successful: Filenames: ${uploadedFiles.map((e) => e['filename'])}");
      AppUtils.log(" Corresponding fileIDs: ${uploadedFiles.map((e) => e['fileID'])}");

      return ResponseData<List<Map<String, dynamic>>>(
        isSuccess: true,
        data: uploadedFiles,
      );
    } else {
      AppUtils.log(" Photo upload failed with status: ${response.error}");
      throw Exception('Photo upload failed');
    }
  }


  Future<ResponseData> deleteImage({String? deleteImgId}) async {
    final token = Preferences.authToken;

    final result = await _apiMethod.delete(
      url: "${Urls.deleteImage}/$deleteImgId",
      authToken: token,
      customHeaders: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
    );

    if (result.isSuccess) {
      AppUtils.log(" File deleted successfully: $deleteImgId");

      return ResponseData(isSuccess: true);
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }




  Future<ResponseData<DashboardCountModel>> submit({
    required String applicationID,
    required String transactionID,
    required String latitude,
    required String longitude,
    required List<Map<String, dynamic>> documents,
    required String action,
    required Map<String, dynamic> checklist,
  }) async {
    final token = Preferences.authToken;

    final body = {
      "ui": action,
      "applicationID": applicationID,
      "transactionID": transactionID,
      "latitude": latitude,
      "longitude": longitude,
      "documents": documents,
      "checklist": checklist,
      "remarks": "remarks",
    };

    final prettyJson = const JsonEncoder.withIndent('  ').convert(body);

    AppUtils.log("Submit Body (JSON):\n$prettyJson");

    final result = await _apiMethod.put(
      url: Urls.submit,
      body: body,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
      authToken: token,
    );


    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final dataJson = rawData['data'] ?? {};
      final dashboardData = DashboardCountModel.fromJson(dataJson);
      AppUtils.toast(rawData['message']);
      return ResponseData(
        isSuccess: true,
        data: dashboardData,
        message: rawData['message'],
      );
    }
    else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
        message: result.data?['message'],
      );
    }
  }






  Future<ResponseData<DashboardCountModel>> submitUpdate({
    required String inspectionID,
    required String applicationID,
    required String transactionID,
    required String latitude,
    required String longitude,
    required List<Map<String, dynamic>> documents,
    required String action,
    required Map<String, dynamic> checklist,
  }) async {
    final token = Preferences.authToken;

    final body = {
      "inspectionID": inspectionID,
      "ui": action,
      "applicationID": applicationID,
      "transactionID": transactionID,
      "latitude": latitude,
      "longitude": longitude,
      "documents": documents,
      "checklist": checklist,
      "remarks": "remarks",
    };

    final prettyJson = const JsonEncoder.withIndent('  ').convert(body);

    AppUtils.log("Submit Update Body (JSON):\n$prettyJson");

    final result = await _apiMethod.patch(
      url: Urls.submitUpdate,
      body: body,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
      authToken: token,
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final dataJson = rawData['data'] ?? {};
      final dashboardData = DashboardCountModel.fromJson(dataJson);

      return ResponseData(
        isSuccess: true,
        data: dashboardData,
        message: rawData['message'],
      );
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
        message: result.data?['message'],
      );
    }
  }


  Future<ResponseData<ButtonData>> getButton({
    String? applicationID,
    String? transactionID,
  }) async {
    final token = Preferences.authToken;
    final Map<String, String> query = {
      "applicationID": applicationID ?? "",
      "transactionID": transactionID ?? ""
    };

    final result = await _apiMethod.get(
      url: Urls.getButton,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
      authToken: token,
      query: query,
    );

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final dataJson = rawData['data'];

      if (dataJson != null) {
        final buttonData = ButtonData.fromJson(dataJson);
        AppUtils.log("Button Data >>> ${buttonData.toJson()}");
        return ResponseData(isSuccess: true, data: buttonData);
      } else {
        return ResponseData(
          isSuccess: false,
          error: Exception("No data found"),
        );
      }
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
      );
    }
  }



}