import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/widgets/extra_packaging_widget.dart';
import 'package:sixam_mart/features/cart/widgets/not_available_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/web_constrained_box.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/cart/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/widgets/web_cart_items_widget.dart';
import 'package:sixam_mart/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  final GlobalKey _widgetKey = GlobalKey();
  double _height = 0;

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    _initialBottomSheetShowHide();
    if (Get.find<CartController>().cartList.isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
    }
    if (Get.find<CartController>().cartList.isNotEmpty) {
      if (kDebugMode) {
        print(
            '----cart item : ${Get.find<CartController>().cartList[0].toJson()}');
      }

      if (Get.find<CartController>().addCutlery) {
        Get.find<CartController>().updateCutlery(willUpdate: false);
      }
      if (Get.find<CartController>().needExtraPackage) {
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(
          Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(
          Store(
              id: Get.find<CartController>().cartList[0].item!.storeId,
              name: null),
          false,
          fromCart: true);
      Get.find<CartController>().calculationCart();
      showReferAndEarnSnackBar();
    }
  }

  void _initialBottomSheetShowHide() {
    Future.delayed(const Duration(milliseconds: 600), () {
      key.currentState?.expand();
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          key.currentState?.contract();
        });
      });
    });
  }

  void _getExpandedBottomSheetHeight() {
    final RenderBox renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;

    setState(() {
      _height = size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
          title: 'my_cart'.tr,
          backButton: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty
              ? Column(children: [
                  Expanded(
                    child: ExpandableBottomSheet(
                      key: key,
                      persistentHeader: isDesktop
                          ? const SizedBox()
                          : InkWell(
                              onTap: () {
                                if (cartController.isExpanded) {
                                  cartController.setExpanded(false);
                                  setState(() {
                                    key.currentState!.contract();
                                  });
                                } else {
                                  cartController.setExpanded(true);
                                  setState(() {
                                    key.currentState!.expand();
                                  });
                                }
                              },
                              child: Container(
                                color: Theme.of(context).cardColor,
                                child: Container(
                                  constraints:
                                      const BoxConstraints.expand(height: 30),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.3),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                            Dimensions.radiusDefault),
                                        topRight: Radius.circular(
                                            Dimensions.radiusDefault)),
                                  ),
                                  child: Icon(Icons.drag_handle,
                                      color: Theme.of(context).hintColor,
                                      size: 25),
                                ),
                              ),
                            ),
                      background: Column(children: [
                        WebScreenTitleWidget(title: 'cart_list'.tr),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: ResponsiveHelper.isDesktop(context)
                                ? const EdgeInsets.only(
                                    top: Dimensions.paddingSizeSmall,
                                  )
                                : EdgeInsets.zero,
                            child: FooterView(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: Column(children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ResponsiveHelper.isDesktop(context)
                                          ? WebCardItemsWidget(
                                              cartList: cartController.cartList)
                                          : Expanded(
                                              flex: 7,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    WebConstrainedBox(
                                                      dataLength: cartController
                                                          .cartList.length,
                                                      minLength: 5,
                                                      minHeight: 0.6,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                boxShadow: !ResponsiveHelper
                                                                        .isMobile(
                                                                            context)
                                                                    ? [
                                                                        const BoxShadow()
                                                                      ]
                                                                    : [
                                                                        const BoxShadow(
                                                                          color:
                                                                              Colors.black12,
                                                                          blurRadius:
                                                                              10,
                                                                          spreadRadius:
                                                                              0,
                                                                        )
                                                                      ],
                                                              ),
                                                              child: ListView
                                                                  .builder(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    cartController
                                                                        .cartList
                                                                        .length,
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeDefault),
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return CartItemWidget(
                                                                      cart: cartController
                                                                              .cartList[
                                                                          index],
                                                                      cartIndex:
                                                                          index,
                                                                      addOns: cartController
                                                                              .addOnsList[
                                                                          index],
                                                                      isAvailable:
                                                                          cartController.availableList[
                                                                              index],
                                                                      showDivider:
                                                                          index !=
                                                                              cartController.cartList.length - 1);
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall),
                                                            Center(
                                                              child: TextButton
                                                                  .icon(
                                                                onPressed: () {
                                                                  cartController.forcefullySetModule(
                                                                      cartController
                                                                          .cartList[
                                                                              0]
                                                                          .item!
                                                                          .moduleId!);
                                                                  Get.toNamed(
                                                                    RouteHelper.getStoreRoute(
                                                                        id: cartController
                                                                            .cartList[
                                                                                0]
                                                                            .item!
                                                                            .storeId,
                                                                        page:
                                                                            'item'),
                                                                    arguments: StoreScreen(
                                                                        store: Store(
                                                                            id: cartController
                                                                                .cartList[
                                                                                    0]
                                                                                .item!
                                                                                .storeId),
                                                                        fromModule:
                                                                            false),
                                                                  );
                                                                },
                                                                icon: Icon(
                                                                    Icons
                                                                        .add_circle_outline_sharp,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor),
                                                                label: Text(
                                                                    'add_more_items'
                                                                        .tr,
                                                                    style: robotoMedium.copyWith(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                        fontSize:
                                                                            Dimensions.fontSizeDefault)),
                                                              ),
                                                            ),
                                                            ExtraPackagingWidget(
                                                                cartController:
                                                                    cartController),
                                                            !ResponsiveHelper
                                                                    .isDesktop(
                                                                        context)
                                                                ? suggestedItemView(
                                                                    cartController
                                                                        .cartList)
                                                                : const SizedBox(),
                                                          ]),
                                                    ),
                                                    const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeSmall),
                                                    !ResponsiveHelper.isDesktop(
                                                            context)
                                                        ? pricingView(
                                                            cartController,
                                                            cartController
                                                                .cartList[0]
                                                                .item!)
                                                        : const SizedBox(),
                                                  ]),
                                            ),
                                      ResponsiveHelper.isDesktop(context)
                                          ? const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall)
                                          : const SizedBox(),
                                      ResponsiveHelper.isDesktop(context)
                                          ? Expanded(
                                              flex: 4,
                                              child: pricingView(
                                                  cartController,
                                                  cartController
                                                      .cartList[0].item!))
                                          : const SizedBox(),
                                    ],
                                  ),
                                  ResponsiveHelper.isDesktop(context)
                                      ? WebSuggestedItemViewWidget(
                                          cartList: cartController.cartList)
                                      : const SizedBox(),
                                  const SizedBox(
                                      height:
                                          Dimensions.paddingSizeExtraOverLarge),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: _height),
                      ]),
                      onIsExtendedCallback: () {
                        ///Don't remove this print.
                        print('======= expandableContent open');
                        _getExpandedBottomSheetHeight();
                        // setState(() {
                        //   _height = 100;
                        // });
                      },
                      onIsContractedCallback: () {
                        ///Don't remove this print.
                        print('======= expandableContent close');
                        setState(() {
                          _height = 0;
                        });
                      },
                      expandableContent: isDesktop
                          ? const SizedBox()
                          : Container(
                              width: context.width,
                              key: _widgetKey,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(
                                        Dimensions.radiusDefault),
                                    topRight: Radius.circular(
                                        Dimensions.radiusDefault)),
                              ),
                              child: Column(children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: Dimensions.paddingSizeSmall,
                                    right: Dimensions.paddingSizeSmall,
                                    top: Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                            Dimensions.radiusDefault),
                                        topRight: Radius.circular(
                                            Dimensions.radiusDefault)),
                                  ),
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('item_price'.tr,
                                              style: robotoRegular),
                                          PriceConverter.convertAnimationPrice(
                                              cartController.itemPrice,
                                              textStyle: robotoRegular),
                                        ]),
                                    SizedBox(
                                        height: cartController.variationPrice >
                                                    0 &&
                                                ModuleHelper.getModuleConfig(
                                                        cartController
                                                            .cartList
                                                            .first
                                                            .item!
                                                            .moduleType)
                                                    .newVariation!
                                            ? Dimensions.paddingSizeSmall
                                            : 0),
                                    cartController.variationPrice > 0 &&
                                            ModuleHelper.getModuleConfig(
                                                    cartController.cartList
                                                        .first.item!.moduleType)
                                                .newVariation!
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('variations'.tr,
                                                  style: robotoRegular),
                                              Text(
                                                '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                                style: robotoRegular,
                                                textDirection:
                                                    TextDirection.ltr,
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('discount'.tr,
                                              style: robotoRegular),
                                          storeController.store != null
                                              ? Row(children: [
                                                  Text('(-)',
                                                      style: robotoRegular),
                                                  PriceConverter
                                                      .convertAnimationPrice(
                                                          cartController
                                                              .itemDiscountPrice,
                                                          textStyle:
                                                              robotoRegular),
                                                ])
                                              : Text('calculating'.tr,
                                                  style: robotoRegular),
                                        ]),
                                    SizedBox(
                                        height: Get.find<SplashController>()
                                                .configModel!
                                                .moduleConfig!
                                                .module!
                                                .addOn!
                                            ? Dimensions.paddingSizeSmall
                                            : 0),
                                    Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .addOn!
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('addons'.tr,
                                                  style: robotoRegular),
                                              Row(children: [
                                                Text('(+)',
                                                    style: robotoRegular),
                                                PriceConverter
                                                    .convertAnimationPrice(
                                                        cartController.addOns,
                                                        textStyle:
                                                            robotoRegular),
                                              ]),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ]),
                                ),
                              ]),
                            ),
                    ),
                  ),
                  ResponsiveHelper.isDesktop(context)
                      ? const SizedBox.shrink()
                      : CheckoutButton(
                          cartController: cartController,
                          availableList: cartController.availableList),
                ])
              : const NoDataScreen(isCart: true, text: '', showFooter: true);
        });
      }),
    );
  }

  Widget pricingView(CartController cartController, Item item) {
    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.isDesktop(context)
                      ? Dimensions.radiusDefault
                      : Dimensions.radiusSmall),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
              ],
            )
          : null,
      child: GetBuilder<StoreController>(builder: (storeController) {
        return Column(children: [
          ResponsiveHelper.isDesktop(context)
              ? ExtraPackagingWidget(cartController: cartController)
              : const SizedBox(),

          ResponsiveHelper.isDesktop(context)
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall),
                    child: Text('order_summary'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                  ),
                )
              : const SizedBox(),

          !ResponsiveHelper.isDesktop(context) &&
                  Get.find<SplashController>()
                      .getModuleConfig(item.moduleType)
                      .newVariation! &&
                  (storeController.store != null &&
                      storeController.store!.cutlery!)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade50,
                          blurRadius: 2,
                          spreadRadius: 1)
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeSmall),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(Images.cutlery, height: 18, width: 18),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('add_cutlery'.tr,
                                    style: robotoMedium.copyWith(
                                        color: Theme.of(context).primaryColor)),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                Text('do_not_have_cutlery'.tr,
                                    style: robotoRegular.copyWith(
                                        color: Theme.of(context).disabledColor,
                                        fontSize: Dimensions.fontSizeSmall)),
                              ]),
                        ),
                        Transform.scale(
                          scale: 0.7,
                          child: CupertinoSwitch(
                            value: cartController.addCutlery,
                            activeTrackColor: Theme.of(context).primaryColor,
                            onChanged: (bool? value) {
                              cartController.updateCutlery();
                            },
                            inactiveTrackColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ]),
                )
              : const SizedBox(),

          ResponsiveHelper.isDesktop(context)
              ? const SizedBox()
              : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade50,
                          blurRadius: 2,
                          spreadRadius: 1)
                    ],
                    // border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  margin: ResponsiveHelper.isDesktop(context)
                      ? const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall)
                      : EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (ResponsiveHelper.isDesktop(context)) {
                            Get.dialog(const Dialog(
                                child: NotAvailableBottomSheetWidget()));
                          } else {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (con) =>
                                  const NotAvailableBottomSheetWidget(),
                            );
                          }
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text('if_any_product_is_not_available'.tr,
                                  style: robotoMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.arrow_forward_ios_sharp, size: 18),
                        ]),
                      ),
                      cartController.notAvailableIndex != -1
                          ? Row(children: [
                              Text(
                                  cartController
                                      .notAvailableList[
                                          cartController.notAvailableIndex]
                                      .tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).primaryColor)),
                              IconButton(
                                onPressed: () =>
                                    cartController.setAvailableIndex(-1),
                                icon: const Icon(Icons.clear, size: 18),
                              )
                            ])
                          : const SizedBox(),
                    ],
                  ),
                ),
          ResponsiveHelper.isDesktop(context)
              ? const SizedBox()
              : const SizedBox(height: Dimensions.paddingSizeSmall),

          // Total
          ResponsiveHelper.isDesktop(context)
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('item_price'.tr, style: robotoRegular),
                          PriceConverter.convertAnimationPrice(
                              cartController.itemPrice,
                              textStyle: robotoRegular),
                        ]),
                    SizedBox(
                        height: cartController.variationPrice > 0
                            ? Dimensions.paddingSizeSmall
                            : 0),
                    Get.find<SplashController>()
                                .getModuleConfig(item.moduleType)
                                .newVariation! &&
                            cartController.variationPrice > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('variations'.tr, style: robotoRegular),
                              Text(
                                  '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                  style: robotoRegular,
                                  textDirection: TextDirection.ltr),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('discount'.tr, style: robotoRegular),
                          storeController.store != null
                              ? Row(children: [
                                  Text('(-)', style: robotoRegular),
                                  PriceConverter.convertAnimationPrice(
                                      cartController.itemDiscountPrice,
                                      textStyle: robotoRegular),
                                ])
                              : Text('calculating'.tr, style: robotoRegular),
                          // Text('(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                        ]),
                    SizedBox(
                        height: Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .addOn!
                            ? 10
                            : 0),
                    Get.find<SplashController>()
                            .configModel!
                            .moduleConfig!
                            .module!
                            .addOn!
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('addons'.tr, style: robotoRegular),
                              Text(
                                  '(+) ${PriceConverter.convertPrice(cartController.addOns)}',
                                  style: robotoRegular,
                                  textDirection: TextDirection.ltr),
                            ],
                          )
                        : const SizedBox(),
                  ]),
                )
              : const SizedBox(),

          ResponsiveHelper.isDesktop(context)
              ? CheckoutButton(
                  cartController: cartController,
                  availableList: cartController.availableList)
              : const SizedBox.shrink(),
        ]);
      }),
    );
  }

  Widget suggestedItemView(List<CartModel> cartList) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if (storeController.cartSuggestItemModel != null) {
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if (!cartIds.contains(item.id)) {
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null &&
                  suggestedItems!.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeExtraSmall),
                      child: Text('you_may_also_like'.tr,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault)),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 160 : 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: suggestedItems.length,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                            left: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.paddingSizeExtraSmall
                                : Dimensions.paddingSizeDefault),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: ResponsiveHelper.isDesktop(context)
                                ? const EdgeInsets.symmetric(vertical: 20)
                                : const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: ResponsiveHelper.isDesktop(context)
                                  ? 500
                                  : 300,
                              padding: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeSmall,
                                  left: Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeSmall),
                              child: ItemWidget(
                                isStore: false,
                                item: suggestedItems![index],
                                fromCartSuggestion: true,
                                store: null,
                                index: index,
                                length: null,
                                isCampaign: false,
                                inStore: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const SizedBox();
        }),
      ]),
    );
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if (Get.find<ProfileController>().userInfoModel != null &&
        Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
  }
}

class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  const CheckoutButton(
      {super.key, required this.cartController, required this.availableList});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
      ),
      child: GetBuilder<StoreController>(builder: (storeController) {
        if (Get.find<StoreController>().store != null &&
            !Get.find<StoreController>().store!.freeDelivery! &&
            (Get.find<SplashController>()
                        .configModel
                        ?.adminFreeDelivery
                        ?.status ==
                    true &&
                (Get.find<SplashController>()
                            .configModel
                            ?.adminFreeDelivery
                            ?.type !=
                        null &&
                    Get.find<SplashController>()
                            .configModel
                            ?.adminFreeDelivery
                            ?.type ==
                        'free_delivery_by_order_amount') &&
                (Get.find<SplashController>()
                        .configModel!
                        .adminFreeDelivery
                        ?.freeDeliveryOver !=
                    null))) {
          percentage = cartController.subTotal /
              Get.find<SplashController>()
                  .configModel!
                  .adminFreeDelivery!
                  .freeDeliveryOver!;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (storeController.store != null &&
                    !storeController.store!.freeDelivery! &&
                    (Get.find<SplashController>()
                                .configModel
                                ?.adminFreeDelivery
                                ?.status ==
                            true &&
                        (Get.find<SplashController>()
                                    .configModel
                                    ?.adminFreeDelivery
                                    ?.type !=
                                null &&
                            Get.find<SplashController>()
                                    .configModel
                                    ?.adminFreeDelivery
                                    ?.type ==
                                'free_delivery_by_order_amount') &&
                        (Get.find<SplashController>()
                                .configModel!
                                .adminFreeDelivery
                                ?.freeDeliveryOver !=
                            null)) &&
                    percentage < 1)
                ? Column(children: [
                    Row(children: [
                      Image.asset(Images.percentTag, height: 20, width: 20),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        PriceConverter.convertPrice(Get.find<SplashController>()
                                .configModel!
                                .adminFreeDelivery!
                                .freeDeliveryOver! -
                            cartController.subTotal),
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor),
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('more_for_free_delivery'.tr,
                          style: robotoMedium.copyWith(
                              color: Theme.of(context).disabledColor)),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    LinearProgressIndicator(
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      value: percentage,
                    ),
                  ])
                : const SizedBox(),
            ResponsiveHelper.isDesktop(context)
                ? const Divider(height: 1)
                : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('subtotal'.tr,
                      style: robotoMedium.copyWith(
                          color: ResponsiveHelper.isDesktop(context)
                              ? Theme.of(context).textTheme.bodyLarge!.color
                              : Theme.of(context).primaryColor)),
                  PriceConverter.convertAnimationPrice(cartController.subTotal,
                      textStyle: robotoRegular.copyWith(
                          color: Theme.of(context).primaryColor)),
                  // Text(
                  //   PriceConverter.convertPrice(cartController.subTotal),
                  //   style: robotoMedium.copyWith(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                  // ),
                ],
              ),
            ),
            ResponsiveHelper.isDesktop(context) &&
                    Get.find<SplashController>()
                        .getModuleConfig(
                            cartController.cartList[0].item!.moduleType)
                        .newVariation! &&
                    (storeController.store != null &&
                        storeController.store!.cutlery!)
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(Images.cutlery, height: 18, width: 18),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('add_cutlery'.tr,
                                      style: robotoMedium.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  Text('do_not_have_cutlery'.tr,
                                      style: robotoRegular.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: Dimensions.fontSizeSmall)),
                                ]),
                          ),
                          Transform.scale(
                            scale: 0.7,
                            child: CupertinoSwitch(
                              value: cartController.addCutlery,
                              activeTrackColor: Theme.of(context).primaryColor,
                              onChanged: (bool? value) {
                                cartController.updateCutlery();
                              },
                              inactiveTrackColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.5),
                            ),
                          )
                        ]),
                  )
                : const SizedBox(),
            ResponsiveHelper.isDesktop(context)
                ? const SizedBox(height: Dimensions.paddingSizeSmall)
                : const SizedBox(),
            !ResponsiveHelper.isDesktop(context)
                ? const SizedBox()
                : Container(
                    width: Dimensions.webMaxWidth,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 0.5),
                    ),
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    //margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            if (ResponsiveHelper.isDesktop(context)) {
                              Get.dialog(const Dialog(
                                  child: NotAvailableBottomSheetWidget()));
                            } else {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (con) =>
                                    const NotAvailableBottomSheetWidget(),
                              );
                            }
                          },
                          child: Row(children: [
                            Expanded(
                                child: Text(
                                    'if_any_product_is_not_available'.tr,
                                    style: robotoMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.keyboard_arrow_down, size: 18),
                          ]),
                        ),
                        cartController.notAvailableIndex != -1
                            ? Row(children: [
                                Text(
                                    cartController
                                        .notAvailableList[
                                            cartController.notAvailableIndex]
                                        .tr,
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).primaryColor)),
                                IconButton(
                                  onPressed: () =>
                                      cartController.setAvailableIndex(-1),
                                  icon: const Icon(Icons.clear, size: 18),
                                )
                              ])
                            : const SizedBox(),
                      ],
                    ),
                  ),
            ResponsiveHelper.isDesktop(context)
                ? const SizedBox(height: Dimensions.paddingSizeSmall)
                : const SizedBox(),
            SafeArea(
              child: CustomButton(
                  buttonText: 'confirm_delivery_details'.tr,
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeSmall
                      : Dimensions.fontSizeLarge,
                  isBold: ResponsiveHelper.isDesktop(context) ? false : true,
                  radius: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.radiusSmall
                      : Dimensions.radiusDefault,
                  onPressed: () {
                    Get.find<CheckoutController>().updateFirstTime();
                    if (!cartController.cartList.first.item!.scheduleOrder! &&
                        availableList.contains(false)) {
                      showCustomSnackBar('one_or_more_product_unavailable'.tr);
                    } /*else if(AuthHelper.isGuestLoggedIn() && !Get.find<SplashController>().configModel!.guestCheckoutStatus!) {
                    showCustomSnackBar('currently_your_zone_have_no_permission_to_place_any_order'.tr);
                  }*/
                    else {
                      if (Get.find<SplashController>().module == null) {
                        int i = 0;
                        for (i = 0;
                            i < Get.find<SplashController>().moduleList!.length;
                            i++) {
                          if (cartController.cartList[0].item!.moduleId ==
                              Get.find<SplashController>().moduleList![i].id) {
                            break;
                          }
                        }
                        Get.find<SplashController>().setModule(
                            Get.find<SplashController>().moduleList![i]);
                        HomeScreen.loadData(true);
                      }
                      Get.find<CouponController>().removeCouponData(false);

                      Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                    }
                  }),
            ),
          ],
        );
      }),
    );
  }
}
