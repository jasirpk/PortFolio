import 'dart:math' as math;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:background_bubbles/background_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:web_portfolio/constants/about_me.dart';
import 'package:web_portfolio/constants/colors.dart';
import 'package:web_portfolio/constants/size.dart';
import 'package:web_portfolio/widgets/contact_section.dart';
import 'package:web_portfolio/widgets/drawer_mobile.dart';
import 'package:web_portfolio/widgets/footer.dart';
import 'package:web_portfolio/widgets/header_desktop.dart';
import 'package:web_portfolio/widgets/header_mobile.dart';
import 'package:web_portfolio/widgets/main_desktop.dart';
import 'package:web_portfolio/widgets/main_mobile.dart';
import 'package:web_portfolio/widgets/project_section.dart';
import 'package:web_portfolio/widgets/scroll_controller.dart';
import 'package:web_portfolio/widgets/skills_desktop.dart';
import 'package:web_portfolio/widgets/skills_mobile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> bounceAnimation;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final scrollController = ScrollController();
  final List<GlobalKey> navbarkeys = List.generate(5, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    bounceAnimation = Tween<double>(begin: 0.0, end: -40.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollToSection(int navIndex) {
    final keyContext = navbarkeys[navIndex].currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kMinDesktopWidth;
        final isLargeScreen = constraints.maxWidth >= kMedDesktopWidth;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: CustomColor.scaffoldBg,
          endDrawer: isDesktop
              ? null
              : DrawerMobile(
                  onNavItemTap: (index) {
                    scaffoldKey.currentState?.openDrawer();
                    scrollToSection(index);
                  },
                ),
          body: BubblesAnimation(
            particleColor: Colors.indigo,
            particleCount: isDesktop ? 400 : 100,
            particleRadius: 5,
            widget: SingleChildScrollView(
              controller: scrollController,
              physics: const SlowScrollPhysics(speedFactor: 0.5),
              child: Column(
                children: [
                  SizedBox(key: navbarkeys[0]),
                  isDesktop
                      ? HeaderDesktop(onNavMenuTap: scrollToSection)
                      : HeaderMobile(
                          onLogoTap: () => scrollToSection(0),
                          onMenuTap: () =>
                              scaffoldKey.currentState?.openEndDrawer()),
                  isDesktop ? MainDesktop() : MainMobile(),
                  Container(
                    key: navbarkeys[1],
                    width: screenWidth,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
                    color: CustomColor.bgLight1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'What I can do',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CustomColor.whitePrimary,
                            letterSpacing: 2,
                   wordSpacing: 2
                          ),
                        ),
                        const SizedBox(height: 50),
                        isLargeScreen ? SkillsDesktop() : SkillsMobile(),
                      ],
                    ),
                  ),
                 
                  ProjectsSection(key: navbarkeys[2]),
             
   Container(
  key: navbarkeys[3],
  width: screenWidth,
  padding: const EdgeInsets.fromLTRB(25, 40, 25, 60),
  decoration: BoxDecoration(
    color: CustomColor.bgLight1,
    boxShadow: [
      BoxShadow(
        color: Colors.white.withAlpha(3),
        blurRadius: 10,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
     
    Container(
  width: 220,
  height: 220,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    image: DecorationImage(
      image: AssetImage('assets/images/my_pic.jpg'),
      fit: BoxFit.cover, // Spread to cover the entire circle
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withValues(),
        blurRadius: 10,
        offset: Offset(0, 6),
      ),
    ],
  ),
),

      const SizedBox(height: 20),

      const Text(
        'About Me',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: CustomColor.whitePrimary,
          letterSpacing: 2,
          wordSpacing: 2,
        ),
      ),
      const SizedBox(height: 50),

      Center(
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            wordSpacing: 2,
          ),
          child: AnimatedTextKit(
            repeatForever: true,
            displayFullTextOnTap: true,
            animatedTexts: [
              TypewriterAnimatedText(aboutMe),
              TypewriterAnimatedText(
                'Let\'s create smooth, powerful experiences! 🚀',
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),


                  const SizedBox(height: 30),
                  ContactSection(key: navbarkeys[4]),
                  const SizedBox(height: 30),
                  const Footer(),
                ],
              ),
            ),
          ),
          floatingActionButton: AnimatedBuilder(
            animation: bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, bounceAnimation.value),
                child: FloatingActionButton(
                  elevation: 30,
                  foregroundColor: Colors.white,
                  backgroundColor: CustomColor.scaffoldBg,
                  onPressed: () => scrollToSection(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  mini: isDesktop ? false : true,
                  child: Transform.rotate(
                    angle: -math.pi / 2, // Point upwards
                    child: const Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
