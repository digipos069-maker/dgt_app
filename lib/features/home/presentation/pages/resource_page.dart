import 'package:flutter/material.dart';

import '../widgets/coming_soon_scaffold.dart';

class ResourcePage extends StatelessWidget {
  const ResourcePage({super.key});

  static const routeName = 'resource';
  static const routePath = '/resource';

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScaffold(titleKey: 'menuResource', selectedIndex: 4);
  }
}
