import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_config_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class CoreBaseApp<L> extends StatelessWidget {
  final String initialRoute;
  final ThemeData? theme;
  final Route<dynamic>? Function(RouteSettings) onGenerateRoute;
  final ConfigTextStyle? configTextStyle;
  final Map<String, Map<String, Color>>? initTheme;
  final LocalizationsDelegate<dynamic>? appLocalizations;

  CoreBaseApp({super.key,
    required this.initialRoute,
    required this.onGenerateRoute,
    this.theme,
    this.configTextStyle,
    this.appLocalizations,
    this.initTheme,
  }) {
    CoreBaseConfigState.configTextStyle = configTextStyle ?? ConfigTextStyle();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoreBaseConfigCubit()
        ..setUpColorTheme(initTheme),
      child: BlocBuilder<CoreBaseConfigCubit, CoreBaseConfigState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [routeObserver],
            title: 'Flutter Demo',
            onGenerateRoute: onGenerateRoute,
            locale: state.locale,
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: [
              if(appLocalizations != null) appLocalizations!,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: theme,
            initialRoute: initialRoute,
          );
        }
      ),
    );
  }
}
