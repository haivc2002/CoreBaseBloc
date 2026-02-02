import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class CoreApp extends StatelessWidget {
  final String initialRoute;
  final Route<dynamic>? Function(RouteSettings) onGenerateRoute;
  final Map<String, ThemeData>? configTheme;
  final LocalizationsDelegate<dynamic>? appLocalizations;

  CoreApp({super.key,
    required this.initialRoute,
    required this.onGenerateRoute,
    this.appLocalizations,
    this.configTheme,
  }) {
    CoreConfigState.configTheme = configTheme ?? const {};
  }

  /// How to setup [configTheme]
  /// Example:
  /// final configTheme = {
  ///   MyConstant.LIGHT_MODE: ThemeData(
  ///     useMaterial3: true,
  ///     textSelectionTheme: textSelectionTheme,
  ///     colorScheme: colorScheme,
  ///     scaffoldBackgroundColor: MyColor.ghostWhite,
  ///     extensions: const [
  ///       ThemeExtensions(
  ///         textPrimary: MyColor.darkNavy,
  ///         textSecondary: MyColor.warmGrey,
  ///         boxColor: MyColor.white,
  ///         loadingColor: MyColor.darkNavy,
  ///         refreshColor: MyColor.sliver
  ///       ),
  ///     ],
  ///     appBarTheme: const AppBarTheme(
  ///       backgroundColor: MyColor.white,
  ///       foregroundColor: MyColor.darkNavy,
  ///       elevation: 0,
  ///     ),
  ///     textTheme: TextTheme(
  ///       labelLarge: TextStyle(
  ///         fontSize: 18,
  ///         color: MyColor.darkNavy,
  ///         fontFamily: 'Poppins',
  ///       ),
  ///       labelMedium: TextStyle(
  ///         fontSize: 13,
  ///         color: MyColor.darkNavy,
  ///         fontFamily: 'Poppins',
  ///       ),
  ///       labelSmall: TextStyle(
  ///         fontSize: 9,
  ///         color: MyColor.darkNavy,
  ///         fontFamily: 'Poppins',
  ///       ),
  ///     ),
  ///   ),
  ///   MyConstant.DARK_MODE: ThemeData(
  ///     useMaterial3: true,
  ///     textSelectionTheme: textSelectionTheme,
  ///     colorScheme: colorScheme,
  ///     scaffoldBackgroundColor: MyColor.ghostWhiteDark,
  ///     extensions: const [
  ///       ThemeExtensions(
  ///         textPrimary: MyColor.darkNavyDark,
  ///         textSecondary: MyColor.warmGreyDark,
  ///         boxColor: MyColor.whiteDark,
  ///         loadingColor: MyColor.darkNavyDark,
  ///         refreshColor: MyColor.sliverDark
  ///       ),
  ///     ],
  ///     appBarTheme: const AppBarTheme(
  ///       backgroundColor: MyColor.whiteDark,
  ///       foregroundColor: MyColor.darkNavyDark,
  ///       elevation: 0,
  ///     ),
  ///     textTheme: TextTheme(
  ///       labelLarge: TextStyle(
  ///         fontSize: 18,
  ///         color: MyColor.darkNavyDark,
  ///         fontFamily: 'Poppins',
  ///       ),
  ///       labelMedium: TextStyle(
  ///         fontSize: 13,
  ///         color: MyColor.darkNavyDark,
  ///         fontFamily: 'Poppins',
  ///       ),
  ///       labelSmall: TextStyle(
  ///         fontSize: 9,
  ///         color: MyColor.darkNavyDark,
  ///         fontFamily: 'Poppins',
  ///       ),
  ///     ),
  ///   )
  /// };
  ///
  /// final textSelectionTheme = TextSelectionThemeData(
  ///   selectionHandleColor: Color(0xFF6AA8FF),
  ///   selectionColor: Color(0xFF6AA8FF).op5,
  ///   cursorColor: Color(0xFF6AA8FF).op5,
  /// );
  ///
  /// final colorScheme = ColorScheme.fromSeed(
  ///   seedColor: Color(0xFF6AA8FF).op5,
  /// );
  ///
  /// @immutable
  /// class ThemeExtensions extends ThemeExtension<ThemeExtensions> {
  ///   final Color textPrimary;
  ///   final Color textSecondary;
  ///   final Color boxColor;
  ///   final Color loadingColor;
  ///   final Color refreshColor;
  ///
  ///   const ThemeExtensions({
  ///     required this.textPrimary,
  ///     required this.textSecondary,
  ///     required this.boxColor,
  ///     required this.loadingColor,
  ///     required this.refreshColor,
  ///   });
  ///
  ///   @override
  ///   ThemeExtensions copyWith({
  ///     Color? textPrimary,
  ///     Color? textSecondary,
  ///     Color? boxColor,
  ///     Color? loadingColor,
  ///     Color? refreshColor,
  ///   }) {
  ///     return ThemeExtensions(
  ///       textPrimary: textPrimary ?? this.textPrimary,
  ///       textSecondary: textSecondary ?? this.textSecondary,
  ///       boxColor: boxColor ?? this.boxColor,
  ///       loadingColor: loadingColor ?? this.loadingColor,
  ///       refreshColor: refreshColor ?? this.refreshColor,
  ///     );
  ///   }
  ///
  ///   @override
  ///   ThemeExtensions lerp(
  ///       ThemeExtension<ThemeExtensions>? other,
  ///       double t,
  ///       ) {
  ///     if (other is! ThemeExtensions) return this;
  ///     return ThemeExtensions(
  ///       textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
  ///       textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
  ///       boxColor: Color.lerp(boxColor, other.boxColor, t)!,
  ///       refreshColor: Color.lerp(refreshColor, other.refreshColor, t)!,
  ///       loadingColor: Color.lerp(loadingColor, other.loadingColor, t)!,
  ///     );
  ///   }
  /// }
  ///
  /// USE:
  /// No need to transmit anything
  /// Or: theme.scaffoldBackgroundColor || Theme.of(context).scaffoldBackgroundColor
  /// With extension: theme.extension<ThemeExtensions>().textPrimary

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoreConfigBloc(),
      child: BlocBuilder<CoreConfigBloc, CoreConfigState>(
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
            theme: CoreConfigState.configTheme != {}
              ? deTheme(context, state.keyTheme)
              : ThemeData(),
            initialRoute: initialRoute,
          );
        }
      ),
    );
  }
}

ThemeData deTheme(BuildContext context, String key) {
  final state = context.read<CoreConfigBloc>().state;
  final data = CoreConfigState.configTheme[state.keyTheme];
  if (data != null) return data;
  return CoreConfigState.configTheme.values.first;
}
