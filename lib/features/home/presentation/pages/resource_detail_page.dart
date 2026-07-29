import 'package:flutter/material.dart';

import '../../domain/models/resource_document_model.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/resource_detail_body.dart';

class ResourceDetailPage extends StatelessWidget {
  const ResourceDetailPage({required this.document, super.key});

  final ResourceDocumentModel document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResourceDetailBody(document: document),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 4),
    );
  }
}
