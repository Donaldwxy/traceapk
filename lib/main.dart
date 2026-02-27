
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await DatabaseHelper.instance.database;
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  final String _prefKey = 'language_code';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(_prefKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          locale: provider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Add other delegates here if needed
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('zh', ''),
          ],
          title: 'Location Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            textTheme: GoogleFonts.latoTextTheme(),
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _isLoading = false;
  String _statusMessage = '...'; // Placeholder
  List<LocationRecord> _recentRecords = [];
  bool _isMainlandChina = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial status message and load data after the first frame.
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.translate('Press the refresh button to get your location.');
      });
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData(isManual: false);
    }
  }

  Future<void> _loadInitialData() async {
    await _refreshData(isManual: false);
  }

  Future<void> _refreshData({bool isManual = true}) async {
    if (_isLoading) return;

    final loc = AppLocalizations.of(context)!;
    final gettingLocationText = loc.translate('Getting your current location...');
    final successText = loc.translate('Successfully recorded your location!');

    setState(() {
      _isLoading = true;
      _statusMessage = gettingLocationText;
    });

    try {
      await _checkPermissions();
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final newRecord = LocationRecord(
        timestamp: DateTime.now().toIso8601String(),
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await DatabaseHelper.instance.create(newRecord);
      _statusMessage = successText;
    } catch (e) {
      _statusMessage = 'Error: ${e.toString()}';
    } finally {
      if (mounted) {
        await _loadHistory();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    final records = await DatabaseHelper.instance.getRecentRecords(limit: 10);
    if (mounted) {
      setState(() {
        _recentRecords = records;
      });
    }
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

    if (picked == null) return;

    final records = await DatabaseHelper.instance.getRecordsByDate(picked);
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${AppLocalizations.of(context)!.translate('Records for')} ${DateFormat.yMMMd().format(picked)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: records.isEmpty
              ? Text(AppLocalizations.of(context)!.translate('No records found for this date.'))
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
                      onTap: () => _openMap(record.latitude, record.longitude),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.translate('Close')),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _openMap(double latitude, double longitude) async {
    String url;
    if (_isMainlandChina) {
      url = 'androidamap://viewMap?sourceApplication=amap&lat=$latitude&lon=$longitude&dev=0';
    } else {
      url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toggleRegion() {
    setState(() {
      _isMainlandChina = !_isMainlandChina;
      final locale = _isMainlandChina ? const Locale('zh') : const Locale('en');
      Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final timeZoneName = DateTime.now().timeZoneName;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('Location History')),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: AppLocalizations.of(context)!.translate('Search by date'),
            onPressed: _showRecordsByDate,
          ),
          IconButton(
            icon: Icon(_isMainlandChina ? Icons.public_off : Icons.public),
            tooltip: _isMainlandChina ? '切换到海外' : 'Switch to Mainland China',
            onPressed: _toggleRegion,
          ),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _recentRecords.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate('No records yet. Press the refresh button to start!'),
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
                              _isMainlandChina ? 'yyyy年M月d日 HH:mm:ss' : 'MMM d, yyyy - hh:mm:ss a',
                              localeProvider.locale.toString(),
                            ).format(parsedDate),
                          ),
                          subtitle: Text(
                            '${_isMainlandChina ? '纬度' : 'Lat'}: ${record.latitude.toStringAsFixed(4)}, ${_isMainlandChina ? '经度' : 'Lon'}: ${record.longitude.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () => _openMap(record.latitude, record.longitude),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Text(
                '${_isMainlandChina ? '时区' : 'Timezone'}: $timeZoneName',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshData(isManual: true),
        tooltip: AppLocalizations.of(context)!.translate('Record Current Location'),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }
}
