import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/new_tag.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final bool? isTopOffers;
  const StoreCard({super.key, required this.store, this.isTopOffers = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy;
    double distance = Get.find<StoreController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? '';
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;
    bool isAvailable = store.open == 1 && store.active!;

    return Stack(children: [
      Container(
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: ResponsiveHelper.isMobile(context)
              ? [
                  BoxShadow(
                      color: Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 0.2),
                      blurRadius: 5,
                      spreadRadius: 1)
                ]
              : null,
        ),
        child: CustomInkWell(
          onTap: () {
            if (Get.find<SplashController>().moduleList != null) {
              for (ModuleModel module
                  in Get.find<SplashController>().moduleList!) {
                if (module.id == store.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: store.id, page: 'store'),
              arguments: StoreScreen(store: store, fromModule: false),
            );
          },
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          radius: Dimensions.radiusDefault,
          child: TextHover(builder: (hovered) {
            return Stack(children: [
              Column(children: [
                Expanded(
                  flex: 5,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                              child: CustomImage(
                                isHovered: hovered,
                                image: '${store.logoFullUrl}',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            isAvailable
                                ? const SizedBox()
                                : NotAvailableWidget(
                                    isStore: true,
                                    store: store,
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    isAllSideRound: true),
                          ],
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 190,
                                  child: Text(
                                    store.name ?? '',
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                !isPharmacy
                                    ? store.ratingCount! > 0
                                        ? RatingBar(
                                            rating: store.avgRating,
                                            ratingCount: store.ratingCount,
                                            size: 12,
                                          )
                                        : const SizedBox()
                                    : Row(children: [
                                        Icon(Icons.storefront,
                                            size: 15,
                                            color:
                                                Theme.of(context).primaryColor),
                                        const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall),
                                        Expanded(
                                          child: Text(
                                            store.address ?? '',
                                            style: robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ]),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                !isPharmacy
                                    ? Row(children: [
                                        Icon(Icons.storefront,
                                            size: 15,
                                            color:
                                                Theme.of(context).primaryColor),
                                        const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall),
                                        Flexible(
                                          child: Text(
                                            store.address ?? '',
                                            style: robotoMedium.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ])
                                    : Text('${store.itemCount}' ' ' 'items'.tr,
                                        style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .primaryColor)),
                              ]),
                        ),
                      ]),
                ),
                Expanded(
                  flex: 2,
                  child: isTopOffers!
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraSmall,
                              vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Image.asset(
                                    Images.distanceLine,
                                    height: 15,
                                    width: 15,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                      '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                      style: robotoBold.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: Dimensions.fontSizeSmall)),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text('from_you'.tr,
                                      style: robotoRegular.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: Dimensions.fontSizeSmall)),
                                ]),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusExtraLarge),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: 3),
                                  child: Text(
                                    discount > 0
                                        ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                                        : 'free_delivery'.tr,
                                    style: robotoMedium.copyWith(
                                        color: Theme.of(context).cardColor,
                                        fontSize: Dimensions.fontSizeSmall),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ]),
                        )
                      : Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusExtraLarge),
                            ),
                            child: Row(children: [
                              Image.asset(Images.distanceLine,
                                  height: 15, width: 15),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                  '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                  style: robotoBold.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeSmall)),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text('from_you'.tr,
                                  style: robotoRegular.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeSmall)),
                            ]),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusExtraLarge),
                            ),
                            child: Row(children: [
                              Image.asset(Images.clockIcon,
                                  height: 15,
                                  width: 15,
                                  color: Get.find<StoreController>()
                                          .isOpenNow(store)
                                      ? const Color(0xffECA507)
                                      : Theme.of(context).colorScheme.error),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                  Get.find<StoreController>().isOpenNow(store)
                                      ? 'open_now'.tr
                                      : 'closed_now'.tr,
                                  style: robotoBold.copyWith(
                                      color: Get.find<StoreController>()
                                              .isOpenNow(store)
                                          ? const Color(0xffECA507)
                                          : Theme.of(context).colorScheme.error,
                                      fontSize: Dimensions.fontSizeSmall)),
                            ]),
                          ),
                        ]),
                ),
              ]),
              Positioned(
                top: 0,
                left: Get.find<LocalizationController>().isLtr ? null : 0,
                right: Get.find<LocalizationController>().isLtr ? 0 : null,
                child: GetBuilder<FavouriteController>(
                    builder: (favouriteController) {
                  bool isWished =
                      favouriteController.wishStoreIdList.contains(store.id);
                  return InkWell(
                    onTap: () {
                      if (AuthHelper.isLoggedIn()) {
                        isWished
                            ? favouriteController.removeFromFavouriteList(
                                store.id, true)
                            : favouriteController.addToFavouriteList(
                                null, store.id, true);
                      } else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    child: Icon(
                      isWished ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }),
              ),
            ]);
          }),
        ),
      ),
      !isTopOffers! ? const NewTag() : const SizedBox(),
    ]);
  }
}
