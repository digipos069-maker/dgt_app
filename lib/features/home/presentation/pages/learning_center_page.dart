import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/presentation/widgets/language_menu_button.dart';
import '../../../auth/presentation/widgets/theme_toggle_button.dart';
import 'grade_list_page.dart';
import '../widgets/learning_center_body.dart';
import '../widgets/main_bottom_navigation.dart';

class LearningCenterPage extends StatelessWidget {
  const LearningCenterPage({this.gradeId, this.gradeNumber, super.key});

  static const routeName = 'learning-center';
  static const routePath = '/learning-center';

  final int? gradeId;
  final int? gradeNumber;

  @override
  Widget build(BuildContext context) {
    return ScrollHidingHeaderScaffold(
      header: AppBar(
        leading: gradeId == null
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.goNamed(GradeListPage.routeName),
                icon: const Icon(Icons.arrow_back),
              ),
        title: Text(context.l10n.text('menuLearningCenter')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: LearningCenterBody(gradeId: gradeId, gradeNumber: gradeNumber),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}
