import 'package:flutter/material.dart';

class ScrollHidingHeader extends StatefulWidget {
  const ScrollHidingHeader({
    required this.header,
    required this.child,
    this.headerHeight = kToolbarHeight,
    super.key,
  });

  final Widget header;
  final Widget child;
  final double headerHeight;

  @override
  State<ScrollHidingHeader> createState() => _ScrollHidingHeaderState();
}

class _ScrollHidingHeaderState extends State<ScrollHidingHeader> {
  bool _isHeaderVisible = true;

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.pixels <= 0) {
      _setHeaderVisible(true);
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 4) {
        _setHeaderVisible(false);
      } else if (delta < -4) {
        _setHeaderVisible(true);
      }
    }

    return false;
  }

  void _setHeaderVisible(bool visible) {
    if (_isHeaderVisible == visible || !mounted) {
      return;
    }
    setState(() => _isHeaderVisible = visible);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: _isHeaderVisible ? widget.headerHeight : 0,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _isHeaderVisible ? 1 : 0,
              child: SizedBox(
                height: widget.headerHeight,
                child: widget.header,
              ),
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class ScrollHidingHeaderScaffold extends StatelessWidget {
  const ScrollHidingHeaderScaffold({
    required this.header,
    required this.body,
    this.headerHeight = kToolbarHeight,
    this.bottomNavigationBar,
    super.key,
  });

  final Widget header;
  final Widget body;
  final double headerHeight;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ScrollHidingHeader(
          header: header,
          headerHeight: headerHeight,
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
