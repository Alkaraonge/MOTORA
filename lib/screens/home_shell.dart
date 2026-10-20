import 'package:flutter/material.dart';

import '../data/business_store.dart';
import '../models/motora_data.dart';
import '../theme/motora_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final spec = motoraThemes[widget.selectedThemeIndex];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _TopBar(themeSpec: spec, onThemesPressed: _showThemes),
            Expanded(
              child: IndexedStack(
                index: _pageIndex,
                children: <Widget>[
                  HomeView(
                    onOpenCars: () => setState(() => _pageIndex = 1),
                    onOpenOperation: (index) => setState(() {
                      _operationIndex = index;
                      _pageIndex = 2;
                    }),
                    onAction: _notify,
                  ),
                  CarsView(onAction: _notify),
                  OperationsView(
                    store: widget.store,
                    selectedIndex: _operationIndex,
                    onSelected: (index) =>
                        setState(() => _operationIndex = index),
                    onAction: _notify,
                  ),
                  SettingsView(onThemesPressed: _showThemes, onAction: _notify),
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
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.themeSpec, required this.onThemesPressed});

  final MotoraThemeSpec themeSpec;
  final VoidCallback onThemesPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
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
                  'زيد للسيارات',
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
          Semantics(
            button: true,
            label: 'اختيار المظهر',
            child: IconButton.filledTonal(
              key: const Key('theme-picker-button'),
              onPressed: onThemesPressed,
              tooltip: 'المظهر: ${themeSpec.name}',
              icon: Icon(themeSpec.icon, size: 21),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({
    required this.onOpenCars,
    required this.onOpenOperation,
    required this.onAction,
    super.key,
  });

  final VoidCallback onOpenCars;
  final ValueChanged<int> onOpenOperation;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<MotoraTokens>()!;
    return SingleChildScrollView(
      key: const PageStorageKey<String>('home'),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _HeroPanel(onOpenCars: onOpenCars),
          SizedBox(height: tokens.compact ? 18 : 24),
          const SectionTitle(
            title: 'إدارة المعرض',
            subtitle: 'كل عملياتك اليومية في مكان واحد',
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 11.0;
              final itemWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  _QuickAction(
                    width: itemWidth,
                    icon: Icons.sell_outlined,
                    label: 'بيع سيارة',
                    caption: 'سجّل عملية البيع',
                    onTap: () => onOpenOperation(0),
                  ),
                  _QuickAction(
                    width: itemWidth,
                    icon: Icons.shopping_cart_outlined,
                    label: 'شراء سيارة',
                    caption: 'أضفها إلى المخزون',
                    onTap: () => onOpenOperation(1),
                  ),
                  _QuickAction(
                    width: itemWidth,
                    icon: Icons.receipt_long_outlined,
                    label: 'الديون',
                    caption: 'المبالغ والأقساط',
                    onTap: () => onOpenOperation(2),
                  ),
                  _QuickAction(
                    width: itemWidth,
                    icon: Icons.note_add_outlined,
                    label: 'إنشاء عقد',
                    caption: 'عقد بيع جاهز للطباعة',
                    onTap: () => onOpenOperation(3),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: tokens.compact ? 18 : 24),
          SectionTitle(
            title: 'آخر السيارات',
            subtitle: 'المخزون المضاف حديثاً',
            action: 'عرض الكل',
            onAction: onOpenCars,
          ),
          const SizedBox(height: 13),
          _FeaturedVehicle(vehicle: vehicles.first, onTap: onOpenCars),
          const SizedBox(height: 18),
          const _StatusStrip(),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.onOpenCars});

  final VoidCallback onOpenCars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tokens = theme.extension<MotoraTokens>()!;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
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
            left: -54,
            top: -64,
            child: _GlowOrb(
              size: 190,
              color: colors.onPrimary.withValues(alpha: .09),
            ),
          ),
          Positioned(
            left: 12,
            bottom: -8,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 150,
              color: colors.onPrimary.withValues(alpha: .15),
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
                    'نظام زيد  •  الإصدار ٣٦',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'إدارة معرضك\nتبدأ من هنا',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colors.onPrimary,
                    fontSize: tokens.compact ? 30 : 34,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'السيارات والمبيعات والعقود في مكان واحد',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: .86),
                  ),
                ),
                const SizedBox(height: 18),
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: color.withValues(alpha: .7), width: 18),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.width,
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
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
      height: 164,
      child: Card(
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
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
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

class SectionTitle extends StatelessWidget {
  const SectionTitle({
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

class _FeaturedVehicle extends StatelessWidget {
  const _FeaturedVehicle({required this.vehicle, required this.onTap});
  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      vehicle.status,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${vehicle.category} • ${vehicle.year}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle.price,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .11),
                  shape: BoxShape.circle,
                ),
                child: Icon(vehicle.icon, size: 60, color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(
          Theme.of(context).extension<MotoraTokens>()!.cardRadius,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.inventory_2_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('حالة المخزون اليوم'),
                const SizedBox(height: 3),
                Text(
                  '٣ سيارات • عقدان',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
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

class CarsView extends StatefulWidget {
  const CarsView({required this.onAction, super.key});
  final ValueChanged<String> onAction;

  @override
  State<CarsView> createState() => _CarsViewState();
}

class _CarsViewState extends State<CarsView> {
  int selectedFilter = 0;
  final filters = const <String>['الكل', 'متاحة', 'محجوزة', 'مباعة'];

  Future<void> _addVehicle() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddVehicleSheet(),
    );
    if (added == true) widget.onAction('تم حفظ السيارة في المخزون');
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('cars'),
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionTitle(
                  title: 'مخزون السيارات',
                  subtitle: '٣ سيارات مسجلة في المعرض',
                  action: 'إضافة',
                  onAction: _addVehicle,
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List<Widget>.generate(
                      filters.length,
                      (index) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(filters[index]),
                          selected: selectedFilter == index,
                          onSelected: (_) =>
                              setState(() => selectedFilter = index),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          sliver: SliverList.separated(
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 13),
            itemBuilder: (context, index) => _VehicleCard(
              vehicle: vehicles[index],
              index: index,
              onAction: widget.onAction,
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.index,
    required this.onAction,
  });

  final Vehicle vehicle;
  final int index;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<MotoraTokens>()!;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.compact ? 16 : 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 128,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  (tokens.cardRadius - 3).clamp(2, 40),
                ),
                gradient: LinearGradient(
                  colors: <Color>[
                    colors.primary.withValues(alpha: .20),
                    colors.secondary.withValues(alpha: .05),
                  ],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Text(
                      'ZC-${(index + 1).toString().padLeft(3, '0')}',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: colors.primary.withValues(alpha: .55),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(vehicle.icon, size: 94, color: colors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        vehicle.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${vehicle.category} • ${vehicle.year}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(vehicle.status)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vehicle.price,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => onAction('تم فتح بيانات ${vehicle.name}'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('تعديل البيانات'),
                  ),
                ),
                const SizedBox(width: 9),
                IconButton.filledTonal(
                  onPressed: () => onAction('تمت مشاركة ${vehicle.name}'),
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVehicleSheet extends StatelessWidget {
  const _AddVehicleSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'إضافة سيارة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                labelText: 'الشركة والطراز',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
            ),
            const SizedBox(height: 11),
            const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'سنة الصنع'),
                  ),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'اللون'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السعر بالدينار العراقي',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.save_outlined),
              label: const Text('حفظ السيارة'),
            ),
          ],
        ),
      ),
    );
  }
}

class OperationsView extends StatelessWidget {
  const OperationsView({
    required this.store,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAction,
    super.key,
  });

  final BusinessStore store;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<String> onAction;

  static const _sections = <(String, IconData)>[
    ('المبيعات', Icons.sell_outlined),
    ('المشتريات', Icons.shopping_cart_outlined),
    ('الديون', Icons.receipt_long_outlined),
    ('العقود', Icons.description_outlined),
  ];

  Future<void> _openRecord(
    BuildContext context,
    Widget sheet,
    String message,
    Future<void> Function(Map<String, String>) save,
  ) async {
    final record = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => sheet,
    );
    if (record == null) return;
    await save(record);
    onAction(message);
  }

  Future<void> _openContract(BuildContext context) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ContractSheet(),
    );
    if (saved == true) onAction('تم إنشاء عقد البيع وحفظه');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
        key: const PageStorageKey<String>('operations'),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: <Widget>[
          const SectionTitle(
            title: 'الحسابات والعمليات',
            subtitle: 'البيع والشراء والديون والعقود',
          ),
          const SizedBox(height: 13),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(
                _sections.length,
                (index) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    avatar: Icon(_sections[index].$2, size: 18),
                    label: Text(_sections[index].$1),
                    selected: selectedIndex == index,
                    onSelected: (_) => onSelected(index),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 17),
          switch (selectedIndex) {
            0 => _SalesSection(
              store: store,
              onAdd: () => _openRecord(
                context,
                const _SaleSheet(),
                'تم تسجيل عملية البيع وتحديث حساب العميل',
                store.addSale,
              ),
              onAction: onAction,
            ),
            1 => _PurchasesSection(
              store: store,
              onAdd: () => _openRecord(
                context,
                const _PurchaseSheet(),
                'تم تسجيل عملية الشراء وإضافة السيارة للمخزون',
                store.addPurchase,
              ),
              onAction: onAction,
            ),
            2 => _DebtsSection(
              store: store,
              onAdd: () => _openRecord(
                context,
                const _DebtSheet(),
                'تم حفظ الدين وجدول الدفعات',
                store.addDebt,
              ),
              onAction: onAction,
            ),
            _ => _ContractsSection(
              onAdd: () => _openContract(context),
              onAction: onAction,
            ),
          },
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.amount,
    required this.caption,
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
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: 13),
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

class _SalesSection extends StatelessWidget {
  const _SalesSection({
    required this.store,
    required this.onAdd,
    required this.onAction,
  });
  final BusinessStore store;
  final VoidCallback onAdd;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      _SummaryCard(
        icon: Icons.trending_up_rounded,
        title: 'إجمالي المبيعات',
        amount: BusinessStore.formatAmount(store.salesTotal),
        caption: '${store.sales.length} عملية محفوظة محلياً',
      ),
      const SizedBox(height: 13),
      if (store.sales.isEmpty)
        const _EmptyRecordCard(message: 'لا توجد مبيعات مسجلة بعد')
      else
        _OperationCard(
          icon: Icons.directions_car_filled_rounded,
          title: store.sales.first['car'] ?? 'سيارة',
          subtitle: 'المشتري: ${store.sales.first['customer'] ?? 'غير محدد'}',
          amount:
              '${store.sales.first['price'] ?? '0'} ${store.sales.first['currency'] ?? ''}',
          status: 'المستلم: ${store.sales.first['received'] ?? '0'}',
          onTap: () => onAction('تم فتح تفاصيل البيع والدفعات'),
        ),
      const SizedBox(height: 13),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded),
        label: const Text('تسجيل بيع سيارة'),
      ),
    ],
  );
}

class _PurchasesSection extends StatelessWidget {
  const _PurchasesSection({
    required this.store,
    required this.onAdd,
    required this.onAction,
  });
  final BusinessStore store;
  final VoidCallback onAdd;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      _SummaryCard(
        icon: Icons.inventory_2_outlined,
        title: 'قيمة المشتريات',
        amount: BusinessStore.formatAmount(store.purchasesTotal),
        caption: '${store.purchases.length} سيارة مشتراة ومحفوظة محلياً',
      ),
      const SizedBox(height: 13),
      if (store.purchases.isEmpty)
        const _EmptyRecordCard(message: 'لا توجد مشتريات مسجلة بعد')
      else
        _OperationCard(
          icon: Icons.shopping_bag_outlined,
          title:
              '${store.purchases.first['maker'] ?? ''} ${store.purchases.first['model'] ?? ''}',
          subtitle:
              'المورد: ${store.purchases.first['supplier'] ?? 'غير محدد'}',
          amount:
              '${store.purchases.first['price'] ?? '0'} ${store.purchases.first['currency'] ?? ''}',
          status: 'الشاصي: ${store.purchases.first['chassis'] ?? 'غير مسجل'}',
          onTap: () => onAction('تم فتح تفاصيل الشراء والمورد'),
        ),
      const SizedBox(height: 13),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('تسجيل شراء سيارة'),
      ),
    ],
  );
}

class _DebtsSection extends StatelessWidget {
  const _DebtsSection({
    required this.store,
    required this.onAdd,
    required this.onAction,
  });
  final BusinessStore store;
  final VoidCallback onAdd;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      _SummaryCard(
        icon: Icons.account_balance_wallet_outlined,
        title: 'الديون المتبقية',
        amount: BusinessStore.formatAmount(store.debtsRemaining),
        caption: '${store.debts.length} حساب دين محفوظ محلياً',
      ),
      const SizedBox(height: 13),
      if (store.debts.isEmpty)
        const _EmptyRecordCard(message: 'لا توجد ديون مسجلة بعد')
      else
        _OperationCard(
          icon: Icons.person_outline_rounded,
          title: store.debts.first['person'] ?? 'حساب دين',
          subtitle:
              '${store.debts.first['type'] ?? ''} • الاستحقاق ${store.debts.first['due'] ?? 'غير محدد'}',
          amount: BusinessStore.formatAmount(
            (BusinessStore.parseAmount(store.debts.first['total']) -
                    BusinessStore.parseAmount(store.debts.first['paid']))
                .clamp(0, 1 << 62),
          ),
          status: 'المدفوع: ${store.debts.first['paid'] ?? '0'}',
          onTap: () => onAction('تم فتح كشف الدين والدفعات'),
        ),
      const SizedBox(height: 13),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.post_add_rounded),
        label: const Text('إضافة دين أو دفعة'),
      ),
    ],
  );
}

class _EmptyRecordCard extends StatelessWidget {
  const _EmptyRecordCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(
          Theme.of(context).extension<MotoraTokens>()!.cardRadius,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.inbox_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ContractsSection extends StatelessWidget {
  const _ContractsSection({required this.onAdd, required this.onAction});
  final VoidCallback onAdd;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    Icons.draw_outlined,
                    color: colors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'مصمم عقود زيد',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '٢٠ نموذجاً وحقول العقد الأصلي كاملة',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        ...contracts.map(
          (contract) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ContractCard(contract: contract, onAction: onAction),
          ),
        ),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('إنشاء عقد بيع جديد'),
        ),
      ],
    );
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Icon(icon, color: colors.primary, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        trailing: Text(
          amount,
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.contract, required this.onAction});
  final SaleContract contract;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.description_rounded, color: colors.primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    contract.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  contract.date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 24),
            _ContractLine(label: 'المشتري', value: contract.buyer),
            _ContractLine(label: 'السيارة', value: contract.vehicle),
            _ContractLine(label: 'المبلغ', value: contract.amount),
            const SizedBox(height: 11),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onAction('تم فتح معاينة العقد'),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('معاينة'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => onAction('العقد جاهز للطباعة'),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('طباعة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractLine extends StatelessWidget {
  const _ContractLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _SaleSheet extends StatefulWidget {
  const _SaleSheet();

  @override
  State<_SaleSheet> createState() => _SaleSheetState();
}

class _SaleSheetState extends State<_SaleSheet> {
  String car = vehicles.first.name;
  String currency = 'دينار عراقي';
  String method = 'نقداً';
  final customer = TextEditingController();
  final phone = TextEditingController();
  final price = TextEditingController();
  final received = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    customer.dispose();
    phone.dispose();
    price.dispose();
    received.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _BusinessSheet(
    title: 'تسجيل عملية بيع',
    subtitle: 'تفاصيل البيع والعميل والمبلغ المستلم والمتبقي',
    saveLabel: 'حفظ عملية البيع',
    onSave: () => Navigator.pop(context, <String, String>{
      'car': car,
      'customer': customer.text.trim(),
      'phone': phone.text.trim(),
      'price': price.text.trim(),
      'received': received.text.trim(),
      'currency': currency,
      'method': method,
      'notes': notes.text.trim(),
      'date': DateTime.now().toIso8601String(),
    }),
    children: <Widget>[
      DropdownButtonFormField<String>(
        initialValue: car,
        decoration: const InputDecoration(
          labelText: 'السيارة المباعة',
          prefixIcon: Icon(Icons.directions_car_outlined),
        ),
        items: vehicles
            .map(
              (vehicle) => DropdownMenuItem(
                value: vehicle.name,
                child: Text(vehicle.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => car = value ?? car),
      ),
      TextField(
        controller: customer,
        decoration: const InputDecoration(
          labelText: 'اسم المشتري',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      TextField(
        controller: phone,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'هاتف المشتري',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
      ),
      TextField(
        controller: price,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'سعر البيع'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: received,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ المستلم'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: currency,
              decoration: const InputDecoration(labelText: 'العملة'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: 'دينار عراقي',
                  child: Text('دينار عراقي'),
                ),
                DropdownMenuItem(value: 'دولار', child: Text('دولار')),
              ],
              onChanged: (value) =>
                  setState(() => currency = value ?? currency),
            ),
          ),
        ],
      ),
      DropdownButtonFormField<String>(
        initialValue: method,
        decoration: const InputDecoration(labelText: 'طريقة الدفع'),
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem(value: 'نقداً', child: Text('نقداً')),
          DropdownMenuItem(value: 'أجل', child: Text('أجل')),
          DropdownMenuItem(value: 'نقداً وأجل', child: Text('نقداً وأجل')),
        ],
        onChanged: (value) => setState(() => method = value ?? method),
      ),
      TextField(
        controller: notes,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'ملاحظات البيع'),
      ),
    ],
  );
}

class _PurchaseSheet extends StatefulWidget {
  const _PurchaseSheet();

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  final maker = TextEditingController();
  final model = TextEditingController();
  final year = TextEditingController();
  final color = TextEditingController();
  final chassis = TextEditingController();
  final engine = TextEditingController();
  final plate = TextEditingController();
  final supplier = TextEditingController();
  final price = TextEditingController();
  final currency = TextEditingController(text: 'دينار عراقي');
  final notes = TextEditingController();

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      maker,
      model,
      year,
      color,
      chassis,
      engine,
      plate,
      supplier,
      price,
      currency,
      notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _BusinessSheet(
    title: 'تسجيل شراء سيارة',
    subtitle: 'حقول السيارة والمورد وسعر الشراء من التطبيق القديم',
    saveLabel: 'حفظ الشراء وإضافة السيارة',
    onSave: () => Navigator.pop(context, <String, String>{
      'maker': maker.text.trim(),
      'model': model.text.trim(),
      'year': year.text.trim(),
      'color': color.text.trim(),
      'chassis': chassis.text.trim(),
      'engine': engine.text.trim(),
      'plate': plate.text.trim(),
      'supplier': supplier.text.trim(),
      'price': price.text.trim(),
      'currency': currency.text.trim(),
      'notes': notes.text.trim(),
      'date': DateTime.now().toIso8601String(),
    }),
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: maker,
              decoration: const InputDecoration(labelText: 'الماركة'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: model,
              decoration: const InputDecoration(labelText: 'الطراز'),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: year,
              decoration: const InputDecoration(labelText: 'سنة الصنع'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: color,
              decoration: const InputDecoration(labelText: 'اللون'),
            ),
          ),
        ],
      ),
      TextField(
        controller: chassis,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          labelText: 'رقم الشاصي VIN',
          prefixIcon: Icon(Icons.numbers_rounded),
        ),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: engine,
              decoration: const InputDecoration(labelText: 'رقم المحرك'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: plate,
              decoration: const InputDecoration(labelText: 'رقم اللوحة'),
            ),
          ),
        ],
      ),
      TextField(
        controller: supplier,
        decoration: const InputDecoration(
          labelText: 'اسم المورد / البائع',
          prefixIcon: Icon(Icons.store_outlined),
        ),
      ),
      TextField(
        controller: price,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'سعر الشراء',
          prefixIcon: Icon(Icons.payments_outlined),
        ),
      ),
      TextField(
        controller: currency,
        decoration: const InputDecoration(labelText: 'عملة الشراء'),
      ),
      TextField(
        controller: notes,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'ملاحظات'),
      ),
    ],
  );
}

class _DebtSheet extends StatefulWidget {
  const _DebtSheet();

  @override
  State<_DebtSheet> createState() => _DebtSheetState();
}

class _DebtSheetState extends State<_DebtSheet> {
  String personType = 'عميل';
  final person = TextEditingController();
  final phone = TextEditingController();
  final total = TextEditingController();
  final paid = TextEditingController();
  final due = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    person.dispose();
    phone.dispose();
    total.dispose();
    paid.dispose();
    due.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _BusinessSheet(
    title: 'إضافة دين أو دفعة',
    subtitle: 'سجل المبلغ والمدفوع والمتبقي وتاريخ الاستحقاق',
    saveLabel: 'حفظ الدين',
    onSave: () => Navigator.pop(context, <String, String>{
      'type': personType,
      'person': person.text.trim(),
      'phone': phone.text.trim(),
      'total': total.text.trim(),
      'paid': paid.text.trim(),
      'due': due.text.trim(),
      'notes': notes.text.trim(),
      'date': DateTime.now().toIso8601String(),
    }),
    children: <Widget>[
      DropdownButtonFormField<String>(
        initialValue: personType,
        decoration: const InputDecoration(
          labelText: 'نوع الحساب',
          prefixIcon: Icon(Icons.swap_horiz_rounded),
        ),
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem(value: 'عميل', child: Text('عميل مدين للمعرض')),
          DropdownMenuItem(value: 'مورد', child: Text('المعرض مدين لمورد')),
          DropdownMenuItem(value: 'دين شخصي', child: Text('دين شخصي')),
        ],
        onChanged: (value) => setState(() => personType = value ?? personType),
      ),
      TextField(
        controller: person,
        decoration: const InputDecoration(
          labelText: 'اسم صاحب الدين',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      TextField(
        controller: phone,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'رقم الهاتف'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: total,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ الكلي'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: paid,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المدفوع'),
            ),
          ),
        ],
      ),
      TextField(
        controller: due,
        decoration: const InputDecoration(
          labelText: 'تاريخ الاستحقاق',
          prefixIcon: Icon(Icons.event_outlined),
        ),
      ),
      TextField(
        controller: notes,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'سبب الدين أو الملاحظات'),
      ),
    ],
  );
}

class _BusinessSheet extends StatelessWidget {
  const _BusinessSheet({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.saveLabel,
    required this.onSave,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String saveLabel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final child in children) ...<Widget>[
              child,
              const SizedBox(height: 11),
            ],
            const SizedBox(height: 3),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined),
              label: Text(saveLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractSheet extends StatefulWidget {
  const _ContractSheet();

  @override
  State<_ContractSheet> createState() => _ContractSheetState();
}

class _ContractSheetState extends State<_ContractSheet> {
  bool paidInFull = true;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'عقد بيع سيارة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'كل حقول عقد التطبيق القديم ضمن التصميم الجديد',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'بيانات العقد',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 9),
            const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'رقم العقد'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'التاريخ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const TextField(
              decoration: InputDecoration(labelText: 'اسم المالك الشرعي'),
            ),
            const SizedBox(height: 11),
            const TextField(
              decoration: InputDecoration(labelText: 'سكن المالك الشرعي'),
            ),
            const SizedBox(height: 15),
            Text(
              'الطرف الأول • البائع',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 9),
            const TextField(
              decoration: InputDecoration(
                labelText: 'اسم البائع',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 11),
            const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'رقم الهوية'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'المهنة'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const TextField(
              decoration: InputDecoration(
                labelText: 'عنوان البائع ورقم الهاتف',
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'الطرف الثاني • المشتري',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 9),
            const TextField(
              decoration: InputDecoration(
                labelText: 'اسم المشتري',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 11),
            const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'رقم الهوية'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'المهنة'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const TextField(
              decoration: InputDecoration(
                labelText: 'عنوان المشتري ورقم الهاتف',
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'بيانات السيارة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 9),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'اختر سيارة من المخزون',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
              items: vehicles
                  .map(
                    (vehicle) => DropdownMenuItem(
                      value: vehicle.name,
                      child: Text(vehicle.name),
                    ),
                  )
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 11),
            const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'رقم السيارة'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'النوع / الاستخدام'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'الموديل'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'اللون'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const TextField(
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: 'رقم الشاصي VIN'),
            ),
            const SizedBox(height: 15),
            Text(
              'المبلغ بالدينار العراقي',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 9),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'بدل البيع الإجمالي'),
            ),
            const SizedBox(height: 11),
            const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'المبلغ المقبوض'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'المبلغ المتبقي'),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تم استلام المبلغ كاملاً'),
              value: paidInFull,
              onChanged: (value) => setState(() => paidInFull = value),
            ),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(labelText: 'ملاحظات إضافية'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.save_outlined),
              label: const Text('حفظ وإنشاء العقد'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({
    required this.onThemesPressed,
    required this.onAction,
    super.key,
  });

  final VoidCallback onThemesPressed;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const PageStorageKey<String>('settings'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(19),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/branding/logo.jpg',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'زيد لتجارة السيارات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'إدارة محلية للمعرض والعقود',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => onAction('تم فتح بيانات المعرض'),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 21),
        const SectionTitle(
          title: 'أدوات إدارة المعرض',
          subtitle: 'كل وحدات الإصدار القديم داخل الواجهة الجديدة',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final width = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                _ModuleTile(
                  width: width,
                  icon: Icons.groups_2_outlined,
                  title: 'العملاء',
                  onTap: () => onAction('تم فتح سجل العملاء وكشوفاتهم'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.local_shipping_outlined,
                  title: 'الموردون',
                  onTap: () => onAction('تم فتح الموردين وحساباتهم'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.payments_outlined,
                  title: 'الدفعات والأقساط',
                  onTap: () => onAction('تم فتح الدفعات والأقساط'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.request_quote_outlined,
                  title: 'المصاريف',
                  onTap: () => onAction('تم فتح مصاريف المعرض والسيارات'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.account_balance_outlined,
                  title: 'الصندوق',
                  onTap: () => onAction('تم فتح حركات الصندوق'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.query_stats_rounded,
                  title: 'الأرباح',
                  onTap: () => onAction('تم فتح أرباح السيارات'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.task_alt_rounded,
                  title: 'المهام',
                  onTap: () => onAction('تم فتح مهام المتابعة'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.badge_outlined,
                  title: 'الموظفون',
                  onTap: () => onAction('تم فتح الموظفين والرواتب'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.bar_chart_rounded,
                  title: 'التقارير',
                  onTap: () => onAction('تم فتح التقارير الأسبوعية والشهرية'),
                ),
                _ModuleTile(
                  width: width,
                  icon: Icons.currency_exchange_rounded,
                  title: 'تحويل العملة',
                  onTap: () => onAction('تم فتح محول الدينار والدولار'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        const SectionTitle(
          title: 'الإعدادات',
          subtitle: 'خصص التطبيق وبيانات المعرض',
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.palette_outlined,
          title: 'مظهر التطبيق',
          subtitle: 'اختر من ١٠ ثيمات بخطوط عربية كاملة',
          onTap: onThemesPressed,
        ),
        _SettingsTile(
          icon: Icons.storefront_outlined,
          title: 'بيانات المعرض',
          subtitle: 'الاسم والعنوان وأرقام الاتصال',
          onTap: () => onAction('تم فتح بيانات المعرض'),
        ),
        _SettingsTile(
          icon: Icons.notifications_none_rounded,
          title: 'التنبيهات',
          subtitle: 'العقود والمواعيد وحالة المخزون',
          onTap: () => onAction('تم فتح إعدادات التنبيهات'),
        ),
        _SettingsTile(
          icon: Icons.backup_outlined,
          title: 'النسخ الاحتياطي',
          subtitle: 'حفظ نسخة من كل السيارات والحسابات والعقود',
          onTap: () => onAction('النسخة الاحتياطية جاهزة'),
        ),
        _SettingsTile(
          icon: Icons.table_view_outlined,
          title: 'تصدير Excel',
          subtitle: 'تصدير السيارات والمبيعات والديون',
          onTap: () => onAction('تم تجهيز ملف Excel للتصدير'),
        ),
        _SettingsTile(
          icon: Icons.lock_outline_rounded,
          title: 'الخصوصية والأمان',
          subtitle: 'حماية بيانات العملاء والعقود',
          onTap: () => onAction('تم فتح الخصوصية والأمان'),
        ),
        const SizedBox(height: 18),
        Center(
          child: Column(
            children: <Widget>[
              Text(
                'زيد للسيارات',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'الإصدار 1.0.36 (Build 2036)',
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.width,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: 86,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(
              children: <Widget>[
                Icon(icon, color: colors.primary, size: 25),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
      ),
    ),
  );
}

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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 14 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'اختر مظهر التطبيق',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              '١٠ ثيمات تغيّر الألوان والخطوط والبطاقات والأزرار',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
                  return Semantics(
                    selected: selected,
                    button: true,
                    label: 'ثيم ${item.name}',
                    child: InkWell(
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
                            color: selected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 2.5,
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
                                      color: Colors.white.withValues(alpha: .8),
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
