import 'package:flutter/material.dart';
import '../models/date_filter.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateFilter _selectedFilter = DateFilter.all;
  final List<Event> _events = []; // Your events list

  List<Event> get _filteredEvents {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    final followingMonth = DateTime(now.year, now.month + 2);

    switch (_selectedFilter) {
      case DateFilter.thisMonth:
        return _events.where((event) {
          return event.date.isAfter(thisMonth) &&
              event.date.isBefore(nextMonth);
        }).toList();
      case DateFilter.nextMonth:
        return _events.where((event) {
          return event.date.isAfter(nextMonth) &&
              event.date.isBefore(followingMonth);
        }).toList();
      case DateFilter.all:
        return _events;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Events'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  DateFilter.values
                      .map(
                        (filter) => RadioListTile<DateFilter>(
                          title: Text(filter.label),
                          value: filter,
                          groupValue: _selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          return EventCard(
            event: _filteredEvents[index],
            onDelete:
                () => setState(() {
                  _events.remove(_filteredEvents[index]);
                }),
          );
        },
      ),
      // ... rest of your scaffold (FAB, etc.)
    );
  }
}
