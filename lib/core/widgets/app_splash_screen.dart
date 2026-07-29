import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../constants/app_assets.dart';
import '../constants/app_sizes.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.65, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.84, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _contentOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );

    _entranceController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: 'Digital Teachers',
                  image: true,
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _entranceController,
                        _pulseController,
                      ]),
                      builder: (context, child) {
                        final pulse = Curves.easeInOut.transform(
                          _pulseController.value,
                        );

                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, -3 * pulse),
                            child: Transform.scale(
                              scale: _logoScale.value * (1 + (0.025 * pulse)),
                              child: Container(
                                width: 192,
                                height: 192,
                                padding: const EdgeInsets.all(
                                  AppSizes.spacing8,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.12 + (0.08 * pulse),
                                      ),
                                      blurRadius: 24 + (8 * pulse),
                                      spreadRadius: 2 + (2 * pulse),
                                    ),
                                  ],
                                ),
                                child: ClipOval(child: child),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _contentOpacity,
                  child: const Column(
                    children: [
                      SizedBox(height: AppSizes.spacing24),
                      Text(
                        'គ្រូបង្រៀនឌីជីថល',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
