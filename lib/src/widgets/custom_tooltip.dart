import 'package:flutter/material.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

class MTooltip extends StatelessWidget {
  final TooltipController controller;
  final String title;
  final String description;

  const MTooltip({
    Key? key,
    required this.controller,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentDisplayIndex = controller.nextPlayIndex + 1;
    final totalLength = controller.playWidgetLength;
    final hasNextItem = currentDisplayIndex < totalLength;
    final hasPreviousItem = currentDisplayIndex != 1;
    final canPause = currentDisplayIndex < totalLength;

    return Container(
      width: size.width * .8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                WidgetSpan(
                  child: Opacity(
                    opacity: totalLength == 1 ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '$currentDisplayIndex dari $totalLength',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                )
              ])),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[100],
          ),
          Text(description),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: hasPreviousItem ? 1 : 0,
                child: TextButton(
                  onPressed: () {
                    debugPrint('previous');
                    controller.previous();
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text(
                    'Prev',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Opacity(
              //   opacity: canPause ? 1 : 0,
              //   child: TextButton(
              //     onPressed: () {
              //       debugPrint('skip');
              //       controller.pause();
              //       AppStorage.setFirstInstall(false);
              //     },
              //     style: TextButton.styleFrom(
              //         backgroundColor: Colors.orange,
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(5))),
              //     child: const Text(
              //       'Skip',
              //       style: TextStyle(
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
              TextButton(
                onPressed: () {
                  debugPrint('next/done');
                  controller.next();
                },
                style: TextButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Text(
                  hasNextItem ? 'Next' : 'Got It',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
