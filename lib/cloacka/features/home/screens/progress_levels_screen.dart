import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/cloacka/core/presentation/state/ui_state.dart';
import 'package:neomoney/cloacka/features/home/bloc/progress_level_state.dart';
import 'package:neomoney/cloacka/features/home/bloc/progress_levels_cubit.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class ProgressLevelsScreen extends StatelessWidget {
  const ProgressLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgressLevelsCubit(totalLevels: 12, purchasesPerLevel: 2),
      child: const _ProgressLevelsView(),
    );
  }
}

class _ProgressLevelsView extends StatefulWidget {
  const _ProgressLevelsView();

  @override
  State<_ProgressLevelsView> createState() => _ProgressLevelsViewState();
}

class _ProgressLevelsViewState extends State<_ProgressLevelsView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // при первом построении
    _syncCount();
  }

  @override
  Widget build(BuildContext context) {
    // при любых изменениях AppState (список покупок) — синхронизируем cubit
    // Это cheap: один int + один emit.
    _syncCount();

    return BlocBuilder<ProgressLevelsCubit, ProgressLevelsState>(
      builder: (context, s) {
        return Scaffold(
          backgroundColor: AppColors.backColor,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              children: [
                Text(
                  'Уровни прогресса',
                  style: AppTypography.textTheme.displayMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                _TopInfoCard(
                  level: s.currentLevel,
                  totalLevels: s.totalLevels,
                  plannedPurchases: s.plannedPurchasesCount,
                  levelProgress: s.levelProgress,
                  purchasesPerLevel: s.purchasesPerLevel,
                ),

                const SizedBox(height: 16),

                _SnakeLevelsCard(
                  totalLevels: s.totalLevels,
                  currentLevel: s.currentLevel,
                  completedLevels: s.completedLevels,
                ),

                const SizedBox(height: 16),

                _HintCard(
                  currentLevel: s.currentLevel,
                  purchasesToNext: s.purchasesToNext,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _syncCount() {
    final count = context.watch<AppState>().plannedPurchases.length;
    context.read<ProgressLevelsCubit>().setPlannedPurchasesCount(count);
  }
}
class _TopInfoCard extends StatelessWidget {
  final int level;
  final int totalLevels;
  final int plannedPurchases;
  final double levelProgress;
  final int purchasesPerLevel;

  const _TopInfoCard({
    required this.level,
    required this.totalLevels,
    required this.plannedPurchases,
    required this.levelProgress,
    required this.purchasesPerLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваш уровень',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6E7485),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$level',
                style: AppTypography.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'из $totalLevels',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF6E7485),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Покупок: $plannedPurchases',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            'До следующего уровня: ${purchasesPerLevel == 0 ? 0 : (purchasesPerLevel * level - plannedPurchases).clamp(0, 9999)} покупки.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6E7485),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnakeLevelsCard extends StatelessWidget {
  final int totalLevels;
  final int currentLevel; // 1..totalLevels
  final int completedLevels;

  const _SnakeLevelsCard({
    required this.totalLevels,
    required this.currentLevel,
    required this.completedLevels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шкала прогресса',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6E7485),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Важное: фиксированная высота для змейки
          LayoutBuilder(
            builder: (context, c) {
              final h = c.maxWidth * 1.5;
              return SizedBox(
                height: h,
                width: double.infinity,
                child: _SnakePathLevels(
                  totalLevels: totalLevels,
                  currentLevel: currentLevel,
                  completedLevels: completedLevels,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final int currentLevel;
  final int purchasesToNext;

  const _HintCard({
    required this.currentLevel,
    required this.purchasesToNext,
  });

  @override
  Widget build(BuildContext context) {
    final String title = currentLevel >= 12
        ? 'Максимальный уровень'
        : 'Как прокачаться?';

    final String subtitle = currentLevel >= 12
        ? 'Вы уже на вершине шкалы — можно добавлять новые цели.'
        : 'Добавьте ещё $purchasesToNext запланированных покупок, чтобы перейти на следующий уровень.';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6E7485),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnakePathLevels extends StatefulWidget {
  final int totalLevels;
  final int currentLevel;
  final int completedLevels;

  const _SnakePathLevels({
    required this.totalLevels,
    required this.currentLevel,
    required this.completedLevels,
  });

  @override
  State<_SnakePathLevels> createState() => _SnakePathLevelsState();
}

class _SnakePathLevelsState extends State<_SnakePathLevels>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const nodeDiameter = 100.0;
    final r = nodeDiameter / 2;
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);

      final points = _SnakeLayout.computePoints(
        size: size,
        count: widget.totalLevels,
        nodeDiameter: 100,
      );

      return Stack(
        children: [
          CustomPaint(
            size: size,
            painter: _SnakePainter(
              points: points,
              completed: widget.completedLevels,
              current: widget.currentLevel,
            ),
          ),

          for (int i = 0; i < points.length; i++)
            Positioned(
              left: points[i].dx - r,
              top: points[i].dy - r,
              child: _LevelNode(
                level: i + 1,
                state: _nodeState(i + 1),
                pulse: (i + 1 == widget.currentLevel) ? _pulse : null,
              ),
            ),
        ],
      );
    });
  }

  _LevelNodeState _nodeState(int level) {
    if (level < widget.currentLevel) return _LevelNodeState.done;
    if (level == widget.currentLevel) return _LevelNodeState.current;
    return _LevelNodeState.locked;
  }
}

class _SnakeLayout {
  static List<Offset> computePoints({
    required Size size,
    required int count,
    double nodeDiameter = 100,
  }) {
    const int rows = 4;
    final int cols = (count / rows).ceil();

    final r = nodeDiameter / 2;

    final left = r;
    final right = size.width - r;
    final top = r;
    final bottom = size.height - r;

    final rowGap = (bottom - top) / math.max(1, rows - 1);
    final colGap = (right - left) / math.max(1, cols - 1);

    final points = <Offset>[];
    int level = 1;

    for (int row = 0; row < rows; row++) {
      final y = top + rowGap * row;
      final ltr = row.isEven;

      for (int col = 0; col < cols; col++) {
        if (level > count) break;

        final x = ltr ? (left + colGap * col) : (right - colGap * col);
        points.add(Offset(x, y));
        level++;
      }
    }

    return points;
  }
}

class _SnakePainter extends CustomPainter {
  final List<Offset> points;
  final int completed;
  final int current;

  _SnakePainter({
    required this.points,
    required this.completed,
    required this.current,
  });

  static const _lineColor = Color(0xFFD3E7FF); // rgba(211,231,255,1)
  static const _activeColor = Color(0xFF4DA3FF); // чтобы прогресс был заметен

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _lineColor;

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _activeColor;

    final fullPath = _buildSmoothPath(points);
    canvas.drawPath(fullPath, basePaint);

    final int activeCount = completed.clamp(0, points.length - 1);
    if (activeCount > 0) {
      final activePath =
      _buildSmoothPath(points.take(activeCount + 1).toList());
      canvas.drawPath(activePath, activePaint);
    }
  }

  Path _buildSmoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);

    for (int i = 1; i < pts.length; i++) {
      final p0 = pts[i - 1];
      final p1 = pts[i];

      final mid = Offset(
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );

      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }

    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.completed != completed ||
        oldDelegate.current != current;
  }
}

enum _LevelNodeState { done, current, locked }

class _LevelNode extends StatelessWidget {
  final int level;
  final _LevelNodeState state;
  final AnimationController? pulse;

  const _LevelNode({
    required this.level,
    required this.state,
    this.pulse,
    super.key,
  });

  static const double _iconSize = 90;
  static const double _circleSize = 100;
  static const Color _circleColor = Color(0xFFD3E7FF);

  @override
  Widget build(BuildContext context) {
    final asset = 'assets/images/${level}_level.png';

    Widget icon = Image.asset(
      asset,
      width: _iconSize,
      height: _iconSize,
      fit: BoxFit.contain,
    );

    if (state == _LevelNodeState.locked) {
      icon = Opacity(
        opacity: 0.45,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(_greyMatrix),
          child: icon,
        ),
      );
    }

    Widget node = SizedBox(
      width: _circleSize,
      height: _circleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _circleSize,
            height: _circleSize,
            decoration: const BoxDecoration(
              color: _circleColor,
              shape: BoxShape.circle,
            ),
          ),
          icon,
        ],
      ),
    );

    if (pulse != null) {
      node = ScaleTransition(scale: pulse!, child: node);
    }

    return node;
  }

  static const List<double> _greyMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];
}