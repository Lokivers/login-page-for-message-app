import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/event.dart';
import 'widgets/event_card.dart';
import 'repositories/event_repository.dart';
import 'screens/upload_event_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events App ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EventRepository _eventRepository = EventRepository();
  late Future<List<Event>> _eventsFuture;
  bool _showMapView = false;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _eventRepository.getEvents();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (_showMapView && _currentLocation != null) {
        _mapController.move(_currentLocation!, 15);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get current location')),
      );
    }
  }

  Widget _buildMapView(List<Event> events) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation ?? const LatLng(0, 0),
        initialZoom: _currentLocation != null ? 15 : 2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            ...events.map(
              (event) => Marker(
                point: LatLng(event.latitude, event.longitude),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => Dialog(
                            child: EventCard(
                              event: event,
                              onDelete: _refreshEvents,
                            ),
                          ),
                    );
                  },
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
            if (_currentLocation != null)
              Marker(
                point: _currentLocation!,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Keep only one map-related icon
          IconButton(
            icon: Icon(_showMapView ? Icons.list : Icons.map),
            tooltip: _showMapView ? 'Show List' : 'Show Map',
            onPressed: () {
              setState(() {
                _showMapView = !_showMapView;
                // If switching to map view and we have current location, center the map
                if (_showMapView && _currentLocation != null) {
                  _mapController.move(_currentLocation!, 13);
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No events found'));
          }

          return _showMapView
              ? _buildMapView(events)
              : ListView.builder(
                itemCount: events.length,
                itemBuilder:
                    (context, index) => EventCard(
                      event: events[index],
                      onDelete: _refreshEvents,
                    ),
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadEventScreen()),
          );
          _refreshEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
