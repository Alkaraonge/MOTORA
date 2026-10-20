import 'package:flutter/material.dart';

enum MotoraShape { rounded, pill, angular, square, continuous }

@immutable
class MotoraTokens extends ThemeExtension<MotoraTokens> {
  const MotoraTokens({
    required this.gradient,
    required this.glow,
    required this.heroRadius,
    required this.cardRadius,
    required this.compact,
  });

  final List<Color> gradient;
  final Color glow;
  final double heroRadius;
  final double cardRadius;
  final bool compact;

  @override
  MotoraTokens copyWith({
    List<Color>? gradient,
    Color? glow,
    double? heroRadius,
    double? cardRadius,
    bool? compact,
  }) => MotoraTokens(
    gradient: gradient ?? this.gradient,
    glow: glow ?? this.glow,
    heroRadius: heroRadius ?? this.heroRadius,
    cardRadius: cardRadius ?? this.cardRadius,
    compact: compact ?? this.compact,
  );

  @override
  MotoraTokens lerp(covariant MotoraTokens? other, double t) {
    if (other == null) return this;
    return MotoraTokens(
      gradient: <Color>[
        Color.lerp(gradient.first, other.gradient.first, t)!,
        Color.lerp(gradient.last, other.gradient.last, t)!,
      ],
      glow: Color.lerp(glow, other.glow, t)!,
      heroRadius: heroRadius + (other.heroRadius - heroRadius) * t,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      compact: t < .5 ? compact : other.compact,
    );
  }
}

@immutable
class MotoraThemeSpec {
  const MotoraThemeSpec({
    required this.name,
    required this.tagline,
    required this.fontFamily,
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.shape,
    required this.cardRadius,
    required this.heroRadius,
    required this.compact,
    required this.icon,
  });

  final String name;
  final String tagline;
  final String fontFamily;
  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final MotoraShape shape;
  final double cardRadius;
  final double heroRadius;
  final bool compact;
  final IconData icon;

  OutlinedBorder get buttonShape => switch (shape) {
    MotoraShape.pill => const StadiumBorder(),
    MotoraShape.angular => const BeveledRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    MotoraShape.square => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    MotoraShape.continuous => const ContinuousRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(34)),
    ),
    MotoraShape.rounded => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadius * .72),
    ),
  };

  ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(primary: primary, secondary: secondary, surface: surface);
    final onSurface = colorScheme.onSurface;
    final baseText = ThemeData(brightness: brightness, fontFamily: fontFamily)
        .textTheme
        .apply(
          fontFamily: fontFamily,
          bodyColor: onSurface,
          displayColor: onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      textTheme: baseText.copyWith(
        displaySmall: baseText.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        elevation: brightness == Brightness.dark ? 0 : 1,
        color: surface,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: primary.withValues(
              alpha: brightness == Brightness.dark ? .18 : .10,
            ),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: Size(compact ? 112 : 128, compact ? 44 : 50),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 22,
            vertical: 12,
          ),
          shape: buttonShape,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: Size(compact ? 112 : 128, compact ? 44 : 50),
          side: BorderSide(
            color: primary,
            width: shape == MotoraShape.square ? 2 : 1.3,
          ),
          shape: buttonShape,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: compact ? 66 : 74,
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: .18),
        indicatorShape: buttonShape,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: .18),
        labelStyle: TextStyle(fontFamily: fontFamily),
        side: BorderSide(color: primary.withValues(alpha: .22)),
        shape: buttonShape,
      ),
      dividerColor: onSurface.withValues(alpha: .08),
      extensions: <ThemeExtension<dynamic>>[
        MotoraTokens(
          gradient: <Color>[primary, secondary],
          glow: secondary.withValues(
            alpha: brightness == Brightness.dark ? .24 : .18,
          ),
          heroRadius: heroRadius,
          cardRadius: cardRadius,
          compact: compact,
        ),
      ],
    );
  }
}

const List<MotoraThemeSpec> motoraThemes = <MotoraThemeSpec>[
  MotoraThemeSpec(
    name: 'الملكي',
    tagline: 'ذهب وفخامة',
    fontFamily: 'Cairo',
    brightness: Brightness.dark,
    primary: Color(0xFFD8A73D),
    secondary: Color(0xFF6E5118),
    background: Color(0xFF090A0D),
    surface: Color(0xFF14161B),
    shape: MotoraShape.rounded,
    cardRadius: 18,
    heroRadius: 28,
    compact: false,
    icon: Icons.workspace_premium_rounded,
  ),
  MotoraThemeSpec(
    name: 'الرمال',
    tagline: 'دفء الصحراء',
    fontFamily: 'Tajawal',
    brightness: Brightness.light,
    primary: Color(0xFF8B5E34),
    secondary: Color(0xFFD6A663),
    background: Color(0xFFF8F0E3),
    surface: Color(0xFFFFFBF5),
    shape: MotoraShape.pill,
    cardRadius: 28,
    heroRadius: 42,
    compact: false,
    icon: Icons.wb_sunny_rounded,
  ),
  MotoraThemeSpec(
    name: 'منتصف الليل',
    tagline: 'أزرق عميق',
    fontFamily: 'Almarai',
    brightness: Brightness.dark,
    primary: Color(0xFF4D8DFF),
    secondary: Color(0xFF113F82),
    background: Color(0xFF06101F),
    surface: Color(0xFF0D1B2F),
    shape: MotoraShape.angular,
    cardRadius: 12,
    heroRadius: 12,
    compact: true,
    icon: Icons.dark_mode_rounded,
  ),
  MotoraThemeSpec(
    name: 'الزمرد',
    tagline: 'هدوء راقٍ',
    fontFamily: 'IBMPlexArabic',
    brightness: Brightness.dark,
    primary: Color(0xFF48C78E),
    secondary: Color(0xFF0D6B4B),
    background: Color(0xFF071712),
    surface: Color(0xFF10251E),
    shape: MotoraShape.continuous,
    cardRadius: 30,
    heroRadius: 52,
    compact: false,
    icon: Icons.diamond_rounded,
  ),
  MotoraThemeSpec(
    name: 'روبي سبورت',
    tagline: 'أداء بلا تنازل',
    fontFamily: 'Changa',
    brightness: Brightness.dark,
    primary: Color(0xFFFF3D4F),
    secondary: Color(0xFF8F1020),
    background: Color(0xFF10090B),
    surface: Color(0xFF211014),
    shape: MotoraShape.angular,
    cardRadius: 8,
    heroRadius: 8,
    compact: true,
    icon: Icons.speed_rounded,
  ),
  MotoraThemeSpec(
    name: 'اللؤلؤ',
    tagline: 'بساطة نقية',
    fontFamily: 'NotoKufi',
    brightness: Brightness.light,
    primary: Color(0xFF263238),
    secondary: Color(0xFF90A4AE),
    background: Color(0xFFF4F6F7),
    surface: Color(0xFFFFFFFF),
    shape: MotoraShape.square,
    cardRadius: 4,
    heroRadius: 4,
    compact: true,
    icon: Icons.blur_on_rounded,
  ),
  MotoraThemeSpec(
    name: 'ليلة بنفسجية',
    tagline: 'حضور استثنائي',
    fontFamily: 'ReemKufi',
    brightness: Brightness.dark,
    primary: Color(0xFFB278FF),
    secondary: Color(0xFF6436A8),
    background: Color(0xFF110B1B),
    surface: Color(0xFF211631),
    shape: MotoraShape.continuous,
    cardRadius: 26,
    heroRadius: 44,
    compact: false,
    icon: Icons.auto_awesome_rounded,
  ),
  MotoraThemeSpec(
    name: 'الجلد الكلاسيكي',
    tagline: 'أصالة الطريق',
    fontFamily: 'Amiri',
    brightness: Brightness.light,
    primary: Color(0xFF70452B),
    secondary: Color(0xFFB78255),
    background: Color(0xFFEFE2CF),
    surface: Color(0xFFF9F0E3),
    shape: MotoraShape.square,
    cardRadius: 2,
    heroRadius: 2,
    compact: false,
    icon: Icons.history_edu_rounded,
  ),
  MotoraThemeSpec(
    name: 'آركتيك تك',
    tagline: 'تقنية باردة',
    fontFamily: 'ArefRuqaa',
    brightness: Brightness.dark,
    primary: Color(0xFF32D4F5),
    secondary: Color(0xFF176E8C),
    background: Color(0xFF031419),
    surface: Color(0xFF0B242B),
    shape: MotoraShape.pill,
    cardRadius: 18,
    heroRadius: 24,
    compact: true,
    icon: Icons.ac_unit_rounded,
  ),
  MotoraThemeSpec(
    name: 'غروب',
    tagline: 'طاقة ودفء',
    fontFamily: 'Scheherazade',
    brightness: Brightness.light,
    primary: Color(0xFFE85D2A),
    secondary: Color(0xFFFFB03A),
    background: Color(0xFFFFF3E6),
    surface: Color(0xFFFFFAF4),
    shape: MotoraShape.rounded,
    cardRadius: 22,
    heroRadius: 34,
    compact: false,
    icon: Icons.wb_twilight_rounded,
  ),
];
