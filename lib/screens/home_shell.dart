import 'package:flutter/material.dart';

import '../data/business_store.dart';
import '../theme/motora_theme.dart';
import 'cars_view.dart';
import 'management_view.dart';
import 'operations_view.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.store,
    required this.selectedThemeIndex,
    required this.onThemeChanged,
    super.key,
  });

  final BusinessStore store;
  final int selectedThemeIndex;
  final ValueChanged<int> onThemeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _pageIndex = 0;
  int _operationIndex = 0;

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showThemes() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ThemeGallery(
        selectedIndex: widget.selectedThemeIndex,
        onSelected: (index) {
          widget.onThemeChanged(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openOperation(int index) {
    setState(() {
      _operationIndex = index;
      _pageIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spec = motoraThemes[widget.selectedThemeIndex];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _TopBar(
              store: widget.store,
              themeSpec: spec,
              onThemesPressed: _showThemes,
            ),
            Expanded(
              child: IndexedStack(
                index: _pageIndex,
                children: <Widget>[
                  HomeView(
                    store: widget.store,
                    onOpenCars: () => setState(() => _pageIndex = 1),
                    onOpenOperation: _openOperation,
                  ),
                  CarsView(store: widget.store, onMessage: _notify),
                  OperationsView(
                    store: widget.store,
                    selectedIndex: _operationIndex,
                    onSelected: (index) =>
                        setState(() => _operationIndex = index),
                    onMessage: _notify,
                  ),
                  ManagementView(
                    store: widget.store,
                    onThemesPressed: _showThemes,
                    onMessage: _notify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: (value) => setState(() => _pageIndex = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car_filled_rounded),
            label: 'السيارات',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'الحسابات',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps_rounded),
            label: 'الإدارة',
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.store,
    required this.themeSpec,
    required this.onThemesPressed,
  });

  final BusinessStore store;
  final MotoraThemeSpec themeSpec;
  final VoidCallback onThemesPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: ShapeDecoration(
                color: colors.primary,
                shape: themeSpec.buttonShape,
              ),
              alignment: Alignment.center,
              child: Text(
                'ز',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    store.settings['showroomName'] ?? 'زيد للسيارات',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'إدارة المعرض والعقود',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const Key('theme-picker-button'),
              onPressed: onThemesPressed,
              tooltip: 'المظهر: ${themeSpec.name}',
              icon: Icon(themeSpec.icon, size: 21),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({
    required this.store,
    required this.onOpenCars,
    required this.onOpenOperation,
    super.key,
  });

  final BusinessStore store;
  final VoidCallback onOpenCars;
  final ValueChanged<int> onOpenOperation;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final tokens = Theme.of(context).extension<MotoraTokens>()!;
      return ListView(
        key: const PageStorageKey<String>('home'),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: <Widget>[
          _HeroPanel(store: store, onOpenCars: onOpenCars),
          SizedBox(height: tokens.compact ? 18 : 24),
          const AppSectionTitle(
            title: 'إدارة المعرض',
            subtitle: 'كل عملية تفتح شاشة حقيقية وتحفظ على الهاتف',
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 11.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  QuickActionCard(
                    width: width,
                    icon: Icons.sell_outlined,
                    label: 'بيع سيارة',
                    caption: 'سجّل البيع والدفعة والدين',
                    onTap: () => onOpenOperation(0),
                  ),
                  QuickActionCard(
                    width: width,
                    icon: Icons.shopping_cart_outlined,
                    label: 'شراء سيارة',
                    caption: 'أضفها تلقائياً إلى المخزون',
                    onTap: () => onOpenOperation(1),
                  ),
                  QuickActionCard(
                    width: width,
                    icon: Icons.receipt_long_outlined,
                    label: 'الديون',
                    caption: 'الأقساط والمتبقي والاستحقاق',
                    onTap: () => onOpenOperation(2),
                  ),
                  QuickActionCard(
                    width: width,
                    icon: Icons.note_add_outlined,
                    label: 'إنشاء عقد',
                    caption: 'احفظ وعاين وانسخ العقد',
                    onTap: () => onOpenOperation(3),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: tokens.compact ? 18 : 24),
          const AppSectionTitle(
            title: 'ملخص حقيقي',
            subtitle: 'الأرقام محسوبة من السجلات المحفوظة',
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: MiniStat(
                  label: 'المخزون',
                  value:
                      '${store.vehicles.where((v) => v['status'] != 'مباعة').length}',
                  icon: Icons.directions_car_filled_outlined,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: MiniStat(
                  label: 'المبيعات',
                  value: '${store.sales.length}',
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: MiniStat(
                  label: 'الديون',
                  value: '${store.debts.length}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          SummaryCard(
            icon: Icons.account_balance_outlined,
            title: 'رصيد الصندوق التقديري',
            amount: BusinessStore.formatAmount(store.cashBalance),
            caption: 'المقبوضات ناقص المشتريات والمصاريف',
          ),
        ],
      );
    },
  );
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.store, required this.onOpenCars});

  final BusinessStore store;
  final VoidCallback onOpenCars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tokens = theme.extension<MotoraTokens>()!;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 270),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.heroRadius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: tokens.gradient,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tokens.glow,
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: -16,
            bottom: -8,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 155,
              color: colors.onPrimary.withValues(alpha: .14),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.compact ? 20 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'الإصدار التشغيلي ٣٧',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'إدارة معرضك\nتبدأ من هنا',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colors.onPrimary,
                    fontSize: tokens.compact ? 29 : 33,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${store.vehicles.length} سيارة • ${store.sales.length} مبيعة • ${store.contracts.length} عقد',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: .88),
                  ),
                ),
                const SizedBox(height: 17),
                FilledButton.tonalIcon(
                  onPressed: onOpenCars,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('إدارة السيارات'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.onPrimary,
                    foregroundColor: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
    super.key,
  });

  final double width;
  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 21, color: colors.primary),
                ),
                const SizedBox(height: 9),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: <Widget>[
            Icon(icon, color: colors.primary),
            const SizedBox(height: 5),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.icon,
    required this.title,
    required this.amount,
    required this.caption,
    super.key,
  });

  final IconData icon;
  final String title;
  final String amount;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: colors.primary),
                  ),
                  Text(
                    caption,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(
          Theme.of(context).extension<MotoraTokens>()!.cardRadius,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

Future<bool> confirmDelete(BuildContext context, String title) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف $title؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    ) ??
    false;

class ThemeGallery extends StatelessWidget {
  const ThemeGallery({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 14 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'اختر مظهر التطبيق',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text('١٠ ثيمات تغيّر الألوان والخطوط والبطاقات والأزرار'),
            const SizedBox(height: 15),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 96,
                ),
                itemCount: motoraThemes.length,
                itemBuilder: (context, index) {
                  final item = motoraThemes[index];
                  final selected = index == selectedIndex;
                  return InkWell(
                    key: Key('theme-option-$index'),
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: <Color>[item.primary, item.secondary],
                        ),
                        border: Border.all(
                          color: selected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: <Widget>[
                          Icon(item.icon, color: Colors.white, size: 25),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: item.fontFamily,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  item.tagline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: item.fontFamily,
                                    color: Colors.white.withValues(alpha: .82),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
