import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

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
    _appLinks = AppLinks();

    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });

    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }).catchError((err) {
      debugPrint('Initial link error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');
    debugPrint('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    debugPrint('Query params: ${uri.queryParameters}');

    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      debugPrint('OAuth code found: ${code.substring(0, 8)}...');
      final navContext = _navigatorKey.currentContext;
      if (navContext != null) {
        final auth = navContext.read<AuthProvider>();
        auth.completeLogin(code);
      } else {
        debugPrint('Navigator context is null - cannot complete login');
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
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const MainScreen();
            }
            return const LoginPage();
          },
        ),
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
