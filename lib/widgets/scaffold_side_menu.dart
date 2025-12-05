import 'package:fisiovision/helpers/theme_helper.dart';
import 'package:fisiovision/widgets/side_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ScaffoldSideMenu extends StatefulWidget {
  final Widget body;
  final String title;
  final String subtitle;
  final String? buttonText;
  final Icon? buttonIcon;
  final VoidCallback? onButtonPressed;

  // Propiedades del Scaffold
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Color? drawerScrimColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  // 👇 CORREGIDO: ESTO DEBE SER double, NO Color
  final double? drawerEdgeDragWidth;

  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  const ScaffoldSideMenu({
    super.key,
    required this.body,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.buttonIcon,
    this.onButtonPressed,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.drawerScrimColor,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  @override
  State<ScaffoldSideMenu> createState() => _ScaffoldSideMenuState();
}

class _ScaffoldSideMenuState extends State<ScaffoldSideMenu> {
  // 👇 CORRECTO: GlobalKey fuera del build
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    const double maxBodyWidth = 1500;

    // Mostrar botón sólo si tiene texto y función
    final bool shouldShowButton =
        widget.buttonText != null &&
            widget.buttonText!.isNotEmpty &&
            widget.onButtonPressed != null;

    Widget? actionButton = shouldShowButton
        ? ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 250,
      ),
      child: ButtonActionMain(
        text: widget.buttonText!,
        icon: widget.buttonIcon,
        onPressed: widget.onButtonPressed!,
      ),
    )
        : null;

    // HEADER (Título + Subtítulo + Botón)
    final headerWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (actionButton != null) const SizedBox(width: 16),
              if (actionButton != null) actionButton,
            ],
          ),

          const SizedBox(height: 4),

          Text(
            widget.subtitle,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      key: scaffoldKey,

      // 👇 SI enviaron drawer desde afuera, úsalo
      // En caso contrario, usa SideMenu
      drawer: widget.drawer ?? SideMenu(scaffoldKey: scaffoldKey),

      // APPBAR con botón para abrir el drawer
      appBar: AppBar(
        backgroundColor: adaptiveBackgroundColor(context),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Icon(Icons.health_and_safety, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'FisioVision',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),

      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: maxBodyWidth,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerWidget,
                    widget.body,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      persistentFooterButtons: widget.persistentFooterButtons,
      onDrawerChanged: widget.onDrawerChanged,
      endDrawer: widget.endDrawer,
      onEndDrawerChanged: widget.onEndDrawerChanged,
      drawerScrimColor: widget.drawerScrimColor,

      backgroundColor: !isDarkMode ? Colors.white : colorScheme.surface,

      bottomNavigationBar: widget.bottomNavigationBar,
      bottomSheet: widget.bottomSheet,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      primary: widget.primary,
      drawerDragStartBehavior: widget.drawerDragStartBehavior,

      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,

      drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,

      restorationId: widget.restorationId,
    );
  }
}


// ---------------------------------------------
// Botón de acción (tal como lo tenías)
// ---------------------------------------------
class ButtonActionMain extends StatelessWidget {
  final String text;
  final Icon? icon;
  final VoidCallback onPressed;

  const ButtonActionMain({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon ?? const Icon(Icons.add),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(45),
      ),
    );
  }
}
    