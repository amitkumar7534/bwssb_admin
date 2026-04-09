 //const String baseUrl = 'https://owc.hostg.in:6060/backend';
  const String baseUrl = 'https://api.owc.bwssb.gov.in';


class _UrlsCollections{
  static const String api = '$baseUrl/api';
  static const String v1 = '/mobile/v1';
  static const String v2 = '/mobile/v2';
  static const String auth = '$v1/auth';
  static const String adminProfile = '$v1/admin/profile';
  static const String authAdmin = '$v1/auth/admin';
  static const String list = '$v2/application/admin/list';
  static const String allDetails = '$v1/application/admin/details';
  static const String dashboard = '$v1/application/admin/dashboard';
  static const String submit = '$v2/application/admin';
  static const String submit1 = '$v1/application/admin';
  static const String fields = '$v2/application/admin';

}


class Urls{
  static const api = _UrlsCollections.api;
  static const login = '${_UrlsCollections.authAdmin}/login';
  static const verifyUser = '${_UrlsCollections.auth}/forgot-password';
  static const verifyOtp = '${_UrlsCollections.auth}/forgot-password';
  static const changePassword = '${_UrlsCollections.auth}/forgot-password';
  static const profileChangePassword = '${_UrlsCollections.adminProfile}/password';
  static const dashBoardCount = '${_UrlsCollections.dashboard}/count';
  static const getApplication = '${_UrlsCollections.list}';
  static const getAllDetails = '${_UrlsCollections.allDetails}';
  static const uploadImage = '${_UrlsCollections.v1}/file';
  static const deleteImage = '${_UrlsCollections.v1}/file';
  static const submit = '${_UrlsCollections.submit}/ui/fields';
  static const submitUpdate = '${_UrlsCollections.submit}/ui/fields';
  static const locationUpdate = '${_UrlsCollections.submit1}/ui/fields/location';
  static const getButton = '${_UrlsCollections.fields}/ui/fields';

}

