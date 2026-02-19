import 'dart:convert';
import 'package:bwssb/services/networking/urls.dart';
import 'package:bwssb/utils/appUtils.dart';
import 'package:http/http.dart';
import '../../feature/data/models/dataModels/responseDataModel.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiUtils {
  // static Future<Response> getMethod(
  //         {required Uri url, Map<String, String>? headers}) =>
  //     get(url, headers: headers,);


  static Future<Response> getMethod(
      {required Uri url, Map<String, String>? headers,
        Map<String, dynamic>? body,
      }) async{
    var request = MultipartRequest('GET', url);
    if(headers != null){
      request.headers.addAll(headers);
    }
    if (body != null) {
      // Convert the body map to JSON
      var jsonBody = jsonEncode(body);

      // Set the JSON body to the request
      request.fields['_json'] = jsonBody; // You can use a custom field key if required


      // for (var entry in body.entries) {
      //   request.fields[entry.key] = entry.value.toString();
      // }
    }

    var streamedResponse = await request.send();
    var response = await Response.fromStream(streamedResponse);
    return response;
  }

  static Future<Response> patchMethod({
    required Uri url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? multipartFile,
  }) async {
    if (multipartFile != null) {
      var request = MultipartRequest('PATCH', url);

      if (headers != null) {
        AppUtils.log(headers);
        request.headers.addAll(headers);
      }

      for (var entry in multipartFile.entries) {
        String fieldName = entry.key;
        String filePath = entry.value;
        request.files.add(
          await MultipartFile.fromPath(fieldName, filePath),
        );
      }

      if (body != null) {
        for (var entry in body.entries) {
          request.fields[entry.key] = entry.value.toString();
        }
      }

      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);
      return response;
    }

    return patch(url, headers: headers, body: jsonEncode(body));
  }


  static Future<Response> postMethod(
      {required Uri url,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
      Map<String, String>? multipartFile}) async {
    // print(url.path);
    // AppUtils.log(Urls.appApiBaseUrl+url.path);
    AppUtils.log(Urls.api+url.path);
    AppUtils.log(headers);
    AppUtils.log(body);

    // AppUtils.log(multipartFile);
    // AppUtils.log(body);
    if (multipartFile != null) {
      var request = MultipartRequest('POST', url);
      if(headers != null){
        request.headers.addAll(headers);
      }
      for (var entry in multipartFile.entries) {
        String fieldName = entry.key;
        String filePath = entry.value;
        request.files.add(
          await MultipartFile.fromPath(fieldName, filePath),
        );
      }
      if (body != null) {
        for (var entry in body.entries) {
          request.fields[entry.key] = entry.value.toString();
        }
      }
      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);
      return response;
    } else {
      return post(url, headers: headers, body: jsonEncode(body));
    }
  }

  static Future<Response> putMethod({
    required Uri url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    http.MultipartFile? multipartFile,
  }) async {
    if (multipartFile != null) {
      var request = MultipartRequest('PUT', url);

      if (headers != null) {
        AppUtils.log(headers);
        request.headers.addAll(headers);
      }

      request.files.add(multipartFile);

      if (body != null) {
        for (var entry in body.entries) {
          request.fields[entry.key] = entry.value.toString();
        }
      }

      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);
      return response;
    }

    return put(url, headers: headers, body: jsonEncode(body));
  }


  static Future<Response> deleteMethod({
    required Uri url,
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final uriWithQuery = generateUri(url.toString(), query);
    AppUtils.log("DELETE → $uriWithQuery");
    AppUtils.log("Headers → $headers");

    return delete(uriWithQuery, headers: headers);
  }






  static Future<ResponseData<Map<String, dynamic>>> call({
    Map<String,dynamic>? responseStatusValue,
    required Future<Response> request,
    required Map<String, dynamic> Function(Map<String, dynamic>) data,
    Function(ResponseData)? error,

  }) async {
    // try{
    final result = await request;


    AppUtils.log(result.statusCode);
    AppUtils.log(result.body);
    // AppUtils.log(result.body);

    // AppUtils.log('statuscodse ::: ${result.statusCode}');
    if (result.statusCode >= 200 && result.statusCode < 300) {
      final body = jsonDecode(result.body) as Map<String, dynamic>;

      AppUtils.log(body);
      if (responseStatusValue != null
          ? body[responseStatusValue['key']] == responseStatusValue['value']
          : (body['success'] != null && body['success'] is bool ? body['success'] : false)) {
        return generateResponse<Map<String, dynamic>>(data(body));
      } else {
        return ResponseData(
            data: body, isSuccess: false, error: Exception(body['message']));
      }

    } else {




      String errorMsg = _statusErrors(result.statusCode);

      try{
       final error =  jsonDecode(result.body) as Map<String,dynamic>;
       if(error.containsKey('error')){
         errorMsg = error['error'];
       }else if(error.containsKey('message')){
         errorMsg = error['message'];
       }
      }catch(e){

      }
      // AppUtils.log(result.body);



      return ResponseData(
          isSuccess: false, error: Exception(errorMsg));
    }
    // }catch(e){
    //   return error?.call(ResponseData(
    //       isSuccess: false,
    //       error: Exception(e.toString())
    //   ));
    // }
  }

  static ResponseData<T> generateResponse<T>(T data) =>
      ResponseData(isSuccess: true, data: data);

  static Uri generateUri(String url, Map<String, String>? query) {
    AppUtils.log(url);
    Uri uri = Uri.parse(url);
    if (query != null) {
      final obj = uri.replace(queryParameters: query);
      uri = obj;
    }
    return uri;
  }

  static Map<String,String> headerGen({String? authToken, bool isMultipart = false}){
    Map<String,String> token = authToken != null ? {'Authorization':authToken} : <String,String>{};
    return {
      "Content-Type": isMultipart ? 'multipart/form-data' : "application/json",
      ...token
    };
  }


  static String _statusErrors(int statusCode) {
    String error = '';
    switch (statusCode) {
      case 400:
        error = 'Bad Request Exception';
        break;
      case 401:
        error = 'Unauthorised Exception';
        break;
      case 403:
        error = 'Access to the requested resource is forbidden';
        break;
      case 500:
        error = 'Internal Server Error';
        break;
      default:
        error = 'Unknown error: $statusCode';
        break;
    }
    return error;
  }
}
