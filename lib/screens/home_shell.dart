import 'package:flutter/material.dart';

import '../models/motora_data.dart';
import '../theme/motora_theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.selectedThemeIndex,
    required this.onThemeChanged,
    super.key,
  });

  final int selectedThemeIndex;
  final ValueChanged<int> onThemeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _pageIndex = 0;

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
                    onExplore: () => setState(() => _pageIndex = 1),
                    onAction: _notify,
                  ),
                  CarsView(onAction: _notify),
                  ServicesView(onAction: _notify),
                  ProfileView(onThemesPressed: _showThemes, onAction: _notify),
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
            icon: Icon(Icons.auto_fix_high_outlined),
            selectedIcon: Icon(Icons.auto_fix_high_rounded),
            label: 'الخدمات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
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
            width: 44,
            height: 44,
            decoration: ShapeDecoration(
              color: colors.primary,
              shape: themeSpec.buttonShape,
            ),
            alignment: Alignment.center,
            child: Text(
              'M',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 22,
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
                  'MOTORA',
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(letterSpacing: 2.2),
                ),
                Text(
                  'صُممت لتقود',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'اختيار الثيم',
            child: InkWell(
              key: const Key('theme-picker-button'),
              onTap: onThemesPressed,
              customBorder: themeSpec.buttonShape,
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: ShapeDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  shape: themeSpec.buttonShape.copyWith(
                    side: BorderSide(
                      color: colors.primary.withValues(alpha: .26),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(themeSpec.icon, size: 18, color: colors.primary),
                    const SizedBox(width: 7),
                    Text(
                      themeSpec.name,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({required this.onExplore, required this.onAction, super.key});

  final VoidCallback onExplore;
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
          _HeroPanel(onExplore: onExplore),
          SizedBox(height: tokens.compact ? 18 : 24),
          const SectionTitle(
            title: 'كل ما تحتاجه',
            subtitle: 'خدمات مصممة حول رحلتك',
          ),
          const SizedBox(height: 13),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 11,
            crossAxisSpacing: 11,
            childAspectRatio: tokens.compact ? 1.72 : 1.55,
            children: <Widget>[
              _QuickAction(
                icon: Icons.calendar_month_rounded,
                label: 'تجربة قيادة',
                caption: 'احجز موعدك',
                onTap: () => onAction('تم فتح مواعيد تجربة القيادة'),
              ),
              _QuickAction(
                icon: Icons.car_repair_rounded,
                label: 'موعد صيانة',
                caption: 'خدمة بلا انتظار',
                onTap: () => onAction('تم فتح جدول مراكز العناية'),
              ),
              _QuickAction(
                icon: Icons.compare_arrows_rounded,
                label: 'قارن الطرازات',
                caption: 'اختر الأنسب لك',
                onTap: onExplore,
              ),
              _QuickAction(
                icon: Icons.calculate_rounded,
                label: 'حاسبة التمويل',
                caption: 'خطة تناسبك',
                onTap: () => onAction('حاسبة التمويل جاهزة'),
              ),
            ],
          ),
          SizedBox(height: tokens.compact ? 18 : 24),
          SectionTitle(
            title: 'اختيار MOTORA',
            subtitle: 'أناقة كهربائية بأداء لا يُنسى',
            action: 'عرض الكل',
            onAction: onExplore,
          ),
          const SizedBox(height: 13),
          _FeaturedVehicle(vehicle: vehicles.first, onTap: onExplore),
          const SizedBox(height: 18),
          const _StatusStrip(),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tokens = theme.extension<MotoraTokens>()!;
    return Container(
      height: tokens.compact ? 224 : 248,
      width: double.infinity,
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
            left: -46,
            top: -58,
            child: _GlowOrb(
              size: 180,
              color: colors.onPrimary.withValues(alpha: .09),
            ),
          ),
          Positioned(
            right: -25,
            bottom: -60,
            child: _GlowOrb(
              size: 170,
              color: colors.onPrimary.withValues(alpha: .08),
            ),
          ),
          Positioned(
            left: 12,
            bottom: -12,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: tokens.compact ? 128 : 152,
              color: colors.onPrimary.withValues(alpha: .17),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.compact ? 20 : 24),
            child: Column(
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
                    'الجيل الجديد  •  ٢٠٢٧',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'الطريق يبدأ\nمن هنا',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colors.onPrimary,
                    fontSize: tokens.compact ? 31 : 36,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اكتشف تجربة قيادة عربية بمعايير عالمية',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: .82),
                  ),
                ),
                const SizedBox(height: 15),
                FilledButton.tonalIcon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('استكشف المجموعة'),
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
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                      vehicle.category,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.name,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle.price,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        _TinySpec(
                          icon: Icons.bolt_rounded,
                          label: vehicle.power,
                        ),
                        const SizedBox(width: 12),
                        _TinySpec(
                          icon: Icons.route_rounded,
                          label: vehicle.range,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .11),
                  shape: BoxShape.circle,
                ),
                child: Icon(vehicle.icon, size: 67, color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinySpec extends StatelessWidget {
  const _TinySpec({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 4),
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(
          Theme.of(context).extension<MotoraTokens>()!.cardRadius,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.eco_rounded, color: colors.primary),
          const SizedBox(width: 10),
          const Expanded(child: Text('رحلات أنظف. أداء أقوى. مستقبل أجمل.')),
          Text(
            '100% EV',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w900,
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
  final filters = const <String>['الكل', 'سيدان', 'دفع رباعي', 'رياضية'];

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
                const SectionTitle(
                  title: 'مجموعة MOTORA',
                  subtitle: 'ثلاث شخصيات، وهندسة واحدة تتقن التفاصيل',
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
              height: 142,
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
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 13,
                    right: 14,
                    child: Text(
                      '0${index + 1}',
                      style: TextStyle(
                        color: colors.primary.withValues(alpha: .5),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(vehicle.icon, size: 108, color: colors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vehicle.category,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            Text(
              vehicle.name,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                _TinySpec(icon: Icons.bolt_rounded, label: vehicle.power),
                const SizedBox(width: 18),
                _TinySpec(icon: Icons.route_rounded, label: vehicle.range),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vehicle.price,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 15),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: () => onAction('تم اختيار ${vehicle.name}'),
                    child: const Text('تكوين سيارتك'),
                  ),
                ),
                const SizedBox(width: 9),
                IconButton.filledTonal(
                  onPressed: () =>
                      onAction('أُضيفت ${vehicle.name} إلى المفضلة'),
                  icon: const Icon(Icons.favorite_border_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesView extends StatelessWidget {
  const ServicesView({required this.onAction, super.key});
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const PageStorageKey<String>('services'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: <Widget>[
        const SectionTitle(
          title: 'خدمات MOTORA',
          subtitle: 'رعاية استباقية تظل معك في كل رحلة',
        ),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(19),
            child: Row(
              children: <Widget>[
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: .12),
                  ),
                  child: Icon(
                    Icons.health_and_safety_rounded,
                    color: colors.primary,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'حالة سيارتك',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'جميع الأنظمة تعمل بكفاءة',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: .92,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '٩٢٪',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: colors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 13),
        ...services.map(
          (service) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Card(
              child: ListTile(
                onTap: () => onAction('تم فتح ${service.title}'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(service.icon, color: colors.primary),
                ),
                title: Text(
                  service.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  service.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.status,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        FilledButton.icon(
          onPressed: () => onAction('بدأ التواصل مع خبير MOTORA'),
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('تحدث مع خبير MOTORA'),
        ),
      ],
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({
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
      key: const PageStorageKey<String>('profile'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 34,
                  backgroundColor: colors.primary,
                  child: Text(
                    'م',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'مرحباً بك',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      Text(
                        'مالك MOTORA',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'عضوية BLACK • منذ ٢٠٢٦',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => onAction('تعديل الملف الشخصي'),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 21),
        const SectionTitle(title: 'تجربتك', subtitle: 'خصص التطبيق كما تحب'),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.palette_outlined,
          title: 'مظهر التطبيق',
          subtitle: 'اختر من ١٠ ثيمات متكاملة',
          onTap: onThemesPressed,
        ),
        _SettingsTile(
          icon: Icons.notifications_none_rounded,
          title: 'التنبيهات',
          subtitle: 'المواعيد وحالة السيارة والعروض',
          onTap: () => onAction('تم فتح إعدادات التنبيهات'),
        ),
        _SettingsTile(
          icon: Icons.language_rounded,
          title: 'اللغة والمنطقة',
          subtitle: 'العربية • المملكة العربية السعودية',
          onTap: () => onAction('العربية هي اللغة الحالية'),
        ),
        _SettingsTile(
          icon: Icons.lock_outline_rounded,
          title: 'الخصوصية والأمان',
          subtitle: 'التحكم في بياناتك وأجهزتك',
          onTap: () => onAction('تم فتح الخصوصية والأمان'),
        ),
        const SizedBox(height: 18),
        Center(
          child: Column(
            children: <Widget>[
              Text(
                'MOTORA',
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(letterSpacing: 2),
              ),
              Text(
                'الإصدار 1.0.0 (Build 1)',
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
              'اختر شخصيتك',
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
                  childAspectRatio: 1.65,
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
                        padding: const EdgeInsets.all(13),
                        child: Row(
                          children: <Widget>[
                            Icon(item.icon, color: Colors.white, size: 26),
                            const SizedBox(width: 10),
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
                                      color: Colors.white.withValues(
                                        alpha: .78,
                                      ),
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
                                size: 19,
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
