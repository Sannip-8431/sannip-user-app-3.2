import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/splash/domain/models/landing_model.dart';
import 'dart:convert';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/domain/repositories/splash_repository_interface.dart';

class SplashRepository implements SplashRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> getConfigData({required DataSourceEnum source}) async {
    Response responseData =
        Response(statusCode: 00, body: ApiClient.noInternetMessage);
    String cacheId = AppConstants.configUri;

    switch (source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.configUri);
        if (response.statusCode == 200) {
          responseData = Response(statusCode: 200, body: response.body);
          LocalClient.organize(source, cacheId, jsonEncode(response.body),
              apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData =
            await LocalClient.organize(source, cacheId, null, null);
        if (cacheResponseData != null) {
          responseData =
              Response(statusCode: 200, body: jsonDecode(cacheResponseData));
        }
    }
    return responseData;
  }

  @override
  Future<LandingModel?> getLandingPageData(
      {required DataSourceEnum source}) async {
    LandingModel? landingModel;
    String cacheId = AppConstants.landingPageUri;

    switch (source) {
      case DataSourceEnum.client:
        Response response =
            await apiClient.getData(AppConstants.landingPageUri);
        if (response.statusCode == 200) {
          landingModel = LandingModel.fromJson(response.body);
          LocalClient.organize(source, cacheId, jsonEncode(response.body),
              apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData =
            await LocalClient.organize(source, cacheId, null, null);
        if (cacheResponseData != null) {
          landingModel = LandingModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return landingModel;
  }

  @override
  Future<ModuleModel?> initSharedData() async {
    if (!sharedPreferences.containsKey(AppConstants.theme)) {
      sharedPreferences.setBool(AppConstants.theme, false);
    }
    if (!sharedPreferences.containsKey(AppConstants.countryCode)) {
      sharedPreferences.setString(
          AppConstants.countryCode, AppConstants.languages[0].countryCode!);
    }
    if (!sharedPreferences.containsKey(AppConstants.languageCode)) {
      sharedPreferences.setString(
          AppConstants.languageCode, AppConstants.languages[0].languageCode!);
    }
    if (!sharedPreferences.containsKey(AppConstants.cartList)) {
      sharedPreferences.setStringList(AppConstants.cartList, []);
    }
    if (!sharedPreferences.containsKey(AppConstants.searchHistory)) {
      sharedPreferences.setStringList(AppConstants.searchHistory, []);
    }
    if (!sharedPreferences.containsKey(AppConstants.notification)) {
      sharedPreferences.setBool(AppConstants.notification, true);
    }
    if (!sharedPreferences.containsKey(AppConstants.intro)) {
      sharedPreferences.setBool(AppConstants.intro, true);
    }
    if (!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if (!sharedPreferences.containsKey(AppConstants.suggestedLocation)) {
      sharedPreferences.setBool(AppConstants.suggestedLocation, false);
    }
    if (sharedPreferences.containsKey(AppConstants.referBottomSheet)) {
      sharedPreferences.setBool(AppConstants.referBottomSheet, true);
    }

    ModuleModel? module;
    if (sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        module = ModuleModel.fromJson(
            jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!));
      } catch (e) {
        debugPrint('Did not get shared Preferences module. Note: $e');
      }
    }
    return module;
  }

  @override
  void disableIntro() {
    sharedPreferences.setBool(AppConstants.intro, false);
  }

  @override
  bool? showIntro() {
    return sharedPreferences.getBool(AppConstants.intro);
  }

  @override
  Future<void> setStoreCategory(int storeCategoryID) async {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    } catch (e) {
      debugPrint('Did not get shared Preferences address . Note: $e');
    }
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      addressModel?.zoneIds,
      addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode),
      storeCategoryID,
      addressModel?.latitude,
      addressModel?.longitude,
    );
  }

  @override
  Future<List<ModuleModel>?> getModules(
      {Map<String, String>? headers, required DataSourceEnum source}) async {
    List<ModuleModel>? moduleList;
    String cacheId = AppConstants.moduleUri;

    switch (source) {
      case DataSourceEnum.client:
        Response response =
            await apiClient.getData(AppConstants.moduleUri, headers: headers);
        if (response.statusCode == 200) {
          moduleList = [];
          response.body.forEach((storeCategory) =>
              moduleList!.add(ModuleModel.fromJson(storeCategory)));
          LocalClient.organize(source, cacheId, jsonEncode(response.body),
              apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData =
            await LocalClient.organize(source, cacheId, null, null);
        if (cacheResponseData != null) {
          moduleList = [];
          jsonDecode(cacheResponseData).forEach((storeCategory) =>
              moduleList!.add(ModuleModel.fromJson(storeCategory)));
        }
    }

    return moduleList;
  }

  @override
  Future<void> setModule(ModuleModel? module) async {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    } catch (e) {
      debugPrint('Did not get shared Preferences address . Note: $e');
    }
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      addressModel?.zoneIds,
      addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode),
      module?.id,
      addressModel?.latitude,
      addressModel?.longitude,
    );
    if (module != null) {
      await sharedPreferences.setString(
          AppConstants.moduleId, jsonEncode(module.toJson()));
    } else {
      await sharedPreferences.remove(AppConstants.moduleId);
    }
  }

  @override
  Future<ModuleModel?> setCacheModule(ModuleModel? module) async {
    if (module != null) {
      await sharedPreferences.setString(
          AppConstants.cacheModuleId, jsonEncode(module.toJson()));
      return module;
    } else {
      await sharedPreferences.remove(AppConstants.cacheModuleId);
      return null;
    }
  }

  @override
  ModuleModel? getCacheModule() {
    ModuleModel? module;
    if (sharedPreferences.containsKey(AppConstants.cacheModuleId)) {
      try {
        module = ModuleModel.fromJson(jsonDecode(
            sharedPreferences.getString(AppConstants.cacheModuleId)!));
      } catch (e) {
        debugPrint('Did not get shared Preferences cache module. Note: $e');
      }
    }
    return module;
  }

  @override
  ModuleModel? getModule() {
    ModuleModel? module;
    if (sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        module = ModuleModel.fromJson(
            jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!));
      } catch (e) {
        debugPrint('Did not get shared Preferences module. Note: $e');
      }
    }
    return module;
  }

  @override
  Future<ResponseModel> subscribeEmail(String email) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(
        AppConstants.subscriptionUri, {'email': email},
        handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'subscribed_successfully'.tr);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  bool getSavedCookiesData() {
    return sharedPreferences.getBool(AppConstants.acceptCookies)!;
  }

  @override
  Future<void> saveCookiesData(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.acceptCookies, data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void cookiesStatusChange(String? data) {
    if (data != null) {
      sharedPreferences.setString(AppConstants.cookiesManagement, data);
    }
  }

  @override
  bool getAcceptCookiesStatus(String data) {
    return sharedPreferences.getString(AppConstants.cookiesManagement) !=
            null &&
        sharedPreferences.getString(AppConstants.cookiesManagement) == data;
  }

  @override
  bool getSuggestedLocationStatus() {
    return sharedPreferences.getBool(AppConstants.suggestedLocation)!;
  }

  @override
  Future<void> saveSuggestedLocationStatus(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.suggestedLocation, data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool getReferBottomSheetStatus() {
    return sharedPreferences.getBool(AppConstants.referBottomSheet) ?? true;
  }

  @override
  Future<void> saveReferBottomSheetStatus(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.referBottomSheet, data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
