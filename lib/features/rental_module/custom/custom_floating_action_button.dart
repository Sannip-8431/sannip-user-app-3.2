import 'package:flutter/material.dart';

import '../../../util/dimensions.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final String heroTag;
  final Function() onTap;

  const CustomFloatingActionButton(
      {super.key,
      required this.icon,
      required this.heroTag,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                spreadRadius: 0.5,
                offset: const Offset(0, 4))
          ],
        ),
        child: FloatingActionButton(
          heroTag: heroTag,
          onPressed: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
