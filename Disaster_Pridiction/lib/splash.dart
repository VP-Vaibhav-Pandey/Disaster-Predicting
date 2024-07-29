import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app2/pages/set.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      splash: LottieBuilder.asset("assets/Lottie/animation.json"),
      nextScreen: const Set(),
      splashIconSize: 450,
      backgroundColor: Colors.grey.shade200,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
