import 'package:flutter/cupertino.dart';
import 'package:miliv2/src/widgets/custom_tooltip.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

OverlayTooltipItem withTooltip(
  Widget item,
  int index,
  String title,
  String description, {
  Transform Function(TooltipController)? transformer,
  double offsetX = 0,
  double offsetY = 10,
  TooltipHorizontalPosition posX = TooltipHorizontalPosition.WITH_WIDGET,
  TooltipVerticalPosition posY = TooltipVerticalPosition.BOTTOM,
}) {
  return OverlayTooltipItem(
    displayIndex: index,
    child: item,
    tooltipHorizontalPosition: posX,
    tooltipVerticalPosition: posY,
    tooltip: transformer != null
        ? transformer
        : (controller) => Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: MTooltip(
                title: title,
                description: description,
                controller: controller,
              ),
            ),
  );
}
