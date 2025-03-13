enum DateFilter {
  all('All'),
  thisMonth('This Month'),
  nextMonth('Next Month');

  final String label;
  const DateFilter(this.label);
}
