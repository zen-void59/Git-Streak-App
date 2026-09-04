import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contribution_day.dart';
import '../utils/constants.dart';

class ContributionHeatmap extends StatefulWidget {
  final List<ContributionDay> days;

  const ContributionHeatmap({super.key, required this.days});

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap>
    with SingleTickerProviderStateMixin {
  ContributionDay? _hoveredDay;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const double _cellSize = 11;
  static const double _cellGap = 2.5;
  static const int _weeks = 53;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Color _colorForCount(int count) {
    if (count == 0) return AppColors.heatmap0;
    if (count <= 2) return AppColors.heatmap1;
    if (count <= 5) return AppColors.heatmap2;
    if (count <= 10) return AppColors.heatmap3;
    return AppColors.heatmap4;
  }

  /// Build a 53-week grid from the contribution data.
  List<List<ContributionDay?>> _buildGrid() {
    final grid = List.generate(_weeks, (_) => List<ContributionDay?>.filled(7, null));

    if (widget.days.isEmpty) return grid;

    final sorted = [...widget.days]..sort((a, b) => a.date.compareTo(b.date));
    final earliest = sorted.first.date;

    // Find the Sunday before (or on) the earliest date
    final startOffset = earliest.weekday % 7; // 0=Sun…6=Sat
    final gridStart = earliest.subtract(Duration(days: startOffset));

    for (final day in sorted) {
      final diff = day.date.difference(gridStart).inDays;
      final weekIdx = diff ~/ 7;
      final dayIdx = diff % 7;
      if (weekIdx >= 0 && weekIdx < _weeks && dayIdx >= 0 && dayIdx < 7) {
        grid[weekIdx][dayIdx] = day;
      }
    }
    return grid;
  }

  List<String> _monthLabels(List<List<ContributionDay?>> grid) {
    final labels = <String>[];
    String? lastMonth;
    for (int w = 0; w < grid.length; w++) {
      final day = grid[w].firstWhere((d) => d != null, orElse: () => null);
      if (day != null) {
        final m = DateFormat('MMM').format(day.date);
        if (m != lastMonth) {
          labels.add(m);
          lastMonth = m;
        } else {
          labels.add('');
        }
      } else {
        labels.add('');
      }
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final grid = _buildGrid();
    final monthLabels = _monthLabels(grid);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month labels
                Row(
                  children: List.generate(_weeks, (w) {
                    return SizedBox(
                      width: _cellSize + _cellGap,
                      child: Text(
                        monthLabels[w],
                        style: const TextStyle(
                          fontSize: 8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                // Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day labels (Mon, Wed, Fri)
                    Column(
                      children: List.generate(7, (dayIdx) {
                        final label = dayIdx == 1
                            ? 'Mon'
                            : dayIdx == 3
                                ? 'Wed'
                                : dayIdx == 5
                                    ? 'Fri'
                                    : '';
                        return SizedBox(
                          height: _cellSize + _cellGap,
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 7,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 4),
                    // Weeks
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_weeks, (w) {
                        return Column(
                          children: List.generate(7, (d) {
                            final day = w < grid.length ? grid[w][d] : null;
                            final count = day?.count ?? 0;
                            return GestureDetector(
                              onTap: day != null
                                  ? () {
                                      setState(() {
                                        _hoveredDay =
                                            _hoveredDay == day ? null : day;
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: _cellSize,
                                height: _cellSize,
                                margin: const EdgeInsets.all(_cellGap / 2),
                                decoration: BoxDecoration(
                                  color: _colorForCount(count),
                                  borderRadius: BorderRadius.circular(2),
                                  border: _hoveredDay == day && day != null
                                      ? Border.all(
                                          color: AppColors.primary, width: 1)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tooltip for selected day
          if (_hoveredDay != null) ...[
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${DateFormat('MMM d, yyyy').format(_hoveredDay!.date)}  •  '
                '${_hoveredDay!.count} contribution${_hoveredDay!.count != 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              const Text(
                'Less',
                style:
                    TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              const SizedBox(width: 4),
              for (final c in [
                AppColors.heatmap0,
                AppColors.heatmap1,
                AppColors.heatmap2,
                AppColors.heatmap3,
                AppColors.heatmap4,
              ])
                Container(
                  width: 11,
                  height: 11,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 4),
              const Text(
                'More',
                style:
                    TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
