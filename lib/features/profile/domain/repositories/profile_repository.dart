import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/profile/domain/models/update_profile_response_model.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/profile/domain/models/userinfo_model.dart';
import 'package:sixam_mart/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ProfileRepository implements ProfileRepositoryInterface {
  final ApiClient apiClient;
  ProfileRepository({required this.apiClient});

  @override
  Future<UserInfoModel?> get(String? id) async {
    UserInfoModel? userInfoModel;
    Response response = await apiClient.getData(AppConstants.customerInfoUri);
    if (response.statusCode == 200) {
      userInfoModel = UserInfoModel.fromJson(response.body);
    }
    return userInfoModel;
  }

/*  @override
  Future<ResponseModel> updateProfile(UserInfoModel userInfoModel, XFile? data, String token) async {
    ResponseModel responseModel;
    Map<String, String> body = {
      'f_name': userInfoModel.fName!,
      'l_name': userInfoModel.lName!,
      'email': userInfoModel.email!,
    };

    Response response = await apiClient.postMultipartData(AppConstants.updateProfileUri, body, [MultipartBody('image', data)], handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.bodyString);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }*/

  @override
  Future<ResponseModel> updateProfile(
      UpdateUserModel userInfoModel, XFile? data, String token) async {
    ResponseModel responseModel;
    Response response = await apiClient.postMultipartData(
        AppConstants.updateProfileUri,
        userInfoModel.toJson(),
        [MultipartBody('image', data)],
        handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(
        true,
        response.body['message'],
        updateProfileResponseModel: response.body['verification_on'] != null
            ? UpdateProfileResponseModel.fromJson(response.body)
            : null,
      );
    } else {
      responseModel = ResponseModel(
        false,
        response.statusText,
        updateProfileResponseModel: response.body['verification_on'] != null
            ? UpdateProfileResponseModel.fromJson(response.body)
            : null,
      );
    }
    return responseModel;
  }

/*  @override
  Future<ResponseModel> changePassword(UserInfoModel userInfoModel) async {
    ResponseModel responseModel;
    Map<String, dynamic> body = {
      'f_name': userInfoModel.fName,
      'l_name': userInfoModel.lName,
      'email': userInfoModel.email,
      'password': userInfoModel.password,
    };
    Response response = await apiClient.postData(AppConstants.updateProfileUri, body, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }*/

  @override
  Future<ResponseModel> changePassword(UserInfoModel userInfoModel) async {
    ResponseModel responseModel;
    Map<String, dynamic> data = {
      'name': '${userInfoModel.fName} ${userInfoModel.lName}',
      'email': userInfoModel.email,
      'password': userInfoModel.password,
      'phone': userInfoModel.phone,
      'button_type': 'change_password'
    };
    Response response = await apiClient
        .postData(AppConstants.updateProfileUri, data, handleError: false);
    if (response.statusCode == 200) {
      String? message = response.body["message"];
      responseModel = ResponseModel(true, message);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

/*  @override
  Future<ResponseModel> delete(int? id) async {
    ResponseModel responseModel;
    Response response = await apiClient.deleteData(AppConstants.customerRemoveUri, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'your_account_remove_successfully'.tr);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }*/

  @override
  Future<Response> delete(int? id) async {
    return await apiClient
        .postData(AppConstants.customerRemoveUri, {"_method": "delete"});
  }

  @override
  Future add(value) {
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
