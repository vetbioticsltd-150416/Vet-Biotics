import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Responsive layout widget that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({super.key, required this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (themeProvider.isDesktop(context)) {
        return desktop ?? tablet ?? mobile;
      } else if (themeProvider.isTablet(context)) {
        return tablet ?? mobile;
      } else {
        return mobile;
      }
    },
  );
}

/// Responsive container that centers content with max width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveContainer({super.key, required this.child, this.padding, this.maxWidth, this.centerContent = true});

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      var responsivePadding = padding ?? themeProvider.getResponsivePadding(context);
      var responsiveMaxWidth = maxWidth ?? themeProvider.getResponsiveMaxWidth(context);

      return Container(
        width: double.infinity,
        padding: responsivePadding,
        child: centerContent
            ? Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
                  child: this.child,
                ),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
                child: this.child,
              ),
      );
    },
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(DoubleProperty('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty<bool>('centerContent', centerContent));
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.padding,
    this.childAspectRatio,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      var crossAxisCount = themeProvider.getResponsiveGridCount(context);

      return GridView.count(
        padding: padding,
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? (crossAxisCount == 1 ? 3.0 : 1.0),
        crossAxisSpacing: crossAxisSpacing!,
        mainAxisSpacing: mainAxisSpacing!,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
    },
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(DoubleProperty('childAspectRatio', childAspectRatio));
    properties.add(DoubleProperty('crossAxisSpacing', crossAxisSpacing));
    properties.add(DoubleProperty('mainAxisSpacing', mainAxisSpacing));
  }
}

/// Responsive scaffold with adaptive app bar
class ResponsiveScaffold extends StatelessWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const ResponsiveScaffold({
    super.key,
    this.title,
    this.actions,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      var isDesktop = themeProvider.isDesktop(context);

      if (isDesktop) {
        return Scaffold(
          body: Row(
            children: [
              // Desktop sidebar can be added here
              Expanded(
                child: Column(
                  children: [
                    if (showAppBar)
                      Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                        ),
                        child: Row(
                          children: [if (title != null) title!, const Spacer(), if (actions != null) ...actions!],
                        ),
                      ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: floatingActionButton,
        );
      } else {
        return Scaffold(
          appBar: showAppBar ? AppBar(title: title, actions: actions) : null,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        );
      }
    },
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showAppBar', showAppBar));
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      EdgeInsetsGeometry padding;

      if (themeProvider.isDesktop(context)) {
        padding = desktopPadding ?? tabletPadding ?? mobilePadding ?? const EdgeInsets.all(24);
      } else if (themeProvider.isTablet(context)) {
        padding = tabletPadding ?? mobilePadding ?? const EdgeInsets.all(20);
      } else {
        padding = mobilePadding ?? const EdgeInsets.all(16);
      }

      return Padding(padding: padding, child: this.child);
    },
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('mobilePadding', mobilePadding));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('tabletPadding', tabletPadding));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('desktopPadding', desktopPadding));
  }
}

/// Responsive text scaling
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const ResponsiveText(this.text, {super.key, this.style, this.textAlign, this.maxLines});

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      double scale = 1;

      if (themeProvider.isDesktop(context)) {
        scale = 1.2;
      } else if (themeProvider.isTablet(context)) {
        scale = 1.1;
      }

      var scaledStyle = style?.copyWith(fontSize: (style?.fontSize ?? 14.0) * scale);

      return Text(text, style: scaledStyle, textAlign: textAlign, maxLines: maxLines);
    },
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(DiagnosticsProperty<TextStyle?>('style', style));
    properties.add(EnumProperty<TextAlign?>('textAlign', textAlign));
    properties.add(IntProperty('maxLines', maxLines));
  }
}
