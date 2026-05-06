import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../data/adhkar_data.dart';
import '../providers/adhkar_progress_provider.dart';

class AdhkarScreen extends ConsumerStatefulWidget {
  final String type; // 'morning' | 'evening' | 'sleep'
  const AdhkarScreen({super.key, required this.type});

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  int _displayedIndex = 0;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((s) {
      if (mounted) setState(() => _isPlaying = s.playing);
    });

    final state = ref.read(adhkarProgressProvider(widget.type));
    _displayedIndex = state.currentIndex.clamp(0, _adhkar.length - 1);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _audioPath(int index) =>
      'assets/audio/adhkar/${widget.type}_${(index + 1).toString().padLeft(2, '00')}.ogg';

  Future<void> _toggleAudio(int index) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      return;
    }
    try {
      await _audioPlayer.setAsset(_audioPath(index));
      await _audioPlayer.play();
    } catch (_) {}
  }

  Future<void> _stopAudio() async {
    if (_isPlaying) await _audioPlayer.stop();
  }

  List<AdhkarItem> get _adhkar => switch (widget.type) {
        'morning' => morningAdhkar,
        'sleep' => sleepAdhkar,
        _ => eveningAdhkar,
      };

  Future<void> _onTap() async {
    if (_advancing) return;

    final notifier = ref.read(adhkarProgressProvider(widget.type).notifier);
    final stateBefore = ref.read(adhkarProgressProvider(widget.type));
    final adhkar = _adhkar;
    final idx = stateBefore.currentIndex;
    if (idx >= adhkar.length) return;

    await _pulseCtrl.forward();
    _pulseCtrl.reverse();

    notifier.increment();

    final stateAfter = ref.read(adhkarProgressProvider(widget.type));

    if (stateAfter.currentIndex > idx) {
      await _stopAudio();
      setState(() => _advancing = true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _displayedIndex = stateAfter.currentIndex.clamp(0, adhkar.length - 1);
          _advancing = false;
        });
      }
    }
  }

  Future<void> _onDone() async {
    if (_advancing) return;
    await _stopAudio();
    final notifier = ref.read(adhkarProgressProvider(widget.type).notifier);
    final idx = ref.read(adhkarProgressProvider(widget.type)).currentIndex;
    notifier.completeAt(idx);
    setState(() => _advancing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      final newIdx = ref
          .read(adhkarProgressProvider(widget.type))
          .currentIndex
          .clamp(0, _adhkar.length - 1);
      setState(() {
        _displayedIndex = newIdx;
        _advancing = false;
      });
    }
  }

  void _resetConfirm() {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetConfirmTitle),
        content: Text(l.resetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancelButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(adhkarProgressProvider(widget.type).notifier).reset();
              setState(() => _displayedIndex = 0);
            },
            child: Text(l.resetButton,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(adhkarProgressProvider(widget.type));
    final adhkar = _adhkar;
    final total = adhkar.length;
    final type = widget.type;
    final cs = Theme.of(context).colorScheme;

    if (state.isComplete) {
      return _CompletionScreen(
        type: type,
        onReset: () {
          ref.read(adhkarProgressProvider(widget.type).notifier).reset();
          setState(() => _displayedIndex = 0);
        },
      );
    }

    final idx = _displayedIndex.clamp(0, total - 1);
    final item = adhkar[idx];
    final count = state.counts.length > idx ? state.counts[idx] : 0;
    final isThisOneDone = count >= item.repetitions;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(switch (type) {
          'morning' => l.morningAdhkarsTitle,
          'sleep' => l.sleepAdhkarsTitle,
          _ => l.eveningAdhkarsTitle,
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l.resetButton,
            onPressed: _resetConfirm,
          ),
        ],
      ),
      body: Column(
        children: [
          _ProgressHeader(
            current: state.currentIndex,
            total: total,
            type: type,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _InvocationCard(
                key: ValueKey(idx),
                item: item,
                count: count,
                index: idx,
                total: total,
                isDone: isThisOneDone,
                pulseAnim: _pulseAnim,
                isPlaying: _isPlaying,
                onTap: _onTap,
                onDone: _onDone,
                onToggleAudio: () => _toggleAudio(idx),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final String type;

  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;
    final color = type == 'morning'
        ? AppColors.prayerEarly
        : type == 'sleep'
            ? AppColors.deepPurple
            : AppColors.gold;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Row(
            children: [
              Icon(
                type == 'morning'
                    ? Icons.wb_sunny_rounded
                    : type == 'sleep'
                        ? Icons.bedtime_rounded
                        : Icons.nights_stay_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.invocationCounter(current, total),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 13,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withValues(alpha: 0.12),
          color: color,
          minHeight: 3,
        ),
      ],
    );
  }
}

class _InvocationCard extends StatefulWidget {
  final AdhkarItem item;
  final int count;
  final int index;
  final int total;
  final bool isDone;
  final Animation<double> pulseAnim;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onDone;
  final VoidCallback onToggleAudio;

  const _InvocationCard({
    super.key,
    required this.item,
    required this.count,
    required this.index,
    required this.total,
    required this.isDone,
    required this.pulseAnim,
    required this.isPlaying,
    required this.onTap,
    required this.onDone,
    required this.onToggleAudio,
  });

  @override
  State<_InvocationCard> createState() => _InvocationCardState();
}

class _InvocationCardState extends State<_InvocationCard> {
  bool _sourceExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final sourceText = isEn ? widget.item.sourceEn : widget.item.source;

    return ScaleTransition(
      scale: widget.pulseAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: widget.onToggleAudio,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.isPlaying
                                    ? cs.primary.withValues(alpha: 0.12)
                                    : cs.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                                size: 20,
                                color: widget.isPlaying ? cs.primary : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.arabic,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 30,
                          height: 2.2,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.item.transliteration,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        isEn ? widget.item.translationEn : widget.item.translation,
                        style: TextStyle(fontSize: 14, height: 1.6, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      _CounterBadge(
                        count: widget.count,
                        repetitions: widget.item.repetitions,
                        isDone: widget.isDone,
                      ),
                      const SizedBox(height: 16),
                      if (!widget.isDone && widget.item.repetitions >= 100)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: widget.onDone,
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: Text(l.doneButton),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      if (!widget.isDone && widget.item.repetitions < 100)
                        Center(
                          child: Text(
                            l.touchToReciteHint,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ),
            GestureDetector(
              onTap: () => setState(() => _sourceExpanded = !_sourceExpanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _sourceExpanded
                              ? Icons.info_rounded
                              : Icons.info_outline_rounded,
                          size: 22,
                          color: cs.onSurfaceVariant.withValues(
                            alpha: _sourceExpanded ? 0.75 : 0.45,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Source',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant.withValues(
                              alpha: _sourceExpanded ? 0.75 : 0.45,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _sourceExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: cs.onSurfaceVariant.withValues(
                            alpha: _sourceExpanded ? 0.75 : 0.45,
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: _sourceExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                sourceText,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final int count;
  final int repetitions;
  final bool isDone;

  const _CounterBadge({
    required this.count,
    required this.repetitions,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color =
        isDone ? AppColors.prayerEarly : Theme.of(context).colorScheme.primary;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.prayerEarly.withValues(alpha: 0.12)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isDone ? AppColors.prayerEarly : color,
            width: isDone ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone) ...[
              const Icon(Icons.check_rounded,
                  color: AppColors.prayerEarly, size: 22),
              const SizedBox(width: 8),
              Text(
                l.completedLabel,
                style: const TextStyle(
                  color: AppColors.prayerEarly,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ] else if (repetitions == 1) ...[
              Icon(Icons.touch_app_rounded, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                l.tapToValidateLabel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ] else ...[
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  height: 1,
                ),
              ),
              Text(
                ' / $repetitions',
                style: TextStyle(
                  color: color.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompletionScreen extends StatelessWidget {
  final String type;
  final VoidCallback onReset;

  const _CompletionScreen({required this.type, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final color = type == 'morning'
        ? AppColors.prayerEarly
        : type == 'sleep'
            ? AppColors.deepPurple
            : AppColors.gold;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(switch (type) {
          'morning' => l.morningAdhkarsTitle,
          'sleep' => l.sleepAdhkarsTitle,
          _ => l.eveningAdhkarsTitle,
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l.restartButton,
            onPressed: onReset,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.check_circle_rounded, color: color, size: 60),
              ),
              const SizedBox(height: 24),
              Text(
                l.allahiBarak,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                switch (type) {
                  'morning' => l.morningAdhkarsCompletedMessage,
                  'sleep' => l.sleepAdhkarsCompletedMessage,
                  _ => l.eveningAdhkarsCompletedMessage,
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.restartButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
