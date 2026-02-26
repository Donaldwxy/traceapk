import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';

void main() async {
  // Ensure that Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database helper.
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  String _statusMessage = 'Press the refresh button to get your location.';
  List<LocationRecord> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    // Automatically fetch data and load history on startup.
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _refreshData();
  }

  Future<void> _refreshData() async {
    if (_isLoading) return; // Prevent simultaneous refreshes

    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting your current location...';
    });

    try {
      // 1. Check permissions and services
      await _checkPermissions();

      // 2. Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Create a new record
      final newRecord = LocationRecord(
        timestamp: DateTime.now().toIso8601String(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // 4. Save the new record to the database
      await DatabaseHelper.instance.create(newRecord);
      _statusMessage = 'Successfully recorded your location!';
    } catch (e) {
      _statusMessage = 'Error: ${e.toString()}';
    } finally {
      // 5. Load the updated history and finish loading state
      await _loadHistory();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    final records = await DatabaseHelper.instance.getRecentRecords(limit: 10);
    setState(() {
      _recentRecords = records;
    });
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied. Please enable them in app settings.';
    }
  }

  Future<void> _showRecordsByDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final records = await DatabaseHelper.instance.getRecordsByDate(picked);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Records for ${DateFormat.yMMMd().format(picked)}'),
          content: SizedBox(
            width: double.maxFinite,
            child: records.isEmpty
                ? const Text('No records found for this date.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return ListTile(
                        title: Text(
                          DateFormat.jm().format(
                            DateTime.parse(record.timestamp),
                          ),
                        ),
                        subtitle: Text(
                          'Lat: ${record.latitude.toStringAsFixed(4)}, Lon: ${record.longitude.toStringAsFixed(4)}',
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Search by date',
            onPressed: _showRecordsByDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top status bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                if (_isLoading) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: _isLoading ? TextAlign.start : TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List of recent records
          Expanded(
            child: _recentRecords.isEmpty
                ? const Center(
                    child: Text(
                      'No records yet. Press the refresh button to start!',
                    ),
                  )
                : ListView.builder(
                    itemCount: _recentRecords.length,
                    itemBuilder: (context, index) {
                      final record = _recentRecords[index];
                      final parsedDate = DateTime.parse(record.timestamp);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text((index + 1).toString()),
                          ),
                          title: Text(
                            DateFormat(
                              'MMM d, yyyy - hh:mm:ss a',
                            ).format(parsedDate),
                          ),
                          subtitle: Text(
                            'Lat: ${record.latitude.toStringAsFixed(4)}, Lon: ${record.longitude.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Record Current Location',
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }
}
