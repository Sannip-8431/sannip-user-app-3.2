import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/screens/taxi_order_details_screen.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';

class TaxiGuestTrackOrderInputViewWidget extends StatefulWidget {
  const TaxiGuestTrackOrderInputViewWidget({super.key});

  @override
  State<TaxiGuestTrackOrderInputViewWidget> createState() =>
      _TaxiGuestTrackOrderInputViewWidgetState();
}

class _TaxiGuestTrackOrderInputViewWidgetState
    extends State<TaxiGuestTrackOrderInputViewWidget> {
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _orderFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    _countryDialCode =
        Get.find<AuthController>().getUserCountryCode().isNotEmpty
            ? Get.find<AuthController>().getUserCountryCode()
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>().configModel!.country!)
                .dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.radiusExtraLarge,
            vertical: Dimensions.paddingSizeLarge),
        child: Column(children: [
          CustomTextField(
            labelText: 'trip_id'.tr,
            titleText: 'write_trip_id'.tr,
            controller: _orderIdController,
            focusNode: _orderFocus,
            nextFocus: _phoneFocus,
            inputType: TextInputType.number,
            showTitle: ResponsiveHelper.isDesktop(context),
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, null),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          CustomTextField(
            titleText: 'enter_phone_number'.tr,
            labelText: 'phone'.tr,
            controller: _phoneNumberController,
            focusNode: _phoneFocus,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.done,
            isPhone: true,
            showTitle: ResponsiveHelper.isDesktop(context),
            onCountryChanged: (CountryCode countryCode) {
              _countryDialCode = countryCode.dialCode;
            },
            countryDialCode: _countryDialCode ??
                Get.find<LocalizationController>().locale.countryCode,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, null),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          GetBuilder<TaxiOrderController>(builder: (taxiOrderController) {
            return CustomButton(
              buttonText: 'track_trip'.tr,
              isLoading: taxiOrderController.isLoading,
              width:
                  ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
              onPressed: () async {
                String phone = _phoneNumberController.text.trim();
                String orderId = _orderIdController.text.trim();
                String numberWithCountryCode = _countryDialCode! + phone;
                PhoneValid phoneValid =
                    await CustomValidator.isPhoneValid(numberWithCountryCode);
                numberWithCountryCode = phoneValid.phone;

                if (orderId.isEmpty) {
                  showCustomSnackBar('please_enter_order_id'.tr);
                } else if (phone.isEmpty) {
                  showCustomSnackBar('enter_phone_number'.tr);
                } else if (!phoneValid.isValid) {
                  showCustomSnackBar('invalid_phone_number'.tr);
                } else {
                  taxiOrderController
                      .getTripDetails(int.parse(orderId),
                          phone: numberWithCountryCode)
                      .then((success) {
                    if (success) {
                      Get.to(TaxiOrderDetailsScreen(
                          tripId: int.parse(orderId),
                          phone: numberWithCountryCode));
                    }
                  });
                }
              },
            );
          }),
        ]),
      ),
    );
  }
}
