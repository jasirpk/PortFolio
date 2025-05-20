import 'package:flutter/material.dart';
import 'package:web_portfolio/services/downlod_cv.dart';
import '../constants/colors.dart';

class MainDesktop extends StatefulWidget {
  const MainDesktop({super.key});

  @override
  State<MainDesktop> createState() => _MainDesktopState();
}

class _MainDesktopState extends State<MainDesktop> with SingleTickerProviderStateMixin{
     late final Animation<double> bounceAnimation;
      late final AnimationController animationController;
  bool isHovering = false;
@override
void initState() {
  super.initState();
  animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  bounceAnimation = Tween<double>(begin: 0.0, end: -12.0)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(animationController);
}

    @override
  void dispose() {
    animationController.dispose();
  
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      height: screenHeight / 1.2,
      constraints: const BoxConstraints(minHeight: 350.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // 👈 improve text alignment
            children: [
              const Text(
                "Hi,\nI'm Jasir PK\nA Flutter Developer",
                style: TextStyle(
                  fontSize: 30,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: CustomColor.whitePrimary,
                ),
              ),
              const SizedBox(height: 25),
              MouseRegion(
                onEnter: (_) => onHover(true),
                onExit: (_) => onHover(false),
                child: InkWell(
                  onTap: downloadCV,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 250.0,
                    padding: const EdgeInsets.symmetric(vertical: 15.0), 
                    decoration: BoxDecoration(
                      color: isHovering ? CustomColor.whiteSecondary : Colors.white, 
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isHovering
                          ? [
                              const BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.download, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          'Download CV',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
         AnimatedBuilder(
            animation: bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, bounceAnimation.value),
                child: Image.asset(
                  "assets/images/my_flutter_avatar.png",
                  width: screenWidth / 2,
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  void onHover(bool hovering) {
    setState(() {
      isHovering = hovering;
    });
  }
}
