import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class AuthRepositoryInterface extends RepositoryInterface {
  bool isSharedPrefNotificationActive();
  Future<Response> registration(SignUpBodyModel signUpBody);
  Future<Response> login(
      {required String emailOrPhone,
      required String password,
      required String loginType,
      required String fieldType});
  Future<Response> otpLogin(
      {required String phone,
      required String otp,
      required String loginType,
      required String verified});
  Future<Response> updatePersonalInfo(
      {required String name,
      required String? phone,
      required String loginType,
      required String? email,
      required String? referCode});
  Future<bool> saveUserToken(String token, {bool alreadyInApp = false});
  Future<Response> updateToken({String notificationDeviceToken = ''});
  Future<bool> saveSharedPrefGuestId(String id);
  String getSharedPrefGuestId();
  Future<bool> clearSharedPrefGuestId();
  bool isGuestLoggedIn();
  Future<bool> clearSharedData({bool removeToken = true});
  Future<ResponseModel> guestLogin();
  Future<Response> loginWithSocialMedia(SocialLogInBody socialLogInModel);
  bool isLoggedIn();
  Future<bool> clearSharedAddress();
  Future<void> saveUserNumberAndPassword(
      String number, String password, String countryCode);
  String getUserNumber();
  String getUserCountryCode();
  String getUserPassword();
  Future<bool> clearUserNumberAndPassword();
  String getUserToken();
  Future<Response> updateZone();
  Future<bool> saveGuestContactNumber(String number);
  String getGuestContactNumber();
  Future<bool> saveDmTipIndex(String index);
  String getDmTipIndex();
  Future<bool> saveEarningPoint(String point);
  String getEarningPint();
  Future<void> setNotificationActive(bool isActive);
  Future<String?> saveDeviceToken();
}
