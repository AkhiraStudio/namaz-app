import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/premium_provider.dart';
import '../../domain/entities/premium_status.dart';

const _kProductMonthly  = 'namaz_monthly';
const _kProductYearly   = 'namaz_yearly';
const _kProductLifetime = 'namaz_lifetime';

// (icon, title, subtitle, isSoon)
const _kFeatures = [
  (Icons.bar_chart_rounded,             'Statistiques de suivi des prières',        'Découvrez les schémas de votre pratique pour ne pas vous laisser aller',         false),
  (Icons.nightlight_round,              'Accédez aux Tiers de la Nuit',             'Recevez une notification au meilleur moment pour adorer Allah',                   false),
  (Icons.local_fire_department,         'Séries des prières et rattrapages',         'Motivez-vous en voyant votre nombre de jours pratique augmenter',                false),
  (Icons.mosque_outlined,               'Mosquées à proximité',                      'Ayez accès à la liste des mosquées proches de vous où que vous soyez',           false),
  (Icons.auto_awesome,                  'Prières surérogatoires',                    'Construisez un lien fort avec l\'adoration qu\'Allah aime le plus',              false),
  (Icons.park_outlined,                 'Jardin spirituel',                          'Rattrapez vos prières et embellissez votre jardin',                              true),
  (Icons.menu_book_outlined,            'Adhkar du jour',                            'N\'oubliez plus jamais de lire vos adhkar du matin et du soir',                  false),
  (Icons.repeat_rounded,                'Périodes à rattraper illimitées',           'Entrez autant de périodes sans prières que vous voulez',                         false),
  (Icons.query_stats_rounded,           'Statistiques de rattrapage',                'Suivez votre progression dans le rattrapage de vos prières',                     false),
  (Icons.notifications_active_outlined, 'Horaires de rappel personnalisable',        'Modifiez les moments de rappel pour qu\'ils conviennent à votre quotidien',      false),
];

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  PremiumProduct _selected = PremiumProduct.yearly;

  String get _selectedProductId => switch (_selected) {
        PremiumProduct.monthly  => _kProductMonthly,
        PremiumProduct.yearly   => _kProductYearly,
        PremiumProduct.lifetime => _kProductLifetime,
      };

  Future<void> _purchase() async {
    final error = await ref
        .read(premiumNotifierProvider.notifier)
        .purchase(_selectedProductId);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
    } else {
      _navigateAfterSuccess();
    }
  }

  Future<void> _restore() async {
    final error = await ref.read(premiumNotifierProvider.notifier).restore();
    if (!mounted) return;
    if (error == null) {
      _navigateAfterSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _navigateAfterSuccess() {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    if (from != null && from.isNotEmpty) {
      context.go(Uri.decodeComponent(from));
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(premiumNotifierProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Bouton fermer ─────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: cs.onSurface.withValues(alpha: 0.45)),
                  onPressed: () => context.pop(),
                ),
              ),
            ),

            // ── Contenu scrollable ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ─────────────────────────────────────────────
                    Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withValues(alpha: 0.15),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded,
                                color: AppColors.gold, size: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Titre ─────────────────────────────────────────────
                    Text(
                      'Namaz Pro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Tagline ───────────────────────────────────────────
                    const Text(
                      'Débloquez toutes les fonctionnalités\npour approfondir vos adorations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: AppColors.mediumPurple,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // ── Liste des features ────────────────────────────────
                    ..._kFeatures.map(
                      (f) => _FeatureRow(feature: f, isDark: isDark),
                    ),
                  ],
                ),
              ),
            ),

            // ── Section fixe en bas ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.creamBackground,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProductSelector(
                    selected: _selected,
                    onSelect: (p) => setState(() => _selected = p),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _CtaButton(isLoading: isLoading, onPressed: _purchase),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FooterLink(
                          label: 'Restaurer',
                          onTap: isLoading ? null : _restore),
                      _FooterDot(cs: cs),
                      _FooterLink(label: 'Conditions', onTap: () {}),
                      _FooterDot(cs: cs),
                      _FooterLink(label: 'Confidentialité', onTap: () {}),
                    ],
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

// ── Ligne feature ─────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final (IconData, String, String, bool) feature;
  final bool isDark;

  const _FeatureRow({required this.feature, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, title, subtitle, isSoon) = feature;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    if (isSoon) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mediumPurple
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.mediumPurple
                                .withValues(alpha: 0.30),
                          ),
                        ),
                        child: const Text(
                          'Bientôt',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mediumPurple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: cs.onSurface.withValues(alpha: 0.50),
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

// ── Sélecteur de produits (3 colonnes) ───────────────────────────────────────

class _ProductSelector extends StatelessWidget {
  final PremiumProduct selected;
  final ValueChanged<PremiumProduct> onSelect;
  final bool isDark;

  const _ProductSelector({
    required this.selected,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProductCard(
            product: PremiumProduct.monthly,
            title: 'Mensuel',
            price: '4,99 €',
            priceUnit: '/mois',
            subtitle: 'Facturation mensuelle',
            isSelected: selected == PremiumProduct.monthly,
            onTap: () => onSelect(PremiumProduct.monthly),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ProductCard(
            product: PremiumProduct.yearly,
            title: 'Annuel',
            price: '35,99 €',
            priceUnit: '/an',
            subtitle: 'Seulement 3 €/mois',
            isSelected: selected == PremiumProduct.yearly,
            onTap: () => onSelect(PremiumProduct.yearly),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ProductCard(
            product: PremiumProduct.lifetime,
            title: 'À vie',
            price: '119,99 €',
            priceUnit: '',
            subtitle: 'Paiement unique',
            isSelected: selected == PremiumProduct.lifetime,
            onTap: () => onSelect(PremiumProduct.lifetime),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PremiumProduct product;
  final String title;
  final String price;
  final String priceUnit;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ProductCard({
    required this.product,
    required this.title,
    required this.price,
    required this.priceUnit,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.deepPurple
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : cs.onSurface,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: cs.outlineVariant, width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: AppColors.deepPurple)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : cs.onSurface,
                    ),
                  ),
                  if (priceUnit.isNotEmpty)
                    TextSpan(
                      text: priceUnit,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white70
                            : cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.70)
                    : cs.onSurface.withValues(alpha: 0.50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton CTA ────────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _CtaButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.deepPurple.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                'Continuer',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
      ),
    );
  }
}

// ── Helpers footer ────────────────────────────────────────────────────────────

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  final ColorScheme cs;
  const _FooterDot({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      '·',
      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.25)),
    );
  }
}
