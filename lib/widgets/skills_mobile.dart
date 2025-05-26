import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/skill_items.dart';

class SkillsMobile extends StatefulWidget {
  const SkillsMobile({super.key});

  @override
  State<SkillsMobile> createState() => _SkillsMobileState();
}

class _SkillsMobileState extends State<SkillsMobile> {
  late List<bool> isHovering;
  @override
  void initState() {
    isHovering = List.filled(skillItems.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 500.0,
      ),
      child: Column(
        children: [
          // platforms
          for (int i = 0; i < platformItems.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 5.0),
              width: double.maxFinite,
              decoration: BoxDecoration(
                 color: Colors.black.withValues(),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                leading: Image.asset(
                  platformItems[i]["img"],
                  width: 26.0,
                ),
                title: Text(
                  platformItems[i]["title"],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          SizedBox(height: 50),

          // skills
          Wrap(
  spacing: 10.0,
  runSpacing: 10.0,
  alignment: WrapAlignment.center,
  children: List.generate(skillItems.length, (i) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isHovering[i] = true),
      onTapUp: (_) => setState(() => isHovering[i] = false),
      onTapCancel: () => setState(() => isHovering[i] = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovering[i] = true),
        onExit: (_) => setState(() => isHovering[i] = false),
        child: Animate(
          target: isHovering[i] ? 1 : 0,
        ).custom(builder: (_, value, __) {
          return Tooltip(
            message: skillItems[i]["title"],
            preferBelow: true,
            child: Chip(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              backgroundColor: Colors.black.withValues(),
              label: Text(
                skillItems[i]["title"],
                style: const TextStyle(color: Colors.white),
              ),
              avatar: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(skillItems[i]["img"]),
              ),
            ).animate(target: isHovering[i] ? 1 : 0).flip(
              end: -0.25,
              alignment: Alignment.bottomCenter,
              duration: 0.2.seconds,
            ),
          );
        }),
      ),
    );
  }),
)
 
        ],
      ),
    );
  }
}
