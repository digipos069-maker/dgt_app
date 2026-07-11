import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppAssets.logo,
        width: 104,
        height: 104,
        fit: BoxFit.contain,
      ),
    );
  }
}
