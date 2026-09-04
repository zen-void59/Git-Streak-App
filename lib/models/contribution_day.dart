class ContributionDay {
  final DateTime date;
  final int count;

  const ContributionDay({required this.date, required this.count});

  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    return ContributionDay(
      date: DateTime.parse(json['date']),
      count: json['contributionCount'] ?? json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'count': count,
      };
}
