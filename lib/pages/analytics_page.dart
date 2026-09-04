import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/contribution_day.dart';
import '../models/github_repo.dart';
import '../services/github_service.dart';
import '../services/cache_service.dart';
import '../utils/constants.dart';
import '../utils/streak_calculator.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  final _cache = CacheService();
  final _service = GitHubService();

  List<ContributionDay> _days = [];
  List<GitHubRepo> _repos = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _cache.init();
    final box = Hive.box('settings');
    final username = box.get('github_username', defaultValue: '') as String;

    var days = _cache.getCachedContributions();
    var repos = _cache.getCachedRepos();

    if (days == null) {
      days = await _service.fetchContributions(username);
      if (days.isNotEmpty) await _cache.saveContributions(days);
    }
    if (repos == null) {
      repos = await _service.fetchRepositories(username, perPage: 30);
      if (repos.isNotEmpty) await _cache.saveRepos(repos);
    }

    if (mounted) {
      setState(() {
        _days = days ?? [];
        _repos = repos ?? [];
        _loading = false;
      });
    }
  }

  // Build last 12 weeks of data (7 bars each week aggregated)
  List<BarChartGroupData> _buildWeeklyBars() {
    final groups = <BarChartGroupData>[];
    final now = DateTime.now();
    for (int w = 11; w >= 0; w--) {
      final start = now.subtract(Duration(days: (w + 1) * 7));
      final end = now.subtract(Duration(days: w * 7));
      final weekCommits = _days
          .where((d) => d.date.isAfter(start) && d.date.isBefore(end))
          .fold(0, (s, d) => s + d.count);
      groups.add(
        BarChartGroupData(
          x: 11 - w,
          barRods: [
            BarChartRodData(
              toY: weekCommits.toDouble(),
              color: weekCommits > 0 ? AppColors.primary : AppColors.border,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  // Last 30 days line chart spots
  List<FlSpot> _buildDailySpots() {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 29; i >= 0; i--) {
      final target = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final match = _days.where((d) =>
          d.date.year == target.year &&
          d.date.month == target.month &&
          d.date.day == target.day);
      spots.add(FlSpot((29 - i).toDouble(),
          match.isEmpty ? 0 : match.first.count.toDouble()));
    }
    return spots;
  }

  Map<String, int> _languageMap() {
    final map = <String, int>{};
    for (final r in _repos) {
      if (r.language != 'Unknown') {
        map[r.language] = (map[r.language] ?? 0) + 1;
      }
    }
    return map;
  }

  static const _pieColors = [
    AppColors.primary,
    AppColors.blue,
    AppColors.purple,
    AppColors.amber,
    AppColors.orange,
    AppColors.red,
    Color(0xFF00BCD4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Daily'),
            Tab(text: 'Languages'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _WeeklyTab(groups: _buildWeeklyBars()),
                _DailyTab(spots: _buildDailySpots(), days: _days),
                _LanguagesTab(map: _languageMap(), colors: _pieColors),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────
// Weekly Bar Chart Tab
// ─────────────────────────────────────────
class _WeeklyTab extends StatelessWidget {
  final List<BarChartGroupData> groups;
  const _WeeklyTab({required this.groups});

  @override
  Widget build(BuildContext context) {
    final maxY = groups
            .expand((g) => g.barRods.map((r) => r.toY))
            .fold(0.0, (a, b) => a > b ? a : b) +
        5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Commits per Week (last 12 weeks)',
              style: AppTextStyles.headline3),
          const SizedBox(height: 4),
          const Text('Tap a bar to see week total',
              style: AppTextStyles.caption),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: groups,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gIdx, rod, rIdx) => BarTooltipItem(
                      '${rod.toY.toInt()} commits',
                      const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        return Text(
                          'W${idx + 1}',
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textMuted),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _summaryRow(groups),
        ],
      ),
    );
  }

  Widget _summaryRow(List<BarChartGroupData> groups) {
    final total = groups
        .expand((g) => g.barRods.map((r) => r.toY.toInt()))
        .fold(0, (a, b) => a + b);
    final avg = groups.isEmpty ? 0 : total ~/ groups.length;
    return Row(
      children: [
        Expanded(
            child: _MiniStat(
                label: '12-Week Total', value: total.toString())),
        const SizedBox(width: 12),
        Expanded(
            child: _MiniStat(label: 'Avg / Week', value: avg.toString())),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Daily Line Chart Tab
// ─────────────────────────────────────────
class _DailyTab extends StatelessWidget {
  final List<FlSpot> spots;
  final List<ContributionDay> days;
  const _DailyTab({required this.spots, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxY =
        spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b) + 2;
    final total30 = StreakCalculator.monthlyCommits(days);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Commits (last 30 days)',
              style: AppTextStyles.headline3),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.border, strokeWidth: 0.5),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (v, _) => Text(
                        'D${v.toInt() + 1}',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _MiniStat(label: 'Total (30 days)', value: total30.toString()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Language Pie Chart Tab
// ─────────────────────────────────────────
class _LanguagesTab extends StatelessWidget {
  final Map<String, int> map;
  final List<Color> colors;
  const _LanguagesTab({required this.map, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) {
      return const Center(
        child: Text('No language data available',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0, (s, e) => s + e.value);
    final sections = <PieChartSectionData>[];

    for (int i = 0; i < entries.length.clamp(0, 7); i++) {
      final e = entries[i];
      final pct = (e.value / total * 100).toStringAsFixed(1);
      sections.add(PieChartSectionData(
        color: colors[i % colors.length],
        value: e.value.toDouble(),
        title: '$pct%',
        radius: 90,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const Text('Language Usage', style: AppTextStyles.headline3),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            )),
          ),
          const SizedBox(height: 24),
          ...entries.take(7).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final pct = (e.value / total * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e.key,
                        style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                  Text('$pct%  (${e.value} repos)',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Mini stat widget
// ─────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
