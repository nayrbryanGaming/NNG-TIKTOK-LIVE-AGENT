import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/initialization_provider.dart';
import 'providers/settings_notifier.dart';
import 'ui/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: NNGAgentApp(),
    ),
  );
}

class NNGAgentApp extends ConsumerWidget {
  const NNGAgentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp(
      title: 'NNG AGENT by nayrbryanGaming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _showEmergencyButton = false;

  @override
  void initState() {
    super.initState();
    // Show emergency button after 5 seconds (faster)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showEmergencyButton = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(initializationProvider);

    return initAsync.when(
      data: (_) => const MainScreen(),
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/NNG.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('Loading NNG AGENT...'),
              const SizedBox(height: 16),
              if (_showEmergencyButton) ...[
                const SizedBox(height: 24),
                const Text(
                  'Taking too long?',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MainScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip & Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/NNG.png',
                height: 64,
                width: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'NNG AGENT',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              const Icon(Icons.warning, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'App initialized with warnings. You can still use the app!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to main screen anyway
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(),
                    ),
                  );
                },
                child: const Text('Continue to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

