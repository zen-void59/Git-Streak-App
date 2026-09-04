import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import 'models/habit_model.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/settings_provider.dart';
import 'services/github_service.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';
import 'main_screen.dart';
import 'login_page.dart';
import 'pages/profile_page.dart';
import 'compare_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitModelAdapter());
  }

  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox('settings');

  // Init notifications
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    // Handle deep links when app is running
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });

    // Handle deep link that opened the app
    getInitialUri().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }).catchError((err) {
      debugPrint('Initial URI error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    // Handle mossapp://callback?code=xxx
    if (uri.scheme == 'mossapp' && uri.host == 'callback') {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        // Complete the OAuth flow
        final auth = context.read<AuthProvider>();
        auth.completeLogin(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        Provider(create: (_) => GitHubService()),
      ],
      child: MaterialApp(
        title: 'Moss',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        navigatorKey: _navigatorKey,
        home: const AuthGate(),
        routes: {
          '/home': (_) => const MainScreen(),
          '/login': (_) => const LoginPage(),
          '/profile': (_) => const ProfilePage(),
          '/compare': (_) => const ComparePage(),
        },
      ),
    );
  }
}

/// Decides whether to show login or main screen based on auth state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (auth.isAuthenticated) {
          return const MainScreen();
        }

        return const LoginPage();
      },
    );
  }
}
