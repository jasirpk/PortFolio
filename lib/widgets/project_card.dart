// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reactable/reactable.dart';
import 'package:web_portfolio/utils/project_utils.dart';
import '../constants/colors.dart';
import 'dart:js' as js;

class ProjectCardWidget extends StatelessWidget {
  const ProjectCardWidget({
    super.key,
    required this.project,
  });
  final ProjectUtils project;

  @override
  Widget build(BuildContext context) {
    Reactable<bool> isHover = false.asReactable;
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (newIsHover) => isHover.value = newIsHover,
      child: Animate(
        target: isHover.value ? 1 : 0,
      ).custom(builder: (_, value, __) {
        return Scope(builder: (context) {
          return Container(
            clipBehavior: Clip.antiAlias,
            height: 290,
            width: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColor.bgLight2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // project img
                Image.asset(
                  project.image,
                  height: 140,
                  width: 260,
                  fit: BoxFit.cover,
                ),
                // title
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 15, 12, 12),
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CustomColor.whitePrimary,
                    ),
                  ),
                ),
                // subtitle
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text(
                    project.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CustomColor.whiteSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                // footer
                Container(
                  color: CustomColor.bgLight1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Available on:",
                        style: TextStyle(
                          color: CustomColor.yellowSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Spacer(),
                      if (project.androidLink != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: InkWell(
                                onTap: () {
                                  js.context
                                      .callMethod("open", [project.gitHubLink]);
                                },
                                child: Image.asset(
                                  "assets/images/github.png",
                                  width: 17,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: InkWell(
                                onTap: () {
                                  js.context.callMethod(
                                      "open", [project.androidLink]);
                                },
                                child: Image.asset(
                                  "assets/images/ios_icon.png",
                                  width: 17,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: InkWell(
                                onTap: () {
                                  js.context.callMethod(
                                      "open", [project.androidLink]);
                                },
                                child: Image.asset(
                                  "assets/images/android_icon.png",
                                  width: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          ).animate(target: isHover.value ? 1 : 0).flipV(
              end: -0.15, alignment: Alignment.center, duration: 0.2.seconds);
        });
      }),
    );
  }
}
