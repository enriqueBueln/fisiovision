import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/legacy.dart';
import '../config/menu_items.dart';

// --- PROVIDERS ---
final selectedMenuItemLinkProvider = StateProvider<String?>(
  (ref) => null,
);

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, bool>(
      (ref) => ThemeNotifier(false),
    );

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier(bool isDarkMode) : super(isDarkMode);

  void toggleTheme() => state = !state;

  void setDarkMode(bool value) => state = value;
}

// ---- BOTÓN ----
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
      icon: icon ?? const Icon(Icons.arrow_forward),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
    );
  }
}

// ==============================
//     SIDE MENU CORREGIDO
// ==============================
class SideMenu extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final isDarkMode = ref.watch(themeNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // --- Determinar la ruta actual ---
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedLink = ref.watch(selectedMenuItemLinkProvider);

    // 🔥 CORRECCIÓN IMPORTANTE:
    // Solo actualiza si es necesario para evitar bucles de reconstrucción
    if (appMenuItems.any((item) => item.link == currentPath) &&
        selectedLink != currentPath) {
      Future.microtask(() {
        ref.read(selectedMenuItemLinkProvider.notifier).state =
            currentPath;
      });
    }

    final selectedIndex = appMenuItems.indexWhere(
      (item) => item.link == selectedLink,
    );

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- Header ----
            Padding(
              padding: EdgeInsets.fromLTRB(
                28,
                hasNotch ? 0 : 20,
                16,
                10,
              ),
              child: Row(
                children: [
                  Icon(Icons.build, color: colorScheme.primary),
                  const SizedBox(width: 15),
                  Text(
                    'FisioVision',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ---- Items del menú (NavigationDrawer adaptado a ListTiles) ----
            ...List.generate(appMenuItems.length, (index) {
              final item = appMenuItems[index];
              final isSelected = index == selectedIndex;

              return Material(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.12)
                    : Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.8),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    ref
                        .read(
                          selectedMenuItemLinkProvider.notifier,
                        )
                        .state = item
                        .link;
                    context.go(item.link);
                    scaffoldKey.currentState?.closeDrawer();
                  },
                ),
              );
            }),

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              child: Divider(),
            ),

            // ---- Cambiar Tema ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
              child: ListTile(
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .toggleTheme();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(
                  isDarkMode
                      ? Icons.wb_sunny_outlined
                      : Icons.dark_mode_outlined,
                  color: isDarkMode ? Colors.amber : Colors.indigo,
                ),
                title: Text(
                  isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
                ),
                trailing: Switch(
                  value: isDarkMode,
                  activeColor: Colors.amber,
                  onChanged: (value) {
                    ref
                        .read(themeNotifierProvider.notifier)
                        .setDarkMode(value);
                  },
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              child: Divider(),
            ),

            // ---- Cerrar Sesión ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
              child: ButtonActionMain(
                text: 'Cerrar Sesión',
                onPressed: () {
                  context.go('/');
                },
                icon: Icon(
                  Icons.logout,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
