import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../constants/skill_items.dart';

class SkillsDesktop extends StatefulWidget {
  const SkillsDesktop({super.key});

  @override
  State<SkillsDesktop> createState() => _SkillsDesktopState();
}

class _SkillsDesktopState extends State<SkillsDesktop> {
  late List<bool> isHovering;
  @override
  void initState() {
    isHovering = List.filled(skillItems.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // platforms
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 450,
          ),
          child: Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: [
              for (int i = 0; i < platformItems.length; i++)
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: CustomColor.bgLight2,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    leading: Image.asset(
                      platformItems[i]["img"],
                      width: 28.0,
                    ),
                    title: Text(
                      platformItems[i]["title"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
            ],
          ),
        ),
        SizedBox(width: 50),

        // skills
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: List.generate(skillItems.length, (i) {
                return FocusableActionDetector(
                  mouseCursor: SystemMouseCursors.click,
                  onShowHoverHighlight: (hovering) {
                    setState(() => isHovering[i] = hovering);
                  },
                  child: Animate(
                    target: isHovering[i] ? 1 : 0,
                  ).custom(builder: (_, value, __) {
                    return Tooltip(
                      message: skillItems[i]["title"]!,
                      preferBelow: true,
                      child: Chip(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        backgroundColor: CustomColor.bgLight2,
                        label: Text(
                         skillItems[i]["title"]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        avatar: Image.asset(skillItems[i]["img"]!),
                      ).animate(target: isHovering[i] ? 1 : 0).fade(
                          end: -0.15,
                          
                          duration: 0.2.seconds),
                    );
                  }),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
