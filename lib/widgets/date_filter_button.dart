import 'package:flutter/material.dart';

enum DateFilter {
  all('All Events'),
  thisMonth('This Month'),
  nextMonth('Next Month');

  final String label;
  const DateFilter(this.label);
}

class DateFilterButton extends StatelessWidget {
  final DateFilter currentFilter;
  final Function(DateFilter) onFilterChanged;

  const DateFilterButton({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateFilter>(
      initialValue: currentFilter,
      icon: const Icon(Icons.filter_list),
      onSelected: onFilterChanged,
      itemBuilder:
          (context) =>
              DateFilter.values
                  .map(
                    (filter) =>
                        PopupMenuItem(value: filter, child: Text(filter.label)),
                  )
                  .toList(),
    );
  }
}
