import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class CoreBaseApp extends StatelessWidget {
  final String initialRoute;
  final ThemeData? theme;
  final Route<dynamic>? Function(RouteSettings) onGenerateRoute;

  const CoreBaseApp({super.key,
    required this.initialRoute,
    required this.onGenerateRoute,
    this.theme
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      title: 'Flutter Demo',
      onGenerateRoute: onGenerateRoute,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme,
      initialRoute: initialRoute,
    );
  }
}
