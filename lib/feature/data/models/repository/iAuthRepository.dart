import 'dart:convert';
import 'dart:io';

import 'package:bwssb/utils/appUtils.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../services/networking/apiMethods.dart';
import '../../../../services/networking/urls.dart';
import '../../../../services/storage/preferences.dart';
import '../../../domain/repository/authRepository.dart';
import '../../../presentation/screens/applicationScreen/application_form_screen.dart';
import '../dataModels/ButtonDataModel.dart';
import '../dataModels/application_model.dart';
import '../dataModels/dashboard_count_model.dart';
import '../dataModels/get_all_details_model.dart';
import '../dataModels/login_model/login_model.dart';
import '../dataModels/responseDataModel.dart';

import 'package:http/http.dart' as http;

class IAuthRepository implements AuthRepository {
  final IApiMethod _apiMethod = IApiMethod(baseUrl: Urls.api);

  // ── Auth ──────────────────────────────────────────────────────────────────────

  @override
  Future<ResponseData<LoginModel>> loginUser({
    required String user,
    required String password,
  }) async {
    final body = {'username': user, 'password': password};
    AppUtils.log("Login API URL: ${Urls.login}");
    final result = await _apiMethod.post(
      url: Urls.login,
      body: body,
      headers: {"x-app-platform": "android", "x-app-version": "1.0"},
    );
    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = rawData['data']?['user'] ?? {};
      final token = rawData['data']?['token'] ?? "";
      final userid = rawData['data']?['user']['user_id'].toString() ?? "";
      AppUtils.log("Token: $token");
      final data = LoginModel.fromJson(userData);
      Preferences.authToken = token;
      Preferences.profile = data;
      Preferences.uid = userid;
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  @override
  Future<ResponseData<LoginModel>> verifyUser({
    required String action,
    required String username,
    required String mobile,
  }) async {
    final body = {'action': action, 'username': username, 'mobile': mobile};
    final result = await _apiMethod.post(
      url: Urls.verifyUser,
      body: body,
      headers: {"x-app-platform": "android", "x-app-version": "1.0"},
    );
    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = rawData['data']?['user'] ?? {};
      final hash = rawData['data']?['hash'];
      final data = LoginModel.fromJson(userData).copyWith(hash: hash);
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  @override
  Future<ResponseData<LoginModel>> VerifyOtp({
    required String action,
    required String mobile,
    required String hash,
    required int? otp,
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
      headers: {"x-app-platform": "android", "x-app-version": "10.0"},
    );
    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = rawData['data'] ?? {};
      final data = LoginModel.fromJson(userData);
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
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
      headers: {"x-app-platform": "android", "x-app-version": "10.0"},
    );
    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = (rawData['data'] is Map)
          ? (rawData['data'] as Map)['user'] ?? {}
          : {};
      final data = LoginModel.fromJson(Map<String, dynamic>.from(userData));
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
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
        "Content-Type": "application/json",
      },
      authToken: Preferences.authToken.bearer,
    );
    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final userData = (rawData['data'] is Map)
          ? (rawData['data'] as Map)['user'] ?? {}
          : {};
      final data = LoginModel.fromJson(Map<String, dynamic>.from(userData));
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  // ── Application ───────────────────────────────────────────────────────────────

  @override
  Future<ResponseData<List<ApplicationModel>>> getApplication() async {
    final token = Preferences.authToken;
    final id = "17";
    final result = await _apiMethod.get(
      url: "${Urls.getApplication}/$id",
      body: {},
      headers: {"x-app-platform": "android", "x-app-version": "1.0"},
      authToken: token,
    );
    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final List<dynamic> appList = rawData['data'] ?? [];
      final applications =
      appList.map((j) => ApplicationModel.fromJson(j)).toList();
      return ResponseData(isSuccess: true, data: applications);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  @override
  Future<ResponseData<GetAllDetailsModel>> getAllDetails({String? id}) async {
    final token = Preferences.authToken;
    final actualId = id ?? "";
    try {
      final result = await _apiMethod.get(
        url: "${Urls.getAllDetails}/$actualId",
        body: {},
        headers: {"x-app-platform": "android", "x-app-version": "1.0"},
        authToken: token,
      );
      if (result.isSuccess) {
        final rawData = result.data;
        final dataJson = rawData?['data'];
        if (dataJson == null) {
          return ResponseData(
            isSuccess: false,
            error: Exception("No 'data' found in API response"),
          );
        }
        final details = GetAllDetailsModel.fromJson(dataJson);
        return ResponseData(isSuccess: true, data: details);
      } else {
        return ResponseData(isSuccess: false, error: result.getError);
      }
    } catch (e, st) {
      AppUtils.log("getAllDetails error: $e\n$st");
      return ResponseData(
          isSuccess: false, error: Exception("Unexpected error: $e"));
    }
  }

  @override
  Future<ResponseData<DashboardCountModel>> getDashBoardCount() async {
    final token = Preferences.authToken;
    final result = await _apiMethod.get(
      url: Urls.dashBoardCount,
      body: {},
      headers: {"x-app-platform": "android", "x-app-version": "1.0"},
      authToken: token,
    );
    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final dashboardData =
      DashboardCountModel.fromJson(rawData['data'] ?? {});
      return ResponseData(isSuccess: true, data: dashboardData);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  // ── deleteImage (original — kept so nothing else breaks) ──────────────────────

  @override
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
      AppUtils.log("File deleted: $deleteImgId");
      return ResponseData(isSuccess: true);
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  // ── deleteExistingDocument ────────────────────────────────────────────────────
  // DELETE /api/mobile/v2/file/{fileID}?applicationID=...&documentType=...

  @override
  Future<ResponseData> deleteExistingDocument({
    required String fileID,
    required String applicationID,
    required String documentType,
  }) async {
    final token = Preferences.authToken;
    final result = await _apiMethod.delete(
      url: "/mobile/v2/file/$fileID?applicationID=$applicationID&documentType=$documentType",
      authToken: token,
      customHeaders: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
      },
    );
    if (result.isSuccess) {
      AppUtils.log("Existing document deleted: $fileID");
      return ResponseData(
        isSuccess: true,
        message: result.data?['message']?.toString(),
      );
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  // ── saveLocation ──────────────────────────────────────────────────────────────
  // PUT  (first save) — no inspectionID
  // PATCH (update)    — with inspectionID

  @override
  Future<ResponseData<LocationSaveData>> saveLocation({
    required String ui,
    required String section,
    required String applicationID,
    required String transactionID,
    required String latitude,
    required String longitude,
    required bool isUpdate,
    String? inspectionID,
  }) async {
    final token = Preferences.authToken;
    final body = <String, dynamic>{
      "ui": ui,
      "section": section,
      "applicationID": applicationID,
      "transactionID": transactionID,
      "latitude": latitude,
      "longitude": longitude,
      if (isUpdate && inspectionID != null) "inspectionID": inspectionID,
    };

    AppUtils.log("saveLocation → ${isUpdate ? 'PATCH' : 'PUT'} ${Urls.locationUpdate}");
    AppUtils.log("body: ${const JsonEncoder.withIndent('  ').convert(body)}");

    final result = isUpdate
        ? await _apiMethod.patch(
      url: Urls.locationUpdate,
      body: body,
      authToken: token,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
        "Content-Type": "application/json",
      },
    )
        : await _apiMethod.put(
      url: Urls.locationUpdate,
      body: body,
      authToken: token,
      headers: {
        "x-app-platform": "android",
        "x-app-version": "1.0",
        "Content-Type": "application/json",
      },
    );

    AppUtils.log("saveLocation result: ${result.data}");

    if (result.isSuccess) {
      final rawData = result.data ?? {};
      final dataJson = rawData['data'] as Map<String, dynamic>? ?? {};
      return ResponseData(
        isSuccess: true,
        data: LocationSaveData.fromJson(dataJson),
        message: rawData['message']?.toString(),
      );
    } else {
      return ResponseData(
        isSuccess: false,
        error: result.getError,
        message: result.data?['message']?.toString(),
      );
    }
  }

  // ── submitWithFiles ───────────────────────────────────────────────────────────
  // PUT   (first submit) — no inspectionID
  // PATCH (update)       — with inspectionID + checklistID inside checklist JSON
  //
  // Uses raw http.MultipartRequest because _apiMethod.put supports only a
  // single MultipartFile. Multiple files under the same 'files' key require
  // building the request manually.

  @override
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
  }) async {
    final token = Preferences.authToken;
    final isUpdate = inspectionID != null && inspectionID.isNotEmpty;
    final httpMethod = isUpdate ? 'PATCH' : 'PUT';

    AppUtils.log("submitWithFiles → $httpMethod | update:$isUpdate | files:${files.length}");

    try {
      final uri = Uri.parse("${Urls.api}${Urls.submit}");
      final request = http.MultipartRequest(httpMethod, uri);

      // Same token pattern as all other _apiMethod calls —
      // ApiUtils.headerGen prepends "Bearer ", so we replicate that here.
      request.headers.addAll({
        "x-app-platform": "android",
        "x-app-version": "1.0",
        "Authorization": token.toString(),
      });

      request.fields['ui'] = ui;
      request.fields['applicationID'] = applicationID;
      request.fields['transactionID'] = transactionID;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['checklist'] = checklist;
      request.fields['remarks'] = remarks ?? "remark";
      if (documentMetadata != null) request.fields['documentMetadata'] = documentMetadata;
      if (isUpdate) request.fields['inspectionID'] = inspectionID!;

      AppUtils.log(
          "Fields: ${const JsonEncoder.withIndent('  ').convert(request.fields)}");

      for (final file in files) {
        final originalPath = file.path;
        final extension = originalPath.split('.').last;
        final upperExt = extension.toUpperCase();

        final renamedPath =
        originalPath.replaceFirst(RegExp(r'\.[^.]+$'), '.$upperExt');
        final renamedFile = await file.copy(renamedPath);

        String mimeType = 'application/octet-stream';
        if (['JPG', 'JPEG'].contains(upperExt)) {
          mimeType = 'image/jpeg';
        } else if (upperExt == 'PNG') {
          mimeType = 'image/png';
        } else if (upperExt == 'PDF') {
          mimeType = 'application/pdf';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            renamedFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final rawBody = jsonDecode(response.body) as Map<String, dynamic>;

      AppUtils.log("submitWithFiles [${response.statusCode}]: $rawBody");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dashboardData =
        DashboardCountModel.fromJson(rawBody['data'] ?? {});
        AppUtils.toast(rawBody['message']?.toString() ?? "");
        return ResponseData(
          isSuccess: true,
          data: dashboardData,
          message: rawBody['message']?.toString(),
        );
      } else {
        return ResponseData(
          isSuccess: false,
          error: Exception(rawBody['message'] ?? 'Submission failed'),
          message: rawBody['message']?.toString(),
        );
      }
    } catch (e, st) {
      AppUtils.log("submitWithFiles error: $e\n$st");
      return ResponseData(
          isSuccess: false, error: Exception("Unexpected error: $e"));
    }
  }

  // ── Button ────────────────────────────────────────────────────────────────────

  @override
  Future<ResponseData<ButtonData>> getButton({
    String? applicationID,
    String? transactionID,
  }) async {
    final token = Preferences.authToken;
    final result = await _apiMethod.get(
      url: Urls.getButton,
      headers: {"x-app-platform": "android", "x-app-version": "1.0"},
      authToken: token,
      query: {
        "applicationID": applicationID ?? "",
        "transactionID": transactionID ?? "",
      },
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
            isSuccess: false, error: Exception("No data found"));
      }
    } else {
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }
}