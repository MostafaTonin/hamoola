import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Builder widget that renders different layouts based on current breakpoint.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) compact;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isExpanded(context) && expanded != null) {
      return expanded!(context);
    }
    if (AppBreakpoints.isMedium(context) && medium != null) {
      return medium!(context);
    }
    return compact(context);
  }
}

/// Adaptive container that centers and constrains width on Web and Desktop screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
