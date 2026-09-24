import 'package:flutter/material.dart';

import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/resource_body.dart';

class ResourcePage extends StatelessWidget {
  const ResourcePage({super.key});

  static const routeName = 'resource';
  static const routePath = '/resource';

  @override
  Widget build(BuildContext context) {
    return ScrollHidingHeaderScaffold(
      header: AppBar(title: Text(context.l10n.text('menuResource'))),
      body: const ResourceBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 4),
    );
  }
}
