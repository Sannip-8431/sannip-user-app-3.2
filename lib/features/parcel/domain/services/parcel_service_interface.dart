import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/video_content_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/why_choose_model.dart';
import 'package:sixam_mart/features/payment/domain/models/offline_method_model.dart';

import '../models/parcel_instruction_model.dart';

abstract class ParcelServiceInterface {
  Future<List<ParcelCategoryModel>?> getParcelCategory();
  Future<List<Data>?> getParcelInstruction(int offset);
  Future<WhyChooseModel?> getWhyChooseDetails({required DataSourceEnum source});
  Future<VideoContentModel?> getVideoContentDetails(
      {required DataSourceEnum source});
  Future<LatLng> getPlaceDetails(String? placeID);
  Future<List<OfflineMethodModel>?> getOfflineMethodList();
  Future<int> getDmTipMostTapped();
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody);
}
