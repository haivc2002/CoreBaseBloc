import 'package:core_base_bloc/core_base_bloc.dart';

/// ---------------------------------------------------------------------------
/// UseLocalizations
/// ---------------------------------------------------------------------------
///
/// A shared utility mixin for retrieving localized resources (l10n)
/// in a type-safe manner.
///
/// This mixin is optimized for core architecture layers, including:
/// - BaseView
/// - BaseXController
///
/// Design considerations:
/// - Decoupled from concrete UI implementations
/// - Enforces explicit localization type via generics
/// - Safe for reuse across multiple modules
///
/// Usage:
/// ```dart
/// class ExampleView
///   extends BaseView<ExampleXController, ExampleBloc, ExampleState>
///   with UseLocalizations<AppLocalizations> {
/// }
///
/// class ExampleXController
///   extends BaseXController<ExampleBloc>
///   with UseLocalizations<AppLocalizations> {
/// }
/// ```
///
/// Warnings:
/// - Omitting the generic type causes Dart to infer `dynamic`,
///   which weakens type safety and may introduce runtime failures.
/// - The provided `context` must be below a properly configured
///   `MaterialApp` or `CupertinoApp` with localization delegates.

mixin UseLocalizations<T> {

  BuildContext get context;

  /// ===========================================================================
  /// TXT – LOCALIZATION SETUP & USAGE GUIDE
  /// ===========================================================================
  ///
  /// This project uses Flutter `gen-l10n` to provide multi-language support
  /// and exposes a global helper [txt] for accessing localized strings
  /// without passing `BuildContext` manually.
  ///
  /// ---------------------------------------------------------------------------
  /// 1. DEFINE LOCALIZATION FILES (.arb)
  /// ---------------------------------------------------------------------------
  ///
  /// Create language-specific ARB files under the `l10n/` directory.
  ///
  /// Example:
  ///
  /// app_en.arb
  /// ```json
  /// {
  ///   "xinChao": "Hello"
  /// }
  /// ```
  ///
  /// app_vi.arb
  /// ```json
  /// {
  ///   "xinChao": "Xin chào"
  /// }
  /// ```
  ///
  /// Each key represents a localized string identifier.
  /// The same keys must exist across all language files.
  ///
  /// ---------------------------------------------------------------------------
  /// 2. GENERATE LOCALIZATION CLASSES
  /// ---------------------------------------------------------------------------
  ///
  /// Run the following command at the ROOT of the Flutter project:
  ///
  /// ```bash
  /// 👉 flutter gen-l10n
  /// ```
  ///
  /// This command generates localization classes, for example:
  /// - AppLocalizations
  /// - AppLocalizationsEn
  /// - AppLocalizationsVi
  ///
  /// These classes are generated automatically and should NOT be edited manually.
  ///
  /// ---------------------------------------------------------------------------
  /// 3. REGISTER LOCALIZATION DELEGATE IN CORE BASE APP
  /// ---------------------------------------------------------------------------
  ///
  /// Localization is registered at the base application level
  /// via `CoreBaseApp`, ensuring it is available globally.
  ///
  /// Example:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return CoreBaseApp(
  ///     ...
  ///     appLocalizations: AppLocalizations.delegate, // 👈 Register localization
  ///     ...
  ///   );
  /// }
  /// ```
  ///
  /// `AppLocalizations.delegate` is required for Flutter to resolve
  /// localized resources at runtime.
  ///
  /// ---------------------------------------------------------------------------
  /// 4. USING [l10n] FOR LOCALIZED STRINGS
  /// ---------------------------------------------------------------------------
  ///
  /// After configuration, localized strings can be accessed globally
  /// using the `l10n` helper.
  ///
  /// Example:
  ///
  /// class ExampleView extends BaseView<ExampleXController, ExampleBloc, ExampleState>
  ///     with UseLocalizations<AppLocalizations> {
  ///     ...
  /// @override
  /// Widget zBuildView() {
  ///    return Text(l10n.xinChao);
  /// }
  ///
  /// Enable for controller
  ///
  /// class ExampleXController extends BaseXController<ExampleBloc> with UseLocalizations<AppLocalizations> {...}
  ///
  /// This returns the localized value for the current locale:
  /// - "Hello" for English (`en`)
  /// - "Xin chào" for Vietnamese (`vi`)
  ///
  /// The `txt` helper internally resolves the localization instance
  /// using the application's global `navigatorKey`.
  ///
  /// ---------------------------------------------------------------------------
  /// NOTES
  /// ---------------------------------------------------------------------------
  ///
  /// - Locale switching is handled via `MaterialApp.locale`.
  /// - All localization files must stay in sync (same keys).
  /// - `txt` can be safely used in widgets, blocs, controllers, and services.
  /// - No `BuildContext` needs to be passed explicitly.
  ///
  /// ===========================================================================
  /// END OF [l10n] LOCALIZATION GUIDE
  /// ===========================================================================

  T get l10n {
    final value = Localizations.of<T>(context, T);
    assert(value != null, 'Localizations<$T> not found in context');
    return value!;
  }
}