import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class FilterView extends StatelessWidget {
  final StoreController storeController;
  const FilterView({super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    return storeController.storeModel != null
        ? PopupMenuButton(
            padding: EdgeInsets.zero,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'all',
                  child: Text('all'.tr,
                      style: robotoMedium.copyWith(
                        color: storeController.filterType == 'all'
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Theme.of(context).disabledColor,
                      )),
                ),
                PopupMenuItem(
                  value: 'take_away',
                  child: Text('take_away'.tr,
                      style: robotoMedium.copyWith(
                        color: storeController.filterType == 'take_away'
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Theme.of(context).disabledColor,
                      )),
                ),
                PopupMenuItem(
                  value: 'delivery',
                  child: Text('delivery'.tr,
                      style: robotoMedium.copyWith(
                        color: storeController.filterType == 'delivery'
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Theme.of(context).disabledColor,
                      )),
                ),
              ];
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Icon(Icons.filter_list,
                    color: Theme.of(context).primaryColor),
              ),
            ),
            onSelected: (dynamic value) => storeController.setFilterType(value),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).disabledColor),
              ),
              child: Icon(Icons.filter_list,
                  color: Theme.of(context).disabledColor),
            ),
          );
  }
}
